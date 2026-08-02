import {
  IsArray,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Matches,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';

export class CreateStoreDto {
  @IsString()
  @MaxLength(100)
  name: string;

  @IsString()
  @MaxLength(255)
  address: string;

  @IsNumber()
  @Min(-90)
  @Max(90)
  lat: number;

  @IsNumber()
  @Min(-180)
  @Max(180)
  lng: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(5)
  rating?: number;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  images?: string[];

  @IsOptional()
  @IsString()
  @MaxLength(50)
  businessHours?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  phone?: string;
}

export class UpdateStoreDto extends PartialType(CreateStoreDto) {}

export class CreateTableDto {
  @IsString()
  @MaxLength(50)
  name: string;

  @IsInt()
  @Min(1)
  capacity: number;

  @IsOptional()
  enabled?: boolean;
}

export class UpdateTableDto extends PartialType(CreateTableDto) {}

const TIME_RE = /^([01]\d|2[0-3]):[0-5]\d$/;

export class CreateSlotDto {
  @Matches(TIME_RE, { message: '开始时间格式为 HH:mm' })
  startTime: string;

  @Matches(TIME_RE, { message: '结束时间格式为 HH:mm' })
  endTime: string;

  @IsOptional()
  enabled?: boolean;
}

export class UpdateSlotDto extends PartialType(CreateSlotDto) {}
