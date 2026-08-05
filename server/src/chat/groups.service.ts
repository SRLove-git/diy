import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, MoreThan, Repository } from 'typeorm';
import { User } from '../users/user.entity';
import { Group } from './group.entity';
import { GroupMember } from './group-member.entity';
import { GroupMessage } from './group-message.entity';
import { GroupRead } from './group-read.entity';

/** 群聊服务：建群 / 群列表 / 群消息 / 已读 / 成员 */
@Injectable()
export class GroupsService {
  constructor(
    @InjectRepository(Group)
    private readonly groups: Repository<Group>,
    @InjectRepository(GroupMember)
    private readonly members: Repository<GroupMember>,
    @InjectRepository(GroupMessage)
    private readonly messages: Repository<GroupMessage>,
    @InjectRepository(GroupRead)
    private readonly reads: Repository<GroupRead>,
    @InjectRepository(User)
    private readonly users: Repository<User>,
  ) {}

  // ──── 建群 ────

  async create(ownerId: number, name: string, memberIds: number[]) {
    const unique = [...new Set(memberIds)].filter((id) => id !== ownerId);
    if (unique.length === 0) {
      throw new BadRequestException('请至少选择一名群成员');
    }
    const users = await this.users.findBy({ id: In(unique) });
    if (users.length !== unique.length) {
      throw new BadRequestException('存在无效的群成员');
    }
    if (users.some((u) => u.isBanned)) {
      throw new BadRequestException('存在已被禁用的用户');
    }

    const group = await this.groups.save(
      this.groups.create({ name: name.trim(), ownerId }),
    );
    await this.members.save(
      this.members.create({ groupId: group.id, userId: ownerId }),
    );
    for (const uid of unique) {
      await this.members.save(
        this.members.create({ groupId: group.id, userId: uid }),
      );
    }
    return this.formatGroup(group, ownerId, users.length + 1, []);
  }

  // ──── 我的群列表 ────

  async myGroups(userId: number, page = 1, pageSize = 50) {
    const rows = await this.members.findBy({ userId });
    if (!rows.length) return { items: [], total: 0 };
    const groupIds = rows.map((r) => r.groupId);
    const groups = await this.groups.find({
      where: { id: In(groupIds) },
      order: { lastMessageAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    const pageIds = groups.map((g) => g.id);
    const [allMembers, allReads] = await Promise.all([
      this.members.find({ where: { groupId: In(pageIds) } }),
      this.reads.find({ where: { groupId: In(pageIds), userId } }),
    ]);
    const memberMap = new Map<number, GroupMember[]>();
    for (const m of allMembers) {
      const list = memberMap.get(m.groupId) ?? [];
      list.push(m);
      memberMap.set(m.groupId, list);
    }
    const readMap = new Map(allReads.map((r) => [r.groupId, r]));

    // 群成员头像（取前 3 位，不含自己）
    const memberIds = [
      ...new Set(allMembers.map((m) => m.userId).filter((id) => id !== userId)),
    ];
    const userMap = new Map(
      (await this.users.find({ where: { id: In(memberIds) } })).map((u) => [
        u.id,
        u,
      ]),
    );

    const items = await Promise.all(
      groups.map(async (g) => {
        const members = memberMap.get(g.id) ?? [];
        const lastRead = readMap.get(g.id);
        const last = Number(lastRead?.lastReadMessageId ?? 0);
        const unread = await this.messages.countBy({
          groupId: g.id,
          ...(last > 0 ? { id: MoreThan(last) } : {}),
        });
        const avatars = members
          .filter((m) => m.userId !== userId)
          .slice(0, 3)
          .map((m) => userMap.get(m.userId)?.avatar ?? '');
        return this.formatGroup(g, userId, members.length, avatars, unread);
      }),
    );
    return { items, total: groupIds.length };
  }

  // ──── 消息 ────

  async getMessages(userId: number, groupId: number, cursor = 0, limit = 50) {
    await this.assertMember(groupId, userId);
    const take = Math.min(Math.max(limit, 1), 100);
    const qb = this.messages
      .createQueryBuilder('m')
      .where('m.groupId = :groupId', { groupId })
      .orderBy('m.id', 'DESC')
      .take(take);
    if (cursor > 0) qb.andWhere('m.id < :cursor', { cursor });
    const rows = await qb.getMany();
    rows.reverse();
    const total = await this.messages.countBy({ groupId });
    const items = rows;
    const nextCursor = rows.length >= take ? (rows[0]?.id ?? null) : null;
    const enriched = await this.enrichMessages(items);
    return { items: enriched, total, nextCursor };
  }

  /** 发群消息：落库 + 更新群预览，返回消息与需要推送的成员 ID */
  async sendMessage(
    userId: number,
    groupId: number,
    contentType: 'text' | 'image' | 'voice',
    content: string,
  ) {
    await this.assertMember(groupId, userId);
    const message = await this.messages.save(
      this.messages.create({ groupId, senderId: userId, contentType, content }),
    );
    const preview =
      contentType === 'image'
        ? 'image:'
        : contentType === 'voice'
          ? 'voice:'
          : `text:${content}`;
    await this.groups.update(groupId, {
      lastMessageId: String(message.id),
      lastMessagePreview: preview,
      lastMessageAt: message.createdAt,
    });
    const memberIds = await this.groupMemberIds(groupId);
    const [author] = await this.enrichMessages([message]);
    return {
      message: author,
      memberIds,
      groupId,
    };
  }

  /** 标记已读（游标为群内最大已读消息 id） */
  async markRead(userId: number, groupId: number, lastMessageId: number) {
    await this.assertMember(groupId, userId);
    const existing = await this.reads.findOneBy({ groupId, userId });
    if (existing) {
      if (Number(existing.lastReadMessageId) < lastMessageId) {
        existing.lastReadMessageId = String(lastMessageId);
        await this.reads.save(existing);
      }
    } else {
      await this.reads.save(
        this.reads.create({ groupId, userId, lastReadMessageId: String(lastMessageId) }),
      );
    }
    return { ok: true };
  }

  // ──── 成员 ────

  async listMembers(groupId: number, viewerId?: number) {
    if (viewerId != null) await this.assertMember(groupId, viewerId);
    const rows = await this.members.findBy({ groupId });
    const ids = rows.map((r) => r.userId);
    if (!ids.length) return [];
    const users = await this.users.find({ where: { id: In(ids) } });
    const map = new Map(users.map((u) => [u.id, u]));
    return ids
      .filter((id) => map.has(id))
      .map((id) => {
        const u = map.get(id)!;
        return {
          id: u.id,
          nickname: u.nickname,
          avatar: u.avatar,
          role: u.role,
        };
      });
  }

  async groupMemberIds(groupId: number): Promise<number[]> {
    const rows = await this.members.find({
      where: { groupId },
      select: { userId: true },
    });
    return rows.map((r) => r.userId);
  }

  async isMember(groupId: number, userId: number): Promise<boolean> {
    return this.members.existsBy({ groupId, userId });
  }

  private async assertMember(groupId: number, userId: number) {
    const group = await this.groups.findOneBy({ id: groupId });
    if (!group) throw new NotFoundException('群聊不存在');
    if (!(await this.isMember(groupId, userId))) {
      throw new ForbiddenException('你不是该群成员');
    }
  }

  // ──── 组装 ────

  private formatGroup(
    group: Group,
    viewerId: number,
    memberCount: number,
    memberAvatars: string[],
    unreadCount = 0,
  ) {
    return {
      id: group.id,
      name: group.name,
      ownerId: group.ownerId,
      memberCount,
      memberAvatars,
      lastMessagePreview: group.lastMessagePreview,
      lastMessageAt: group.lastMessageAt,
      unreadCount,
      isOwner: group.ownerId === viewerId,
      createdAt: group.createdAt,
    };
  }

  /** 群消息附加发送者信息 */
  private async enrichMessages(items: GroupMessage[]) {
    if (!items.length) return items;
    const ids = [...new Set(items.map((m) => m.senderId))];
    const users = await this.users.find({
      where: { id: In(ids) },
      select: { id: true, nickname: true, avatar: true },
    });
    const map = new Map(users.map((u) => [u.id, u]));
    return items.map((m) => ({
      ...m,
      author: map.get(m.senderId)
        ? {
            id: m.senderId,
            nickname: map.get(m.senderId)!.nickname,
            avatar: map.get(m.senderId)!.avatar,
          }
        : { id: m.senderId, nickname: `用户 #${m.senderId}`, avatar: '' },
    }));
  }
}
