import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

/** 预约单状态机：待核销 → 服务中 → 已完成；扫码核销即上钟。checked_in 为兼容状态（历史数据/管理端单独上钟） */
export type AppointmentStatus =
  'booked' | 'checked_in' | 'in_service' | 'completed' | 'cancelled';

/** 预约类型：门店桌位预约 / 活动场次预约 */
export type AppointmentType = 'store' | 'activity';

/** 门店预约方式：按小时（1 小时起）/ 时长套餐 / 全天不限时 */
export type BookingType = 'hourly' | 'package' | 'all_day';

/** 支付状态：预约时同步支付（演示支付），历史数据为 unpaid */
export type PayStatus = 'unpaid' | 'paid';

/** 预约单 */
@Entity('appointments')
@Index(['storeId', 'tableId', 'date']) // 防超卖：同店同桌同日期按时间段重叠校验
export class Appointment {
  @PrimaryGeneratedColumn()
  id: number;

  /** 预约类型 */
  @Column({
    type: 'enum',
    enum: ['store', 'activity'],
    default: 'store',
  })
  type: AppointmentType;

  /** 门店预约方式：hourly 按小时 / package 套餐 / all_day 全天不限时 */
  @Column({
    type: 'enum',
    enum: ['hourly', 'package', 'all_day'],
    default: 'hourly',
  })
  bookingType: BookingType;

  /** 预约时长（小时）：hourly/package 必填，all_day 为营业时长 */
  @Column({ type: 'int', nullable: true })
  durationHours: number | null;

  /** 套餐 ID（bookingType=package 时使用） */
  @Column({ type: 'int', nullable: true })
  packageId: number | null;

  /** 套餐名（冗余展示） */
  @Column({ length: 60, default: '' })
  packageName: string;

  @Column()
  userId: number;

  @Column({ type: 'int', nullable: true })
  storeId: number | null;

  /** 冗余门店名，列表免 join */
  @Column({ length: 100 })
  storeName: string;

  @Column({ type: 'int', nullable: true })
  tableId: number | null;

  /** 冗余桌位名 */
  @Column({ length: 50 })
  tableName: string;

  @Column({ type: 'int', nullable: true })
  slotId: number | null;

  /** 活动预约：活动 ID / 场次 ID / 活动名（冗余） */
  @Column({ type: 'int', nullable: true })
  activityId: number | null;

  @Column({ type: 'int', nullable: true })
  activitySessionId: number | null;

  @Column({ length: 100, default: '' })
  activityName: string;

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

  /** 应付金额（会员折扣后） */
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
  amount: number;

  /** 原价金额（会员折扣前） */
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
  originalAmount: number;

  /** 支付状态 */
  @Column({
    type: 'enum',
    enum: ['unpaid', 'paid'],
    default: 'unpaid',
  })
  payStatus: PayStatus;

  /** 支付方式：wechat / alipay */
  @Column({ length: 20, default: '' })
  payMethod: string;

  /** 支付时间 */
  @Column({ type: 'datetime', nullable: true })
  paidAt: Date | null;

  /** 使用的优惠券（用户卡包记录 ID） */
  @Column({ type: 'int', nullable: true })
  userCouponId: number | null;

  /** 优惠券名称（冗余展示） */
  @Column({ length: 60, default: '' })
  couponTitle: string;

  /** 优惠券抵扣金额 */
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
  couponDiscount: number;

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
