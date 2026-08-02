import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

/** 预约单状态机：待核销 → 已核销 → 服务中 → 已完成；待核销可取消 */
export type AppointmentStatus =
  | 'booked'
  | 'checked_in'
  | 'in_service'
  | 'completed'
  | 'cancelled';

/** 预约单 */
@Entity('appointments')
@Index(['storeId', 'tableId', 'date', 'slotId']) // 防超卖：同店同桌同日期同时段冲突校验
export class Appointment {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: number;

  @Column()
  storeId: number;

  /** 冗余门店名，列表免 join */
  @Column({ length: 100 })
  storeName: string;

  @Column()
  tableId: number;

  /** 冗余桌位名 */
  @Column({ length: 50 })
  tableName: string;

  @Column()
  slotId: number;

  /** 预约日期 YYYY-MM-DD */
  @Column({ length: 10 })
  date: string;

  /** 冗余时段起止，免 join */
  @Column({ length: 5 })
  startTime: string;

  @Column({ length: 5 })
  endTime: string;

  /** 预约人数 */
  @Column()
  peopleCount: number;

  /** 预约码：到店核销凭证（6 位数字） */
  @Column({ length: 10, unique: true })
  code: string;

  @Column({
    type: 'enum',
    enum: ['booked', 'checked_in', 'in_service', 'completed', 'cancelled'],
    default: 'booked',
  })
  status: AppointmentStatus;

  @Column({ length: 200, default: '' })
  note: string;

  /** 核销时间 */
  @Column({ type: 'datetime', nullable: true })
  checkInTime: Date | null;

  /** 上钟（开始服务）时间 */
  @Column({ type: 'datetime', nullable: true })
  serviceStartTime: Date | null;

  /** 下钟（结束服务）时间 */
  @Column({ type: 'datetime', nullable: true })
  serviceEndTime: Date | null;

  /** 核销人ID（门店店员代操作时记录） */
  @Column({ type: 'int', nullable: true })
  checkedInBy: number | null;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
