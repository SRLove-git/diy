import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
} from 'typeorm';

@Entity('messages')
@Index('idx_message_conversation', ['conversationId', 'id'])
export class Message {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  conversationId: number;

  @Column()
  senderId: number;

  /** 消息类型：text 文本/表情；image 图片；voice 语音（content 为 {url,duration} JSON） */
  @Column({ type: 'enum', enum: ['text', 'image', 'voice'], default: 'text' })
  contentType: 'text' | 'image' | 'voice';

  @Column({ type: 'text' })
  content: string;

  /** 对方已读时间；空 = 未读 */
  @Column({ type: 'datetime', nullable: true })
  readAt: Date | null;

  @CreateDateColumn()
  createdAt: Date;
}
