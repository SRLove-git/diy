import {
  BadRequestException,
  ForbiddenException,
  Inject,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, IsNull, Repository } from 'typeorm';
import type Redis from 'ioredis';
import { FollowsService } from '../follows/follows.service';
import { REDIS_CLIENT } from '../redis/redis.module';
import { User } from '../users/user.entity';
import { Conversation } from './conversation.entity';
import { Message } from './message.entity';
import { MessageStatus } from './message_status.entity';

/** 消息内容类型：text 文本/表情；image 图片；video 视频（content 存 /uploads/video/... 相对路径）；voice 语音（content 存 {url,duration} JSON） */
export type MessageContentType = 'text' | 'image' | 'voice' | 'video';

/** 未互相关注时，单会话最多可发送的消息条数 */
const CHAT_LIMIT = 3;

/** 聊天媒体内容必须是本站上传的相对路径（图片走 chat/，视频走 video/） */
const MEDIA_URL_RE = /^\/uploads\/(chat|video)\/[\w./-]+$/;

/** 语音内容校验：JSON { url, duration }，url 必须是本站上传路径 */
function isValidVoiceContent(content: string): boolean {
  try {
    const j = JSON.parse(content) as { url?: unknown; duration?: unknown };
    return (
      typeof j.url === 'string' &&
      MEDIA_URL_RE.test(j.url) &&
      typeof j.duration === 'number' &&
      j.duration >= 0
    );
  } catch {
    return false;
  }
}

/** 消息内容合法性校验（单聊/群聊共用） */
export function isValidChatContent(
  type: MessageContentType,
  content: string,
): boolean {
  const body = content.trim();
  if (type === 'image' || type === 'video') return MEDIA_URL_RE.test(body);
  if (type === 'voice') return isValidVoiceContent(body);
  return body.length > 0;
}

/** 撤回时限（毫秒），群聊与单聊共用 */
export const RECALL_WINDOW_MS = 2 * 60 * 1000;

@Injectable()
export class ChatService {
  constructor(
    @InjectRepository(Conversation)
    private readonly conversations: Repository<Conversation>,
    @InjectRepository(Message)
    private readonly messages: Repository<Message>,
    @InjectRepository(MessageStatus)
    private readonly messageStatus: Repository<MessageStatus>,
    @InjectRepository(User)
    private readonly users: Repository<User>,
    private readonly follows: FollowsService,
    @Inject(REDIS_CLIENT)
    private readonly redis: Redis,
  ) {}

  private peerIdOf(conv: Conversation, userId: number): number {
    return conv.userAId === userId ? conv.userBId : conv.userAId;
  }

  /** 校验会话存在且当前用户是参与者 */
  async findConversationForUser(
    conversationId: number,
    userId: number,
  ): Promise<Conversation> {
    const conv = await this.conversations.findOneBy({ id: conversationId });
    if (!conv) throw new NotFoundException('会话不存在');
    if (conv.userAId !== userId && conv.userBId !== userId) {
      throw new ForbiddenException('无权访问该会话');
    }
    return conv;
  }

  /** 创建或复用与指定用户的会话（返回与列表一致的格式，含 peer 信息） */
  async createOrGet(userId: number, peerUserId: number) {
    if (peerUserId === userId)
      throw new BadRequestException('不能和自己发起会话');
    const peer = await this.users.findOneBy({ id: peerUserId });
    if (!peer) throw new BadRequestException('对方不存在');
    if (peer.isBanned) throw new BadRequestException('对方账号已被禁用');

    const [a, b] = [Math.min(userId, peerUserId), Math.max(userId, peerUserId)];
    let conv = await this.conversations.findOneBy({ userAId: a, userBId: b });
    if (!conv) {
      try {
        conv = await this.conversations.save(
          this.conversations.create({ userAId: a, userBId: b }),
        );
      } catch {
        // 并发创建时靠唯一约束兜底，返回已存在的会话
        conv = await this.conversations.findOneBy({ userAId: a, userBId: b });
        if (conv) return this._formatConv(conv, peerUserId, peer);
        throw new Error('创建会话失败');
      }
    }
    return this._formatConv(conv, peerUserId, peer);
  }

  /** 当前用户全部会话的对端用户 ID（在线状态广播用） */
  async conversationPeerIds(userId: number): Promise<number[]> {
    const convs = await this.conversations.find({
      where: [{ userAId: userId }, { userBId: userId }],
    });
    return convs.map((c) => this.peerIdOf(c, userId));
  }

  /** Redis 在线判断：chat:online:{userId} 连接计数 > 0 视为在线（心跳续期） */
  async isUserOnline(userId: number): Promise<boolean> {
    try {
      // 网络层已有 commandTimeout（1500ms），此处再叠加本地超时兜底，
      // Redis 不可用时按"离线"处理，不阻塞消息推送主流程
      const v = await Promise.race([
        this.redis.get(`chat:online:${userId}`),
        new Promise<null>((resolve) =>
          setTimeout(() => resolve(null), 1500),
        ),
      ]);
      return Number(v) > 0;
    } catch {
      // Redis 异常时回退为进程内连接表判断
      return false;
    }
  }

  /** 会话列表：对方信息（含在线状态）+ 最后一条预览 + 未读数 */
  async listConversations(userId: number, page = 1, pageSize = 20) {
    const [convs, total] = await this.conversations.findAndCount({
      where: [{ userAId: userId }, { userBId: userId }],
      // MySQL 中 DESC 排序时 NULL 排最后，天然实现"置顶在前、其余按时间"
      order: { pinnedAt: 'DESC', lastMessageAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
    if (convs.length === 0) return { items: [], total };

    const peerIds = convs.map((c) => this.peerIdOf(c, userId));
    const userMap = new Map(
      (await this.users.find({ where: { id: In(peerIds) } })).map((u) => [
        u.id,
        u,
      ]),
    );

    // Redis 在线集合（mget 一次取回全部对端状态）
    const online = new Set<number>();
    try {
      const counts = await this.redis.mget(
        peerIds.map((id) => `chat:online:${id}`),
      );
      counts.forEach((c, i) => {
        if (Number(c) > 0) online.add(peerIds[i]);
      });
    } catch {
      // Redis 异常时降级为全离线
    }

    // 每个会话的未读条数：message_status 为单一数据源（对方发来且我未读）
    const unreadRows = await this.messageStatus
      .createQueryBuilder('ms')
      .select('m.conversationId', 'conversationId')
      .addSelect('COUNT(*)', 'cnt')
      .innerJoin('messages', 'm', 'm.id = ms.messageId')
      .where('m.conversationId IN (:...ids)', { ids: convs.map((c) => c.id) })
      .andWhere('ms.userId = :userId', { userId })
      .andWhere('ms.readAt IS NULL')
      .andWhere('ms.deletedAt IS NULL')
      .groupBy('m.conversationId')
      .getRawMany<{ conversationId: string; cnt: string }>();
    const unreadMap = new Map<number, number>(
      unreadRows.map((r) => [Number(r.conversationId), Number(r.cnt)]),
    );

    const items = convs.map((c) => {
      const peerId = this.peerIdOf(c, userId);
      const peer = userMap.get(peerId);
      return {
        id: c.id,
        peer: {
          id: peerId,
          nickname: peer?.nickname ?? '',
          avatar: peer?.avatar ?? '',
          online: online.has(peerId),
        },
        lastMessagePreview: c.lastMessagePreview,
        lastMessageAt: c.lastMessageAt,
        unreadCount: unreadMap.get(c.id) ?? 0,
        pinned: c.pinnedAt != null,
      };
    });
    return { items, total };
  }

  /** 置顶/取消置顶会话 */
  async pinConversation(
    userId: number,
    conversationId: number,
    pinned: boolean,
  ): Promise<{ pinned: boolean }> {
    await this.findConversationForUser(conversationId, userId);
    await this.conversations.update(
      { id: conversationId },
      { pinnedAt: pinned ? new Date() : null },
    );
    return { pinned };
  }

  /** 删除会话及其全部消息（对双方生效） */
  async deleteConversation(
    userId: number,
    conversationId: number,
  ): Promise<void> {
    await this.findConversationForUser(conversationId, userId);
    await this.messages.manager.transaction(async (em) => {
      await em
        .createQueryBuilder()
        .delete()
        .from(MessageStatus)
        .where(
          'messageId IN (SELECT id FROM messages WHERE conversationId = :cid)',
          { cid: conversationId },
        )
        .execute();
      await em.delete(Message, { conversationId });
      await em.delete(Conversation, { id: conversationId });
    });
  }

  /** 游标分页拉取历史消息（按时间升序返回） */
  async getMessages(
    userId: number,
    conversationId: number,
    cursor = 0,
    limit = 50,
  ) {
    await this.findConversationForUser(conversationId, userId);
    const take = Math.min(Math.max(limit, 1), 100);
    const qb = this.messages
      .createQueryBuilder('m')
      // 已删除（仅对自己隐藏）的消息不返回：message_status 缺行视为未删除
      .leftJoin(
        MessageStatus,
        'ms',
        'ms.messageId = m.id AND ms.userId = :uid',
        { uid: userId },
      )
      .where('m.conversationId = :cid', { cid: conversationId })
      .andWhere('ms.id IS NULL OR ms.deletedAt IS NULL')
      .orderBy('m.id', 'DESC')
      .take(take);
    if (cursor > 0) qb.andWhere('m.id < :cursor', { cursor });
    const rows = await qb.getMany();
    rows.reverse();
    const nextCursor = rows.length >= take ? (rows[0]?.id ?? null) : null;
    return { items: rows, nextCursor };
  }

  /**
   * 发送消息（P1 优化：落库不阻塞实时转发）。
   *
   * 仅同步 INSERT 消息本体（1 次写入，返回完整消息拿 id/createdAt）；
   * 已读状态（message_status × 2）与会话冗余字段由 finalizeSend 异步补全。
   * 这样 `sent` 回执与对端推送只等待单次 INSERT，不受其余写放大拖累；
   * 异步补全失败仅影响未读数/会话预览/已读回执，消息本体已落库不丢失。
   */
  async sendMessage(
    userId: number,
    conversationId: number,
    contentType: MessageContentType,
    content: string,
    options: { replyToId?: number; forwarded?: boolean } = {},
  ) {
    const conv = await this.findConversationForUser(conversationId, userId);
    const peerId = this.peerIdOf(conv, userId);
    const peer = await this.users.findOneBy({ id: peerId });
    if (peer?.isBanned) throw new BadRequestException('对方账号已被禁用');

    // 聊天限制：互相关注无限畅聊；未互关（无关注或单向关注）每会话最多发 CHAT_LIMIT 条
    if (!(await this.follows.isMutual(userId, peerId))) {
      const sent = await this.messages.count({
        where: { conversationId, senderId: userId },
      });
      if (sent >= CHAT_LIMIT) {
        throw new ForbiddenException(
          `未互相关注，最多可发送 ${CHAT_LIMIT} 条消息，互相关注后即可畅聊`,
        );
      }
    }

    const type: MessageContentType =
      contentType === 'image'
        ? 'image'
        : contentType === 'voice'
          ? 'voice'
          : contentType === 'video'
            ? 'video'
            : 'text';
    const body = content.trim();
    if (!isValidChatContent(type, body)) {
      const tip =
        type === 'image'
          ? '图片地址不合法'
          : type === 'video'
            ? '视频地址不合法'
            : type === 'voice'
              ? '语音内容不合法'
              : '消息内容不能为空';
      throw new BadRequestException(tip);
    }

    // 引用校验：被引用消息必须存在于同一会话，并生成快照预览
    let replyPreview: string | null = null;
    if (options.replyToId) {
      const reply = await this.messages.findOneBy({
        id: options.replyToId,
        conversationId,
      });
      if (!reply) throw new BadRequestException('被引用的消息不存在');
      replyPreview = ChatService.previewOf(reply);
    }

    const message = await this.messages.save(
      this.messages.create({
        conversationId,
        senderId: userId,
        contentType: type,
        content: body,
        replyToId: options.replyToId ?? null,
        replyPreview,
        forwarded: options.forwarded ?? false,
      }),
    );

    // 异步补全（fire-and-forget）：失败仅影响未读数/预览，不影响消息送达
    void this.finalizeSend(message, peerId).catch((e) => {
      console.warn(
        '[ChatService] finalizeSend failed:',
        e instanceof Error ? e.message : e,
      );
    });

    return { message, peerId };
  }

  /** 消息快照预览（引用气泡 / 会话列表预览共用） */
  static previewOf(message: Message): string {
    if (message.recalledAt) return 'recalled:';
    switch (message.contentType) {
      case 'image':
        return 'image:';
      case 'voice':
        return 'voice:';
      case 'video':
        return 'video:';
      default:
        return `text:${message.content.slice(0, 50)}`;
    }
  }

  /** 发送后的异步补全：参与者各自已读状态 + 会话最后消息冗余字段（同事务） */
  private async finalizeSend(message: Message, peerId: number): Promise<void> {
    await this.messages.manager.transaction(async (em) => {
      // 参与者的各自已读状态：发送方立即已读，接收方待读
      await em.insert(MessageStatus, [
        { messageId: message.id, userId: message.senderId, readAt: message.createdAt },
        { messageId: message.id, userId: peerId, readAt: null },
      ]);
      const preview =
        message.contentType === 'image'
          ? 'image:'
          : message.contentType === 'voice'
            ? 'voice:'
            : message.contentType === 'video'
              ? 'video:'
              : `text:${message.content.slice(0, 50)}`;
      await em.update(
        Conversation,
        { id: message.conversationId },
        {
          lastMessageId: String(message.id),
          lastMessagePreview: preview,
          lastMessageAt: message.createdAt,
        },
      );
    });
  }

  /**
   * 撤回消息：仅发送者本人、发送后 2 分钟内可撤回，撤回对双方生效。
   * 若该消息为会话最后一条，同步把会话预览更新为撤回提示。
   */
  async recallMessage(
    userId: number,
    conversationId: number,
    messageId: number,
  ) {
    const conv = await this.findConversationForUser(conversationId, userId);
    const message = await this.messages.findOneBy({
      id: messageId,
      conversationId,
    });
    if (!message) throw new NotFoundException('消息不存在');
    if (message.senderId !== userId) {
      throw new ForbiddenException('只能撤回自己发送的消息');
    }
    if (message.recalledAt) throw new BadRequestException('消息已撤回');
    const age = Date.now() - (message.createdAt?.getTime() ?? 0);
    if (age > RECALL_WINDOW_MS) {
      throw new BadRequestException('发送超过 2 分钟的消息不能撤回');
    }
    const recalledAt = new Date();
    await this.messages.update(message.id, { recalledAt });
    message.recalledAt = recalledAt;
    // 会话最后一条消息被撤回时，列表预览同步为撤回提示
    if (
      conv.lastMessageId != null &&
      String(conv.lastMessageId) === String(message.id)
    ) {
      await this.conversations.update(conv.id, {
        lastMessagePreview: 'recalled:',
      });
    }
    return { message, peerId: this.peerIdOf(conv, userId) };
  }

  /**
   * 删除消息（仅对自己生效，对端不受影响）。
   * 利用 message_status 的 per-user 行记录删除时间；缺行时补建。
   */
  async deleteMessage(
    userId: number,
    conversationId: number,
    messageId: number,
  ) {
    await this.findConversationForUser(conversationId, userId);
    const message = await this.messages.findOneBy({
      id: messageId,
      conversationId,
    });
    if (!message) throw new NotFoundException('消息不存在');
    const existing = await this.messageStatus.findOneBy({ messageId, userId });
    const now = new Date();
    if (existing) {
      await this.messageStatus.update(existing.id, { deletedAt: now });
    } else {
      // finalizeSend 尚未执行（消息刚发出）时直接补建删除标记
      await this.messageStatus.insert({
        messageId,
        userId,
        readAt: null,
        deletedAt: now,
      });
    }
    return { ok: true };
  }

  /** 批量标记已读，返回已读时间与对端用户 ID */
  async markRead(userId: number, conversationId: number) {
    const conv = await this.findConversationForUser(conversationId, userId);
    const peerId = this.peerIdOf(conv, userId);
    const readAt = new Date();
    // message_status 为已读单一数据源（UPDATE 不支持别名前缀，列名直接引用）
    await this.messageStatus
      .createQueryBuilder()
      .update()
      .set({ readAt })
      .where('userId = :userId', { userId })
      .andWhere('readAt IS NULL')
      .andWhere(
        'messageId IN (SELECT m.id FROM messages m WHERE m.conversationId = :cid)',
        { cid: conversationId },
      )
      .execute();
    // 兼容字段：供历史接口直接返回 readAt
    await this.messages.update(
      { conversationId, senderId: peerId, readAt: IsNull() },
      { readAt },
    );
    return { readAt, peerId };
  }

  /** 格式化单条会话为前端友好格式（用于 createOrGet 等单条查询） */
  private _formatConv(conv: Conversation, peerId: number, peerUser: User) {
    return {
      id: conv.id,
      peer: {
        id: peerId,
        nickname: peerUser.nickname,
        avatar: peerUser.avatar,
        online: false,
      },
      lastMessagePreview: conv.lastMessagePreview,
      lastMessageAt: conv.lastMessageAt,
      unreadCount: 0,
      pinned: conv.pinnedAt != null,
    };
  }
}
