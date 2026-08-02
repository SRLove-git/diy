import {
  Column,
  CreateDateColumn,
  Entity,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
  ValueTransformer,
} from 'typeorm';
import { StoreTable } from './store-table.entity';
import { TimeSlot } from './time-slot.entity';

/** decimal 列返回 number（避免字符串） */
const decimal: ValueTransformer = {
  to: (v: number) => v,
  from: (v: string) => Number(v),
};

/** 门店 */
@Entity('stores')
export class Store {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 100 })
  name: string;

  @Column({ length: 255 })
  address: string;

  @Column({ type: 'decimal', precision: 10, scale: 7, transformer: decimal })
  lat: number;

  @Column({ type: 'decimal', precision: 10, scale: 7, transformer: decimal })
  lng: number;

  /** 评分 0-5 */
  @Column({ type: 'decimal', precision: 2, scale: 1, default: 5, transformer: decimal })
  rating: number;

  /** 门店图片（OSS URL 列表） */
  @Column({ type: 'json', nullable: true })
  images: string[] | null;

  @Column({ length: 50, default: '09:00-21:00' })
  businessHours: string;

  @Column({ length: 20, default: '' })
  phone: string;

  @Column({ default: true })
  enabled: boolean;

  @OneToMany(() => StoreTable, (t) => t.store)
  tables: StoreTable[];

  @OneToMany(() => TimeSlot, (t) => t.store)
  slots: TimeSlot[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
