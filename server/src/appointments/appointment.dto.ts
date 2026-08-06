import {
  IsInt,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  Min,
} from 'class-validator';

/** 创建预约：门店 + 日期 + 时段 + 人数 + 桌位 */
export class CreateAppointmentDto {
  @IsInt()
  storeId: number;

  @IsInt()
  tableId: number;

  @IsInt()
  slotId: number;

  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: '日期格式为 YYYY-MM-DD' })
  date: string;

  @IsInt()
  @Min(1, { message: '人数至少 1 人' })
  peopleCount: number;

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
