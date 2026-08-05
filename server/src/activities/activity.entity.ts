import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';

/** 活动：活动专区 / 会员套餐页展示的活动数据源 */
@Entity('activities')
export class Activity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 60 })
  title: string;

  /** 展示时间文案，如 `08-16 14:00` / `08-22 起` */
  @Column({ length: 40 })
  date: string;

  @Column({ length: 200, default: '' })
  desc: string;

  /** 标签，如 `限会员` / `双倍积分` */
  @Column({ length: 20, default: '' })
  tag: string;

  @Column({ default: false })
  membersOnly: boolean;

  @Column({ default: true })
  enabled: boolean;

  /** 排序权重，越小越靠前 */
  @Column({ default: 0 })
  sort: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
