import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
} from 'typeorm';

/** 短视频评论 */
@Entity('video_comments')
@Index(['videoId'])
export class VideoComment {
  @PrimaryGeneratedColumn()
  id: number;

  /** 评论用户 */
  @Column()
  userId: number;

  /** 所属视频 */
  @Column()
  videoId: number;

  @Column({ type: 'text' })
  content: string;

  @CreateDateColumn()
  createdAt: Date;
}
