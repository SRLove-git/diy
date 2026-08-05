import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Like, Repository } from 'typeorm';
import { Collection } from '../community/collection.entity';
import { Comment as PostComment } from '../community/comment.entity';
import { Like as PostLike } from '../community/like.entity';
import { Post } from '../community/post.entity';
import { Report } from '../community/report.entity';
import { Video } from '../videos/video.entity';
import { VideoComment } from '../videos/video-comment.entity';
import { VideoLike } from '../videos/video-like.entity';
import { History } from './history.entity';
import { User } from './user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User) private readonly users: Repository<User>,
    @InjectRepository(Post) private readonly posts: Repository<Post>,
    @InjectRepository(PostLike) private readonly postLikes: Repository<PostLike>,
    @InjectRepository(PostComment)
    private readonly postComments: Repository<PostComment>,
    @InjectRepository(Collection)
    private readonly collections: Repository<Collection>,
    @InjectRepository(Report) private readonly reports: Repository<Report>,
    @InjectRepository(History) private readonly history: Repository<History>,
    @InjectRepository(Video) private readonly videos: Repository<Video>,
    @InjectRepository(VideoLike)
    private readonly videoLikes: Repository<VideoLike>,
    @InjectRepository(VideoComment)
    private readonly videoComments: Repository<VideoComment>,
  ) {}

  findByPhone(phone: string): Promise<User | null> {
    return this.users.findOneBy({ phone });
  }

  /** 按手机号搜索用户（添加好友用）：精确匹配，排除自己与被封禁账号 */
  async searchByPhone(phone: string): Promise<
    Array<{ id: number; nickname: string; avatar: string; phoneMasked: string }>
  > {
    const keyword = (phone ?? '').trim();
    if (!keyword) return [];
    const user = await this.users.findOneBy({
      phone: keyword,
      isBanned: false,
    });
    if (!user) return [];
    const masked = `${user.phone.slice(0, 3)}****${user.phone.slice(-4)}`;
    return [
      {
        id: user.id,
        nickname: user.nickname || `用户 #${user.id}`,
        avatar: user.avatar,
        phoneMasked: masked,
      },
    ];
  }

  findByUsername(username: string): Promise<User | null> {
    return this.users.findOneBy({ username });
  }

  /** 按手机号查用户，不存在则创建（并发下靠唯一约束兜底） */
  async findByPhoneOrCreate(phone: string): Promise<User> {
    const existing = await this.findByPhone(phone);
    if (existing) return existing;
    try {
      return await this.create({ phone });
    } catch {
      const again = await this.findByPhone(phone);
      if (again) return again;
      throw new Error('用户创建失败');
    }
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

  updateProfile(id: number, patch: { nickname?: string; avatar?: string }) {
    return this.users.update({ id }, patch);
  }

  setPasswordHash(id: number, hash: string) {
    return this.users.update({ id }, { passwordHash: hash });
  }

  setUsername(id: number, username: string) {
    return this.users.update({ id }, { username });
  }

  setRole(id: number, role: 'admin' | 'user') {
    return this.users.update({ id }, { role });
  }

  /** 管理端：用户列表（分页，可选手机号/昵称搜索） */
  async findAll(page = 1, search?: string, pageSize = 20): Promise<[User[], number]> {
    const keyword = (search ?? '').trim();
    const where: any = keyword
      ? [
          { phone: Like(`%${keyword}%`) },
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

  /** 管理端：封禁/解封用户 */
  async toggleBan(id: number, isBanned: boolean): Promise<User> {
    await this.users.update({ id }, { isBanned });
    return this.users.findOneBy({ id }) as Promise<User>;
  }

  /** 管理端：物理删除某用户的全部作品（社区帖子 + 短视频/照片，含关联互动数据） */
  async deleteWorks(userId: number): Promise<{ posts: number; videos: number }> {
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
        this.reports.delete({ postId: In(postIds) }),
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
}
