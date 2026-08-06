import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

export type ReportStatus = 'pending' | 'resolved' | 'dismissed';
export type ReportTargetType = 'post' | 'video';

@Entity('post_reports')
export class Report {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  reporterId: number;

  @Column()
  postId: number;

  /** 举报对象类型：post 社区帖子 / video 短视频（默认 post，兼容存量数据） */
  @Column({
    type: 'enum',
    enum: ['post', 'video'],
    default: 'post',
  })
  targetType: ReportTargetType;

  /** 被举报短视频 ID（targetType = video 时必填） */
  @Column({ type: 'int', nullable: true })
  videoId: number | null;

  @Column({ type: 'text' })
  reason: string;

  @Column({
    type: 'enum',
    enum: ['pending', 'resolved', 'dismissed'],
    default: 'pending',
  })
  status: ReportStatus;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
