import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
} from 'typeorm';

@Entity('group_messages')
@Index('idx_group_message', ['groupId', 'id'])
export class GroupMessage {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  groupId: number;

  @Column()
  senderId: number;

  @Column({ type: 'enum', enum: ['text', 'image', 'voice'], default: 'text' })
  contentType: 'text' | 'image' | 'voice';

  @Column({ type: 'text' })
  content: string;

  @CreateDateColumn()
  createdAt: Date;
}
