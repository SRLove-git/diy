import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('coupons')
export class Coupon {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 60 })
  title: string;

  @Column({ length: 20 })
  amount: string;

  @Column({ length: 60, default: '无门槛' })
  threshold: string;

  @Column({ type: 'datetime' })
  expireAt: Date;

  @Column({ default: 0 })
  stock: number;

  @Column({ default: true })
  membersOnly: boolean;

  @Column({ default: true })
  enabled: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

@Entity('user_coupons')
@Index(['userId', 'couponId'], { unique: true })
export class UserCoupon {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: number;

  @Column()
  couponId: number;

  @Column({
    type: 'enum',
    enum: ['unused', 'used', 'expired'],
    default: 'unused',
  })
  status: 'unused' | 'used' | 'expired';

  @Column({ type: 'datetime', nullable: true })
  usedAt: Date | null;

  @CreateDateColumn()
  receivedAt: Date;
}
