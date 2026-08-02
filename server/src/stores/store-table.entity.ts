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

/** 门店桌位（工位/操作台）：预约时按人数选择 */
@Entity('store_tables')
export class StoreTable {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => Store, (s) => s.tables, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'storeId' })
  store: Store;

  @Column()
  storeId: number;

  /** 桌位名，如 A1 / B2 */
  @Column({ length: 50 })
  name: string;

  /** 可容纳人数上限 */
  @Column()
  capacity: number;

  @Column({ default: true })
  enabled: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
