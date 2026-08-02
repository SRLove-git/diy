import {
  BadRequestException,
  ForbiddenException,
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
import { CreatePostDto, UpdatePostStatusDto } from './post.dto';

/** 简易敏感词列表（一期机审用） */
const BLOCKED_KEYWORDS = ['违禁', '色情', '赌博', '诈骗', '枪支', '毒品'];

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
  ) {}

  /** 发布作品：内容机审 → 标记 pending，等待人工复核 */
  async create(userId: number, dto: CreatePostDto): Promise<Post> {
    // 简易内容机审：检查敏感词
    const text = (dto.content ?? '').toLowerCase();
    const blocked = BLOCKED_KEYWORDS.find((kw) => text.includes(kw));
    if (blocked) {
      throw new BadRequestException(`内容包含违规关键词，请修改后发布`);
    }

    const post = this.posts.create({
      userId,
      content: dto.content,
      images: dto.images,
      tags: dto.tags ?? [],
      status: 'pending', // 所有作品机审后仍需人工复核
    });
    return this.posts.save(post);
  }

  /** 信息流：最新（按创建时间倒序），仅展示已通过作品 */
  async listLatest(page = 1, pageSize = 20): Promise<[Post[], number]> {
    return this.posts.findAndCount({
      where: { status: 'approved' },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
  }

  /** 信息流：热门（按点赞数倒序），仅展示已通过作品 */
  async listHot(page = 1, pageSize = 20): Promise<[Post[], number]> {
    return this.posts.findAndCount({
      where: { status: 'approved' },
      order: { likeCount: 'DESC', createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
  }

  /** 作品详情 */
  async detail(id: number): Promise<Post> {
    const post = await this.posts.findOneBy({ id });
    if (!post) throw new NotFoundException('作品不存在');
    if (post.status === 'rejected') throw new NotFoundException('作品不存在');
    return post;
  }

  /** 我的作品列表 */
  async myPosts(userId: number, page = 1, pageSize = 20): Promise<[Post[], number]> {
    return this.posts.findAndCount({
      where: { userId },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
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
  ): Promise<[Comment[], number]> {
    return this.comments.findAndCount({
      where: { postId },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
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
  ): Promise<[Post[], number]> {
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
    // preserve the collection order
    const postMap = new Map(posts.map((p) => [p.id, p]));
    const ordered = postIds.map((id) => postMap.get(id)).filter(Boolean) as Post[];
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
  ): Promise<[Post[], number]> {
    return this.posts.findAndCount({
      where: { userId, status: 'approved' },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
  }
}
