import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, IsNull, Repository } from 'typeorm';
import { User } from '../users/user.entity';
import { Conversation } from './conversation.entity';
import { Message } from './message.entity';

@Injectable()
export class ChatService {
  constructor(
    @InjectRepository(Conversation)
    private readonly conversations: Repository<Conversation>,
    @InjectRepository(Message)
    private readonly messages: Repository<Message>,
    @InjectRepository(User)
    private readonly users: Repository<User>,
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

  /** 创建或复用与指定用户的会话 */
  async createOrGet(userId: number, peerUserId: number): Promise<Conversation> {
    if (peerUserId === userId)
      throw new BadRequestException('不能和自己发起会话');
    const peer = await this.users.findOneBy({ id: peerUserId });
    if (!peer) throw new BadRequestException('对方不存在');
    if (peer.isBanned) throw new BadRequestException('对方账号已被禁用');

    const [a, b] = [Math.min(userId, peerUserId), Math.max(userId, peerUserId)];
    let conv = await this.conversations.findOneBy({ userAId: a, userBId: b });
    if (conv) return conv;
    try {
      conv = await this.conversations.save(
        this.conversations.create({ userAId: a, userBId: b }),
      );
      return conv;
    } catch {
      // 并发创建时靠唯一约束兜底，返回已存在的会话
      conv = await this.conversations.findOneBy({ userAId: a, userBId: b });
      if (conv) return conv;
      throw new Error('创建会话失败');
    }
  }

  /** 会话列表：对方信息 + 最后一条预览 + 未读数（置顶在前，再按最后消息时间） */
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

    // 每个会话的未读条数（对方发来且我未读）
    // 注意：项目未启用 snake_case 命名策略，列名为实体属性名（camelCase）
    const unreadRows = await this.messages
      .createQueryBuilder('m')
      .select('m.conversationId', 'conversationId')
      .addSelect('COUNT(*)', 'cnt')
      .where('m.conversationId IN (:...ids)', { ids: convs.map((c) => c.id) })
      .andWhere('m.senderId != :userId', { userId })
      .andWhere('m.readAt IS NULL')
      .groupBy('m.conversationId')
      .getRawMany<{ conversationId: string; cnt: string }>();
    const unreadMap = new Map<number, number>(
      unreadRows.map((r) => [Number(r.conversationId), Number(r.cnt)]),
    );

    const items = convs.map((c) => {
      const peer = userMap.get(this.peerIdOf(c, userId));
      return {
        id: c.id,
        peer: {
          id: this.peerIdOf(c, userId),
          nickname: peer?.nickname ?? '',
          avatar: peer?.avatar ?? '',
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
      .where('m.conversationId = :cid', { cid: conversationId })
      .orderBy('m.id', 'DESC')
      .take(take);
    if (cursor > 0) qb.andWhere('m.id < :cursor', { cursor });
    const rows = await qb.getMany();
    rows.reverse();
    const nextCursor = rows.length >= take ? (rows[0]?.id ?? null) : null;
    return { items: rows, nextCursor };
  }

  /** 发送消息：落库并更新会话冗余字段（同事务） */
  async sendMessage(userId: number, conversationId: number, content: string) {
    const conv = await this.findConversationForUser(conversationId, userId);
    const peerId = this.peerIdOf(conv, userId);
    const peer = await this.users.findOneBy({ id: peerId });
    if (peer?.isBanned) throw new BadRequestException('对方账号已被禁用');

    const text = content.trim();
    const message = this.messages.create({
      conversationId,
      senderId: userId,
      contentType: 'text',
      content: text,
    });
    await this.messages.manager.transaction(async (em) => {
      const saved = await em.save(message);
      await em.update(
        Conversation,
        { id: conversationId },
        {
          lastMessageId: String(saved.id),
          lastMessagePreview: `text:${text.slice(0, 50)}`,
          lastMessageAt: saved.createdAt,
        },
      );
      return saved;
    });
    return { message, peerId };
  }

  /** 批量标记已读，返回已读时间与对端用户 ID */
  async markRead(userId: number, conversationId: number) {
    const conv = await this.findConversationForUser(conversationId, userId);
    const peerId = this.peerIdOf(conv, userId);
    const readAt = new Date();
    await this.messages.update(
      { conversationId, senderId: peerId, readAt: IsNull() },
      { readAt },
    );
    return { readAt, peerId };
  }
}
