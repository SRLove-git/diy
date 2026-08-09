import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Store } from './store.entity';

/** 门店时长套餐（如 5 小时 / 6 小时）：按人计费，预约时选择 */
@Entity('store_packages')
export class StorePackage {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => Store, (s) => s.packages, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'storeId' })
  store: Store;

  @Column()
  storeId: number;

  /** 套餐名，如「5 小时套餐」 */
  @Column({ length: 50 })
  name: string;

  /** 套餐时长（小时） */
  @Column()
  hours: number;

  /** 套餐价（元/人） */
  @Column({
    type: 'decimal',
    precision: 10,
    scale: 2,
    default: 0,
    transformer: {
      to: (v: number) => v,
      from: (v: string) => Number(v),
    },
  })
  price: number;

  @Column({ default: true })
  enabled: boolean;

  @Column({ default: 0 })
  sortOrder: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
