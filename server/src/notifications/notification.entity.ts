import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
} from 'typeorm';

export type NotificationTarget = 'all' | 'role' | 'user';

@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn()
  id: number;

  /** 标题 */
  @Column({ length: 200 })
  title: string;

  /** 正文内容 */
  @Column({ type: 'text' })
  content: string;

  /** 发送目标类型：all=全体 / role=按角色 / user=指定用户 */
  @Column({ type: 'enum', enum: ['all', 'role', 'user'], default: 'all' })
  targetType: NotificationTarget;

  /** 当 targetType=role 时指定角色 */
  @Column({ type: 'enum', enum: ['user', 'admin'], nullable: true })
  targetRole: 'user' | 'admin' | null;

  /** 当 targetType=user 时指定用户ID（逗号分隔） */
  @Column({ type: 'text', nullable: true })
  targetUserIds: string;

  /** 发送渠道：push=推送 / sms=短信 / email=邮件，多选用逗号分隔 */
  @Column({ default: 'push' })
  channels: string;

  /** 是否已发送 */
  @Column({ default: false })
  sent: boolean;

  /** 发送时间 */
  @Column({ type: 'datetime', nullable: true })
  sentAt: Date;

  @CreateDateColumn()
  createdAt: Date;
}
