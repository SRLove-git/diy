import {
  BadRequestException,
  ConflictException,
  Inject,
  Injectable,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import type Redis from 'ioredis';
import { FindOptionsWhere, In, IsNull, Like, Repository } from 'typeorm';
import { FORCE_OFFLINE_TTL, kickKey } from '../auth/session-keys';
import { publishKickEvent } from '../chat/chat-events';
import { REDIS_CLIENT } from '../redis/redis.module';
import { Appointment } from '../appointments/appointment.entity';
import { Conversation } from '../chat/conversation.entity';
import { Group } from '../chat/group.entity';
import { GroupMember } from '../chat/group-member.entity';
import { GroupMessage } from '../chat/group-message.entity';
import { GroupMessageDeletion } from '../chat/group-message-deletion.entity';
import { GroupRead } from '../chat/group-read.entity';
import { Message } from '../chat/message.entity';
import { MessageStatus } from '../chat/message_status.entity';
import { Collection } from '../community/collection.entity';
import { Comment as PostComment } from '../community/comment.entity';
import { Like as PostLike } from '../community/like.entity';
import { Post } from '../community/post.entity';
import { Follow } from '../follows/follow.entity';
import { Membership } from '../members/membership.entity';
import { UserCoupon } from '../members/coupon.entity';
import { NotificationRead } from '../notifications/notification-read.entity';
import { Video } from '../videos/video.entity';
import { VideoComment } from '../videos/video-comment.entity';
import { VideoLike } from '../videos/video-like.entity';
import { History } from './history.entity';
import { User } from './user.entity';

@Injectable()
export class UsersService {
  /** 用户名一年内只能修改一次 */
  private static readonly USERNAME_CHANGE_INTERVAL_MS =
    365 * 24 * 60 * 60 * 1000;

  constructor(
    @Inject(REDIS_CLIENT) private readonly redis: Redis,
    @InjectRepository(User) private readonly users: Repository<User>,
    @InjectRepository(Post) private readonly posts: Repository<Post>,
    @InjectRepository(PostLike)
    private readonly postLikes: Repository<PostLike>,
    @InjectRepository(PostComment)
    private readonly postComments: Repository<PostComment>,
    @InjectRepository(Collection)
    private readonly collections: Repository<Collection>,
    @InjectRepository(History) private readonly history: Repository<History>,
    @InjectRepository(Video) private readonly videos: Repository<Video>,
    @InjectRepository(VideoLike)
    private readonly videoLikes: Repository<VideoLike>,
    @InjectRepository(VideoComment)
    private readonly videoComments: Repository<VideoComment>,
    @InjectRepository(Follow) private readonly follows: Repository<Follow>,
    @InjectRepository(NotificationRead)
    private readonly notificationReads: Repository<NotificationRead>,
    @InjectRepository(Membership)
    private readonly memberships: Repository<Membership>,
    @InjectRepository(UserCoupon)
    private readonly userCoupons: Repository<UserCoupon>,
    @InjectRepository(Appointment)
    private readonly appointments: Repository<Appointment>,
    @InjectRepository(Conversation)
    private readonly conversations: Repository<Conversation>,
    @InjectRepository(Message) private readonly messages: Repository<Message>,
    @InjectRepository(MessageStatus)
    private readonly messageStatuses: Repository<MessageStatus>,
    @InjectRepository(Group) private readonly groups: Repository<Group>,
    @InjectRepository(GroupMember)
    private readonly groupMembers: Repository<GroupMember>,
    @InjectRepository(GroupMessage)
    private readonly groupMessages: Repository<GroupMessage>,
    @InjectRepository(GroupRead)
    private readonly groupReads: Repository<GroupRead>,
    @InjectRepository(GroupMessageDeletion)
    private readonly groupMessageDeletions: Repository<GroupMessageDeletion>,
  ) {}

  findByEmail(email: string): Promise<User | null> {
    return this.users.findOneBy({ email });
  }

  findByUsername(username: string): Promise<User | null> {
    return this.users.findOneBy({ username });
  }

  /** 旧版手机号体系遗留的管理员（无用户名），迁移时补全用户名用 */
  findLegacyAdmin(): Promise<User | null> {
    return this.users.findOne({
      where: { role: 'admin', username: IsNull() },
      order: { id: 'ASC' },
    });
  }

  /** 按用户名或邮箱查找（登录用），两者均可登录 */
  async findByUsernameOrEmail(account: string): Promise<User | null> {
    const keyword = (account ?? '').trim();
    if (!keyword) return null;
    return this.users.findOne({
      where: [{ username: keyword }, { email: keyword.toLowerCase() }],
    });
  }

  /** 按用户名查用户，不存在则创建（预置演示作者用，并发下靠唯一约束兜底） */
  async findByUsernameOrCreate(data: {
    username: string;
    email: string;
    nickname: string;
    avatar: string;
  }): Promise<User> {
    const existing = await this.findByUsername(data.username);
    if (existing) return existing;
    try {
      return await this.create(data);
    } catch {
      const again = await this.findByUsername(data.username);
      if (again) return again;
      throw new Error('用户创建失败');
    }
  }

  /** 按用户名搜索用户（添加好友/社区找人用）：精确匹配，排除被封禁账号 */
  async searchByUsername(username: string): Promise<
    Array<{
      id: number;
      nickname: string;
      avatar: string;
      username: string;
      email: string;
    }>
  > {
    const keyword = (username ?? '').trim();
    if (!keyword) return [];
    const user = await this.users.findOneBy({
      username: keyword,
      isBanned: false,
    });
    if (!user) return [];
    return [
      {
        id: user.id,
        nickname: user.nickname || `用户 #${user.id}`,
        avatar: user.avatar,
        username: user.username ?? '',
        email: user.email ?? '',
      },
    ];
  }

  /** 管理端：按用户名/邮箱/昵称模糊搜索用户（订单按用户筛选用） */
  async findByKeyword(keyword: string): Promise<User[]> {
    const kw = (keyword ?? '').trim();
    if (!kw) return [];
    return this.users.find({
      where: [
        { username: Like(`%${kw}%`) },
        { email: Like(`%${kw}%`) },
        { nickname: Like(`%${kw}%`) },
      ],
      take: 200,
    });
  }

  findById(id: number): Promise<User | null> {
    return this.users.findOneBy({ id });
  }

  /** 批量按 ID 查用户 */
  findByIds(ids: number[]): Promise<User[]> {
    if (!ids.length) return Promise.resolve([]);
    return this.users.find({ where: { id: In(ids) } });
  }

  create(data: Partial<User>): Promise<User> {
    return this.users.save(this.users.create(data));
  }

  /** 更新个人资料：昵称 / 用户名 / 头像 / 简介 / 性别 / 生日 / 所在地。
   *  用户名去空格并做唯一校验，空串视为未设置；其他文本字段统一 trim。 */
  async updateProfile(
    id: number,
    patch: {
      nickname?: string;
      username?: string;
      avatar?: string;
      bio?: string;
      gender?: 'male' | 'female' | 'secret';
      birthday?: string;
      location?: string;
    },
  ) {
    const user = await this.users.findOneBy({ id });
    const data: Record<string, unknown> = {};
    if (patch.nickname !== undefined) data.nickname = patch.nickname.trim();
    if (patch.avatar !== undefined) data.avatar = patch.avatar;
    if (patch.bio !== undefined) data.bio = patch.bio.trim();
    if (patch.gender !== undefined) data.gender = patch.gender;
    if (patch.birthday !== undefined) data.birthday = patch.birthday || null;
    if (patch.location !== undefined) data.location = patch.location.trim();
    if (patch.username !== undefined) {
      const username = patch.username.trim();
      if (username && username.length < 2) {
        throw new BadRequestException('用户名至少 2 位');
      }
      const next = username || null;
      if (next) {
        const taken = await this.users.findOneBy({ username: next });
        if (taken && taken.id !== id) {
          throw new ConflictException('用户名已被占用');
        }
      }
      const current = user?.username ?? null;
      if (next !== current) {
        data.username = next;
        data.usernameUpdatedAt = this.resolveUsernameChange(
          user,
          current,
          next,
        );
      }
    }
    return this.users.update({ id }, data);
  }

  setPasswordHash(id: number, hash: string) {
    return this.users.update({ id }, { passwordHash: hash });
  }

  /** 设置用户名（首次设置不限；修改需距上次修改满一年，用于设置密码时一并写入） */
  async setUsername(id: number, username: string) {
    const user = await this.users.findOneBy({ id });
    const next = (username ?? '').trim() || null;
    const current = user?.username ?? null;
    const data: Record<string, unknown> = { username: next };
    if (next !== current) {
      data.usernameUpdatedAt = this.resolveUsernameChange(user, current, next);
    }
    return this.users.update({ id }, data);
  }

  /**
   * 校验“用户名一年内只能修改一次”：首次设置不受限；
   * 与当前值相同返回 null（不刷新修改时间），否则返回本次修改时间。
   */
  private resolveUsernameChange(
    user: User | null,
    current: string | null,
    next: string | null,
  ): Date | null {
    if (next === current) return null;
    const lastChangedAt = user?.usernameUpdatedAt;
    if (lastChangedAt) {
      const elapsed = Date.now() - new Date(lastChangedAt).getTime();
      if (elapsed < UsersService.USERNAME_CHANGE_INTERVAL_MS) {
        throw new BadRequestException('用户名一年内只能修改一次');
      }
    }
    return new Date();
  }

  setRole(id: number, role: 'admin' | 'user') {
    return this.users.update({ id }, { role });
  }

  /** 管理端：用户列表（分页，可选用户名/邮箱/昵称搜索） */
  async findAll(
    page = 1,
    search?: string,
    pageSize = 20,
  ): Promise<[User[], number]> {
    const keyword = (search ?? '').trim();
    const where: FindOptionsWhere<User> | FindOptionsWhere<User>[] = keyword
      ? [
          { username: Like(`%${keyword}%`) },
          { email: Like(`%${keyword}%`) },
          { nickname: Like(`%${keyword}%`) },
        ]
      : {};
    return this.users.findAndCount({
      where,
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
  }

  /** 管理端：封禁/解封用户（封禁时同时强制下线，解封时清除下线标记） */
  async toggleBan(id: number, isBanned: boolean): Promise<User> {
    await this.users.update({ id }, { isBanned });
    if (isBanned) {
      await this.redis.set(kickKey(id), '1', 'EX', FORCE_OFFLINE_TTL);
      publishKickEvent(this.redis, id, 'banned');
    } else {
      await this.redis.del(kickKey(id));
    }
    return this.users.findOneBy({ id }) as Promise<User>;
  }

  /** 管理端：强制下线（立即使该用户全部现有会话失效，用户可重新登录） */
  async forceOffline(userId: number): Promise<void> {
    await this.redis.set(kickKey(userId), '1', 'EX', FORCE_OFFLINE_TTL);
    publishKickEvent(this.redis, userId, 'forced_offline');
  }

  /** 管理端：物理删除某用户的全部作品（社区帖子 + 短视频/照片，含关联互动数据） */
  async deleteWorks(
    userId: number,
  ): Promise<{ posts: number; videos: number }> {
    const postIds = (
      await this.posts.find({ where: { userId }, select: { id: true } })
    ).map((p) => p.id);
    const videoIds = (
      await this.videos.find({ where: { userId }, select: { id: true } })
    ).map((v) => v.id);

    if (postIds.length) {
      await Promise.all([
        this.postLikes.delete({ postId: In(postIds) }),
        this.postComments.delete({ postId: In(postIds) }),
        this.collections.delete({ postId: In(postIds) }),
        this.history.delete({ postId: In(postIds) }),
      ]);
      await this.posts.delete(postIds);
    }
    if (videoIds.length) {
      await Promise.all([
        this.videoLikes.delete({ videoId: In(videoIds) }),
        this.videoComments.delete({ videoId: In(videoIds) }),
      ]);
      await this.videos.delete(videoIds);
    }
    return { posts: postIds.length, videos: videoIds.length };
  }

  /** 管理端：物理删除用户（含作品、互动、关注、会员、预约、聊天等全部关联数据） */
  async remove(userId: number): Promise<{ posts: number; videos: number }> {
    // 删除账号前先令其现有会话失效并踢线，避免旧 token 继续访问
    await this.redis.set(kickKey(userId), '1', 'EX', FORCE_OFFLINE_TTL);
    publishKickEvent(this.redis, userId, 'forced_offline');

    // 1. 先删除该用户发布的全部作品及互动数据
    const { posts, videos } = await this.deleteWorks(userId);

    // 2. 用户产生的互动/浏览/预约/会员/关注等记录
    await Promise.all([
      this.postLikes.delete({ userId }),
      this.postComments.delete({ userId }),
      this.collections.delete({ userId }),
      this.history.delete({ userId }),
      this.videoLikes.delete({ userId }),
      this.videoComments.delete({ userId }),
      this.follows.delete([{ followerId: userId }, { followeeId: userId }]),
      this.memberships.delete({ userId }),
      this.userCoupons.delete({ userId }),
      this.notificationReads.delete({ userId }),
      this.appointments.delete({ userId }),
    ]);

    // 3. 聊天数据：用户参与的私聊、发送的消息，以及其创建的群聊
    const conversationIds = (
      await this.conversations.find({
        where: [{ userAId: userId }, { userBId: userId }],
        select: { id: true },
      })
    ).map((c) => c.id);
    const groupIds = (
      await this.groups.find({
        where: { ownerId: userId },
        select: { id: true },
      })
    ).map((g) => g.id);

    if (conversationIds.length) {
      const messageIds = (
        await this.messages.find({
          where: { conversationId: In(conversationIds) },
          select: { id: true },
        })
      ).map((m) => m.id);
      await Promise.all([
        this.messageStatuses.delete([
          { userId },
          ...(messageIds.length ? [{ messageId: In(messageIds) }] : []),
        ]),
        this.messages.delete({ senderId: userId }),
        this.messages.delete({ conversationId: In(conversationIds) }),
        this.conversations.delete(conversationIds),
      ]);
    } else {
      await Promise.all([
        this.messageStatuses.delete({ userId }),
        this.messages.delete({ senderId: userId }),
      ]);
    }

    if (groupIds.length) {
      await Promise.all([
        this.groupMessageDeletions.delete({ groupId: In(groupIds) }),
        this.groupReads.delete({ groupId: In(groupIds) }),
        this.groupMessages.delete({ groupId: In(groupIds) }),
        this.groupMembers.delete({ groupId: In(groupIds) }),
        this.groups.delete(groupIds),
      ]);
    }
    await Promise.all([
      this.groupMembers.delete({ userId }),
      this.groupReads.delete({ userId }),
      this.groupMessageDeletions.delete({ userId }),
      this.groupMessages.delete({ senderId: userId }),
    ]);

    // 4. 删除用户账号
    await this.users.delete({ id: userId });
    return { posts, videos };
  }
}
