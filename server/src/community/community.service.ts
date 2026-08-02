import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Post } from './post.entity';
import { CreatePostDto, UpdatePostStatusDto } from './post.dto';

/** 简易敏感词列表（一期机审用） */
const BLOCKED_KEYWORDS = ['违禁', '色情', '赌博', '诈骗', '枪支', '毒品'];

@Injectable()
export class CommunityService {
  constructor(
    @InjectRepository(Post)
    private readonly posts: Repository<Post>,
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
}
