import {
  IsInt,
  IsIn,
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
}

/** 输码核销 */
export class CheckInDto {
  /** 6 位预约码 */
  @Matches(/^\d{6}$/, { message: '预约码为 6 位数字' })
  code: string;
}
