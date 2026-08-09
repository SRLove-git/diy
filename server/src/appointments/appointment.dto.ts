import {
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  Min,
} from 'class-validator';

/** 创建预约：门店桌位 或 活动场次 + 人数 + 支付方式 */
export class CreateAppointmentDto {
  @IsOptional()
  @IsIn(['store', 'activity'])
  type?: 'store' | 'activity';

  /** 门店预约方式：hourly 按小时 / package 套餐 / all_day 全天不限时 */
  @IsOptional()
  @IsIn(['hourly', 'package', 'all_day'])
  bookingType?: 'hourly' | 'package' | 'all_day';

  /** 开始时间 HH:mm（hourly/package 必填，all_day 由营业时间决定） */
  @IsOptional()
  @Matches(/^([01]\d|2[0-3]):[0-5]\d$/, {
    message: '开始时间格式为 HH:mm',
  })
  startTime?: string;

  /** 预约时长（小时），hourly 必填且 ≥1 */
  @IsOptional()
  @IsInt()
  @Min(1)
  durationHours?: number;

  /** 套餐 ID（bookingType=package 时必填） */
  @IsOptional()
  @IsInt()
  packageId?: number;

  @IsOptional()
  @IsInt()
  storeId?: number;

  @IsOptional()
  @IsInt()
  tableId?: number;

  @IsOptional()
  @IsInt()
  slotId?: number;

  @IsOptional()
  @IsInt()
  activityId?: number;

  @IsOptional()
  @IsInt()
  activitySessionId?: number;

  @IsOptional()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: '日期格式为 YYYY-MM-DD' })
  date?: string;

  @IsInt()
  @Min(1, { message: '人数至少 1 人' })
  peopleCount: number;

  @IsOptional()
  @IsIn(['wechat', 'alipay'], { message: '支付方式仅支持微信/支付宝' })
  payMethod?: 'wechat' | 'alipay';

  @IsOptional()
  @IsString()
  @MaxLength(200)
  note?: string;

  /** 使用的优惠券（用户卡包记录 ID，可空表示不使用） */
  @IsOptional()
  @IsInt()
  userCouponId?: number;
}

/** 输码核销 */
export class CheckInDto {
  /** 6 位预约码 */
  @Matches(/^\d{6}$/, { message: '预约码为 6 位数字' })
  code: string;
}
