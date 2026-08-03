import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  /** 手机号：账号主键（对齐方案书 §4.2，微信登录二期绑定） */
  @Column({ unique: true, length: 20 })
  phone: string;

  @Column({ default: '' })
  nickname: string;

  /** 头像地址（OSS），空串表示未设置 */
  @Column({ default: '' })
  avatar: string;

  /** 密码哈希（scrypt），格式 scrypt$<salt>:<hash> 共 168 字符；null 表示未设置密码 */
  @Column({ type: 'varchar', length: 255, nullable: true })
  passwordHash: string | null;

  @Column({ default: false })
  isBanned: boolean;

  /** 角色：admin 可访问管理端接口 */
  @Column({ type: 'enum', enum: ['user', 'admin'], default: 'user' })
  role: 'user' | 'admin';

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
