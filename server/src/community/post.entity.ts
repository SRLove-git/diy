import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

/** 作品状态：待审核 → 已通过/已驳回 */
export type PostStatus = 'pending' | 'approved' | 'rejected';

/** 社区作品 */
@Entity('posts')
@Index(['status'])
@Index(['userId'])
export class Post {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: number;

  /** 文案内容 */
  @Column({ type: 'text' })
  content: string;

  /** 图片 URL 列表（JSON 数组），最多 9 张 */
  @Column({ type: 'json' })
  images: string[];

  /** 标签列表（JSON 数组） */
  @Column({ type: 'json' })
  tags: string[];

  /** 审核状态 */
  @Column({
    type: 'enum',
    enum: ['pending', 'approved', 'rejected'],
    default: 'pending',
  })
  status: PostStatus;

  /** 驳回原因 */
  @Column({ length: 500, default: '' })
  rejectReason: string;

  /** 点赞数（计数器，免 join 统计） */
  @Column({ default: 0 })
  likeCount: number;

  /** 收藏数 */
  @Column({ default: 0 })
  collectCount: number;

  /** 评论数 */
  @Column({ default: 0 })
  commentCount: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
