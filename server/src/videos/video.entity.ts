import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

/** 短视频审核状态 */
export type VideoStatus = 'pending' | 'approved' | 'rejected';

/** 短视频（TikTok 风格信息流单条） */
@Entity('videos')
@Index(['status'])
@Index(['userId'])
export class Video {
  @PrimaryGeneratedColumn()
  id: number;

  /** 作者用户 ID */
  @Column()
  userId: number;

  /** 标题 / 文案（信息流展示区显示） */
  @Column({ length: 200, default: '' })
  title: string;

  /** 视频描述（发布页文案） */
  @Column({ type: 'text', nullable: true })
  content: string;

  /** 封面 URL（本地模式为相对路径 /uploads/...） */
  @Column({ length: 500, default: '' })
  cover: string;

  /** 视频文件 URL */
  @Column({ length: 500, default: '' })
  videoUrl: string;

  /** 视频时长（秒） */
  @Column({ default: 0 })
  duration: number;

  /** 配乐名称 */
  @Column({ length: 200, default: '' })
  music: string;

  /** 话题标签列表（JSON 数组） */
  @Column({ type: 'json' })
  tags: string[];

  /** 发布地点 */
  @Column({ length: 200, default: '' })
  location: string;

  /** 审核状态：默认通过（与社区作品一致，机审后直接上架） */
  @Column({
    type: 'enum',
    enum: ['pending', 'approved', 'rejected'],
    default: 'approved',
  })
  status: VideoStatus;

  /** 驳回原因 */
  @Column({ length: 500, default: '' })
  rejectReason: string;

  /** 点赞数（计数器，免 join 统计） */
  @Column({ default: 0 })
  likeCount: number;

  /** 评论数 */
  @Column({ default: 0 })
  commentCount: number;

  /** 分享数 */
  @Column({ default: 0 })
  shareCount: number;

  /** 浏览数 */
  @Column({ default: 0 })
  viewCount: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
