import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';

import { Follow } from '../follows/follow.entity';
import { User } from '../users/user.entity';
import { Video } from './video.entity';
import { VideoComment } from './video-comment.entity';
import { VideoLike } from './video-like.entity';
import { CreateVideoDto } from './video.dto';

/** 作者简要信息 + 粉丝数（嵌入列表响应，避免 N+1） */
export interface VideoAuthor {
  id: number;
  nickname: string;
  avatar: string;
  /** 作者粉丝数（来自关注表统计） */
  followCount: number;
}

/** 客户端短视频条目（feed / 详情） */
export interface VideoItem {
  id: number;
  userId: number;
  title: string;
  content: string;
  cover: string;
  videoUrl: string;
  duration: number;
  aspectRatio: number;
  music: string;
  tags: string[];
  location: string;
  photos: string[];
  filter: string;
  trimStart: number;
  trimEnd: number;
  speed: number;
  rotation: number;
  likeCount: number;
  commentCount: number;
  shareCount: number;
  viewCount: number;
  createdAt: Date;
  author: VideoAuthor;
  /** 当前用户是否已点赞 */
  liked: boolean;
}

@Injectable()
export class VideosService {
  constructor(
    @InjectRepository(Video)
    private readonly videos: Repository<Video>,
    @InjectRepository(VideoLike)
    private readonly likes: Repository<VideoLike>,
    @InjectRepository(VideoComment)
    private readonly comments: Repository<VideoComment>,
    @InjectRepository(Follow)
    private readonly follows: Repository<Follow>,
    @InjectRepository(User)
    private readonly users: Repository<User>,
  ) {}

  // ──── Helpers ────

  /** 批量查询作者信息 + 粉丝数，返回 userId → VideoAuthor 映射 */
  private async resolveAuthors(
    userIds: number[],
  ): Promise<Map<number, VideoAuthor>> {
    const unique = [...new Set(userIds)];
    if (!unique.length) return new Map();

    const [users, followerRows] = await Promise.all([
      this.users.find({
        where: { id: In(unique) },
        select: { id: true, nickname: true, avatar: true },
      }),
      this.follows
        .createQueryBuilder('f')
        .select('f.followeeId', 'followeeId')
        .addSelect('COUNT(*)', 'cnt')
        .where('f.followeeId IN (:...ids)', { ids: unique })
        .groupBy('f.followeeId')
        .getRawMany<{ followeeId: number; cnt: number }>(),
    ]);

    const followerCounts = new Map<number, number>();
    for (const row of followerRows) {
      followerCounts.set(Number(row.followeeId), Number(row.cnt));
    }

    return new Map(
      users.map((u) => [
        u.id,
        {
          id: u.id,
          nickname: u.nickname,
          avatar: u.avatar,
          followCount: followerCounts.get(u.id) ?? 0,
        },
      ]),
    );
  }

  /** 当前用户已点赞的视频 id 集合（未登录返回空集合） */
  private async likedSet(
    userId: number | undefined,
    videoIds: number[],
  ): Promise<Set<number>> {
    if (!userId || !videoIds.length) return new Set();
    const rows = await this.likes.findBy({ userId, videoId: In(videoIds) });
    return new Set(rows.map((l) => l.videoId));
  }

  private fallbackAuthor(userId: number): VideoAuthor {
    return {
      id: userId,
      nickname: `用户 #${userId}`,
      avatar: '',
      followCount: 0,
    };
  }

  /** 将视频实体合并作者信息 / 点赞状态为客户端格式 */
  private enrich(
    list: Video[],
    authors: Map<number, VideoAuthor>,
    liked: Set<number>,
  ): VideoItem[] {
    return list.map((v) => ({
      ...v,
      author: authors.get(v.userId) ?? this.fallbackAuthor(v.userId),
      liked: liked.has(v.id),
    }));
  }

  // ──── Feed ────

  /** 推荐信息流：全部已通过视频，按创建时间倒序 */
  async recommendFeed(userId: number | undefined, page = 1, pageSize = 20) {
    const [list, total] = await this.videos.findAndCount({
      where: { status: 'approved' },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
    const [authors, liked] = await Promise.all([
      this.resolveAuthors(list.map((v) => v.userId)),
      this.likedSet(
        userId,
        list.map((v) => v.id),
      ),
    ]);
    return [this.enrich(list, authors, liked), total];
  }

  /** 关注信息流：已关注作者发布的视频 */
  async followingFeed(userId: number, page = 1, pageSize = 20) {
    const followees = await this.follows.find({
      where: { followerId: userId },
      select: { followeeId: true },
    });
    const followeeIds = followees.map((f) => f.followeeId);
    if (!followeeIds.length) return [[], 0];

    const [list, total] = await this.videos.findAndCount({
      where: { status: 'approved', userId: In(followeeIds) },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
    const [authors, liked] = await Promise.all([
      this.resolveAuthors(list.map((v) => v.userId)),
      this.likedSet(
        userId,
        list.map((v) => v.id),
      ),
    ]);
    return [this.enrich(list, authors, liked), total];
  }

  /** 我的发布列表（含未审核通过状态，供个人页展示） */
  async myVideos(userId: number, page = 1, pageSize = 20) {
    const [list, total] = await this.videos.findAndCount({
      where: { userId },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
    const [authors, liked] = await Promise.all([
      this.resolveAuthors([userId]),
      this.likedSet(
        userId,
        list.map((v) => v.id),
      ),
    ]);
    return [this.enrich(list, authors, liked), total];
  }

  /** 指定作者的视频列表 */
  async userVideos(authorId: number, page = 1, pageSize = 20) {
    const [list, total] = await this.videos.findAndCount({
      where: { userId: authorId, status: 'approved' },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
    const authors = await this.resolveAuthors([authorId]);
    return [this.enrich(list, authors, new Set<number>()), total];
  }

  // ──── Detail ────

  /** 视频详情（已下架/驳回视为不存在） */
  async detail(id: number, userId?: number): Promise<VideoItem> {
    const video = await this.videos.findOneBy({ id });
    if (!video || video.status === 'rejected') {
      throw new NotFoundException('视频不存在');
    }
    const [authors, liked] = await Promise.all([
      this.resolveAuthors([video.userId]),
      this.likedSet(userId, [id]),
    ]);
    return this.enrich([video], authors, liked)[0];
  }

  // ──── Publish ────

  /** 视频总数（开发环境种子数据判断用） */
  async countVideos(): Promise<number> {
    return this.videos.count();
  }

  async create(userId: number, dto: CreateVideoDto): Promise<Video> {
    const video = this.videos.create({
      userId,
      title: dto.title ?? '',
      content: dto.content ?? '',
      cover: dto.cover ?? '',
      videoUrl: dto.videoUrl ?? '',
      photos: dto.photos ?? [],
      filter: dto.filter ?? '',
      trimStart: dto.trimStart ?? 0,
      trimEnd: dto.trimEnd ?? 0,
      speed: dto.speed ?? 1,
      rotation: dto.rotation ?? 0,
      duration: dto.duration ?? 15,
      aspectRatio: dto.aspectRatio ?? 0,
      music: dto.music ?? '',
      tags: dto.tags ?? [],
      location: dto.location ?? '',
      status: 'approved',
    });
    return this.videos.save(video);
  }

  // ──── Like operations ────

  async toggleLike(
    userId: number,
    videoId: number,
  ): Promise<{ liked: boolean }> {
    const video = await this.videos.findOneBy({ id: videoId });
    if (!video) throw new NotFoundException('视频不存在');

    const existing = await this.likes.findOneBy({ userId, videoId });
    if (existing) {
      await this.likes.delete({ userId, videoId });
      await this.videos.decrement({ id: videoId }, 'likeCount', 1);
      return { liked: false };
    }
    await this.likes.save(this.likes.create({ userId, videoId }));
    await this.videos.increment({ id: videoId }, 'likeCount', 1);
    return { liked: true };
  }

  async isLiked(userId: number, videoId: number): Promise<boolean> {
    return this.likes.existsBy({ userId, videoId });
  }

  /** 批量查询当前用户点赞状态（信息流预取用） */
  async hasUserLikedMultiple(
    userId: number,
    videoIds: number[],
  ): Promise<Set<number>> {
    return this.likedSet(userId, videoIds);
  }

  // ──── Comment operations ────

  async getComments(videoId: number, page = 1, pageSize = 50) {
    const [list, total] = await this.comments.findAndCount({
      where: { videoId },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
    const authors = await this.resolveAuthors(list.map((c) => c.userId));
    return [
      list.map((c) => ({
        ...c,
        author: authors.get(c.userId) ?? this.fallbackAuthor(c.userId),
      })),
      total,
    ];
  }

  async addComment(
    userId: number,
    videoId: number,
    content: string,
  ): Promise<VideoComment & { author: VideoAuthor }> {
    const video = await this.videos.findOneBy({ id: videoId });
    if (!video) throw new NotFoundException('视频不存在');

    const saved = await this.comments.save(
      this.comments.create({ userId, videoId, content }),
    );
    await this.videos.increment({ id: videoId }, 'commentCount', 1);

    const authors = await this.resolveAuthors([userId]);
    return {
      ...saved,
      author: authors.get(userId) ?? this.fallbackAuthor(userId),
    };
  }

  // ──── View / Share ────

  /** 记录浏览（浏览量 +1） */
  async recordView(id: number): Promise<void> {
    const video = await this.videos.findOneBy({ id });
    if (!video || video.status === 'rejected') return;
    await this.videos.increment({ id }, 'viewCount', 1);
  }

  /** 记录分享（分享数 +1） */
  async recordShare(id: number): Promise<void> {
    const video = await this.videos.findOneBy({ id });
    if (!video || video.status === 'rejected') return;
    await this.videos.increment({ id }, 'shareCount', 1);
  }
}
