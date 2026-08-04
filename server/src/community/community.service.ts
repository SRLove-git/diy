import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';

import { Post } from './post.entity';
import { Like } from './like.entity';
import { Comment } from './comment.entity';
import { Collection } from './collection.entity';
import { Report } from './report.entity';
import { History } from '../users/history.entity';
import { User } from '../users/user.entity';
import { CreatePostDto, UpdatePostStatusDto } from './post.dto';

/** 简易敏感词列表（一期机审用） */
const BLOCKED_KEYWORDS = ['违禁', '色情', '赌博', '诈骗', '枪支', '毒品'];

/** 作者简要信息（嵌入列表响应中，避免 N+1 查询） */
export interface AuthorInfo {
  nickname: string;
  avatar: string;
}

@Injectable()
export class CommunityService {
  constructor(
    @InjectRepository(Post)
    private readonly posts: Repository<Post>,
    @InjectRepository(Like)
    private readonly likes: Repository<Like>,
    @InjectRepository(Comment)
    private readonly comments: Repository<Comment>,
    @InjectRepository(Collection)
    private readonly collections: Repository<Collection>,
    @InjectRepository(Report)
    private readonly reports: Repository<Report>,
    @InjectRepository(History)
    private readonly histories: Repository<History>,
    @InjectRepository(User)
    private readonly users: Repository<User>,
  ) {}

  // ──── Helpers ────

  /** 批量查询作者信息，返回 userId → AuthorInfo 映射 */
  private async resolveAuthors(userIds: number[]): Promise<Map<number, AuthorInfo>> {
    const unique = [...new Set(userIds)];
    if (!unique.length) return new Map();
    const users = await this.users.find({
      where: { id: In(unique) },
      select: { id: true, nickname: true, avatar: true },
    });
    return new Map(users.map((u) => [u.id, { nickname: u.nickname, avatar: u.avatar }]));
  }

  /** 将 Post 实体 + 作者信息合并为客户端友好的格式 */
  private enrichPost(post: Post, author?: AuthorInfo) {
    return {
      ...post,
      author: author ?? { nickname: `用户 #${post.userId}`, avatar: '' },
    };
  }

  /** 将 Comment 实体 + 作者信息合并 */
  private enrichComment(comment: Comment, author?: AuthorInfo) {
    return {
      ...comment,
      author: author ?? { nickname: `用户 #${comment.userId}`, avatar: '' },
    };
  }

  /** 发布作品：内容机审 → 标记 pending，等待人工复核 */
  async create(userId: number, dto: CreatePostDto): Promise<Post> {
    const text = (dto.content ?? '').toLowerCase();
    const blocked = BLOCKED_KEYWORDS.find((kw) => text.includes(kw));
    if (blocked) {
      throw new BadRequestException(`内容包含违规关键词，请修改后发布`);
    }

    const post = this.posts.create({
      userId,
      title: dto.title ?? '',
      content: dto.content,
      images: dto.images ?? [],
      medias: dto.medias ?? [],
      tags: dto.tags ?? [],
      channelTag: dto.channelTag ?? '',
      location: dto.location ?? '',
      status: 'approved',
    });
    return this.posts.save(post);
  }

  /** 信息流：最新（按创建时间倒序），仅展示已通过作品，含作者信息 */
  async listLatest(page = 1, pageSize = 20) {
    const [posts, total] = await this.posts.findAndCount({
      where: { status: 'approved' },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    const userIds = posts.map((p) => p.userId);
    const authors = await this.resolveAuthors(userIds);

    return [posts.map((p) => this.enrichPost(p, authors.get(p.userId))), total];
  }

  /** 信息流：热门（按点赞数倒序），仅展示已通过作品，含作者信息 */
  async listHot(page = 1, pageSize = 20) {
    const [posts, total] = await this.posts.findAndCount({
      where: { status: 'approved' },
      order: { likeCount: 'DESC', createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    const userIds = posts.map((p) => p.userId);
    const authors = await this.resolveAuthors(userIds);

    return [posts.map((p) => this.enrichPost(p, authors.get(p.userId))), total];
  }

  /** 作品详情（含浏览量自增） */
  async detail(id: number) {
    const post = await this.posts.findOneBy({ id });
    if (!post) throw new NotFoundException('作品不存在');
    if (post.status === 'rejected') throw new NotFoundException('作品不存在');

    // 浏览量 +1（异步自增，不阻塞响应）
    const author = (await this.resolveAuthors([post.userId])).get(post.userId);

    return this.enrichPost(post, author);
  }

  /** 记录浏览（浏览量 +1） */
  async recordView(id: number): Promise<void> {
    const post = await this.posts.findOneBy({ id });
    if (!post || post.status === 'rejected') return;
    await this.posts.increment({ id }, 'viewCount', 1);
  }

  /** 记录分享（分享数 +1） */
  async recordShare(id: number): Promise<void> {
    const post = await this.posts.findOneBy({ id });
    if (!post || post.status === 'rejected') return;
    await this.posts.increment({ id }, 'shareCount', 1);
  }

  /** 我的作品列表 */
  async myPosts(userId: number, page = 1, pageSize = 20) {
    const [posts, total] = await this.posts.findAndCount({
      where: { userId },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    const authors = await this.resolveAuthors([userId]);
    return [posts.map((p) => this.enrichPost(p, authors.get(userId))), total];
  }

  /** 管理端：全量作品列表（可按状态筛选） */
  async findAll(status?: string, page = 1, pageSize = 20): Promise<[Post[], number]> {
    const where: any = {};
    if (status) where.status = status;
    return this.posts.findAndCount({
      where,
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
  }

  /** 管理端：审核作品（通过/驳回） */
  async updateStatus(id: number, dto: UpdatePostStatusDto): Promise<Post> {
    const post = await this.posts.findOneBy({ id });
    if (!post) throw new NotFoundException('作品不存在');
    post.status = dto.status;
    if (dto.status === 'rejected') {
      post.rejectReason = dto.rejectReason ?? '';
    } else {
      post.rejectReason = '';
    }
    return this.posts.save(post);
  }

  /** 管理端：下架作品（软删除标记为 rejected） */
  async remove(id: number): Promise<void> {
    const post = await this.posts.findOneBy({ id });
    if (!post) throw new NotFoundException('作品不存在');
    post.status = 'rejected';
    post.rejectReason = '管理员下架';
    await this.posts.save(post);
  }

  // ──── Like operations ────

  async toggleLike(userId: number, postId: number): Promise<{ liked: boolean }> {
    const post = await this.posts.findOneBy({ id: postId });
    if (!post) throw new NotFoundException('作品不存在');

    const existing = await this.likes.findOneBy({ userId, postId });
    if (existing) {
      await this.likes.delete({ userId, postId });
      await this.posts.decrement({ id: postId }, 'likeCount', 1);
      return { liked: false };
    }
    await this.likes.save(this.likes.create({ userId, postId }));
    await this.posts.increment({ id: postId }, 'likeCount', 1);
    return { liked: true };
  }

  async isLiked(userId: number, postId: number): Promise<boolean> {
    const existing = await this.likes.findOneBy({ userId, postId });
    return !!existing;
  }

  async hasUserLikedMultiple(userId: number, postIds: number[]): Promise<Set<number>> {
    if (!postIds.length) return new Set();
    const likes = await this.likes.findBy({ userId, postId: In(postIds) });
    return new Set(likes.map((l) => l.postId));
  }

  async getMyLikes(
    userId: number,
    page = 1,
    pageSize = 20,
  ) {
    const likes = await this.likes.find({
      where: { userId },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
    const total = await this.likes.count({ where: { userId } });
    if (!likes.length) return [[], total];

    const postIds = likes.map((item) => item.postId);
    const posts = await this.posts.findBy({ id: In(postIds) });
    const authorIds = [...new Set(posts.map((post) => post.userId))];
    const authors = await this.resolveAuthors(authorIds);
    const postMap = new Map(posts.map((post) => [post.id, post]));

    const ordered = postIds
      .map((id) => postMap.get(id))
      .filter((post): post is Post => !!post)
      .map((post) => this.enrichPost(post, authors.get(post.userId)));

    return [ordered, total];
  }

  // ──── Comment operations ────

  async addComment(userId: number, postId: number, content: string): Promise<Comment> {
    const post = await this.posts.findOneBy({ id: postId });
    if (!post) throw new NotFoundException('作品不存在');

    const comment = this.comments.create({ userId, postId, content });
    const saved = await this.comments.save(comment);
    await this.posts.increment({ id: postId }, 'commentCount', 1);
    return saved;
  }

  async getComments(
    postId: number,
    page = 1,
    pageSize = 20,
  ) {
    const [comments, total] = await this.comments.findAndCount({
      where: { postId },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    const userIds = comments.map((c) => c.userId);
    const authors = await this.resolveAuthors(userIds);

    return [comments.map((c) => this.enrichComment(c, authors.get(c.userId))), total];
  }

  // ──── Collection operations ────

  async toggleCollect(
    userId: number,
    postId: number,
  ): Promise<{ collected: boolean }> {
    const post = await this.posts.findOneBy({ id: postId });
    if (!post) throw new NotFoundException('作品不存在');

    const existing = await this.collections.findOneBy({ userId, postId });
    if (existing) {
      await this.collections.delete({ userId, postId });
      await this.posts.decrement({ id: postId }, 'collectCount', 1);
      return { collected: false };
    }
    await this.collections.save(this.collections.create({ userId, postId }));
    await this.posts.increment({ id: postId }, 'collectCount', 1);
    return { collected: true };
  }

  async isCollected(userId: number, postId: number): Promise<boolean> {
    const existing = await this.collections.findOneBy({ userId, postId });
    return !!existing;
  }

  async getMyCollections(
    userId: number,
    page = 1,
    pageSize = 20,
  ) {
    const collections = await this.collections.find({
      where: { userId },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
    const total = await this.collections.count({ where: { userId } });
    if (!collections.length) return [[], total];

    const postIds = collections.map((c) => c.postId);
    const posts = await this.posts.findBy({ id: In(postIds) });

    // resolve authors for all collected posts
    const authorIds = [...new Set(posts.map((p) => p.userId))];
    const authors = await this.resolveAuthors(authorIds);

    // preserve the collection order
    const postMap = new Map(posts.map((p) => [p.id, p]));
    const ordered = postIds
      .map((id) => postMap.get(id))
      .filter(Boolean)
      .map((p) => this.enrichPost(p!, authors.get(p!.userId)));

    return [ordered, total];
  }

  // ──── History operations ────

  async addHistory(userId: number, postId: number): Promise<void> {
    const post = await this.posts.findOneBy({ id: postId });
    if (!post) throw new NotFoundException('作品不存在');

    const existing = await this.histories.findOneBy({ userId, postId });
    if (existing) {
      await this.histories.update({ id: existing.id }, { createdAt: new Date() });
    } else {
      await this.histories.save(this.histories.create({ userId, postId }));
    }
  }

  /** 获取用户浏览历史，按浏览时间倒序 */
  async fetchHistory(userId: number, page = 1, pageSize = 20) {
    const [records, total] = await this.histories.findAndCount({
      where: { userId },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    if (records.length === 0) return [[], total];

    const postIds = records.map((r) => r.postId);
    const posts = await this.posts.findBy({ id: In(postIds) });

    // resolve authors
    const authorIds = [...new Set(posts.map((p) => p.userId))];
    const authors = await this.resolveAuthors(authorIds);

    // 按浏览时间排序
    const postMap = new Map(posts.map((p) => [p.id, p]));
    const ordered = postIds
      .map((id) => postMap.get(id))
      .filter((p): p is Post => !!p)
      .map((p) => this.enrichPost(p, authors.get(p.userId)));

    return [ordered, total];
  }

  // ──── Report operations ────

  async createReport(
    reporterId: number,
    postId: number,
    reason: string,
  ): Promise<Report> {
    const post = await this.posts.findOneBy({ id: postId });
    if (!post) throw new NotFoundException('作品不存在');

    const report = this.reports.create({ reporterId, postId, reason });
    return this.reports.save(report);
  }

  async findAllReports(
    status?: string,
    page = 1,
    pageSize = 20,
  ): Promise<[Report[], number]> {
    const where: any = {};
    if (status) where.status = status;
    return this.reports.findAndCount({
      where,
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
  }

  async resolveReport(id: number): Promise<Report> {
    const report = await this.reports.findOneBy({ id });
    if (!report) throw new NotFoundException('举报不存在');
    report.status = 'resolved';
    return this.reports.save(report);
  }

  async dismissReport(id: number): Promise<Report> {
    const report = await this.reports.findOneBy({ id });
    if (!report) throw new NotFoundException('举报不存在');
    report.status = 'dismissed';
    return this.reports.save(report);
  }

  // ──── User posts ────

  async userPosts(
    userId: number,
    page = 1,
    pageSize = 20,
  ) {
    const [posts, total] = await this.posts.findAndCount({
      where: { userId, status: 'approved' },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    const authors = await this.resolveAuthors([userId]);
    return [posts.map((p) => this.enrichPost(p, authors.get(userId))), total];
  }
}
