import {
  IsArray,
  IsBoolean,
  IsInt,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';

export class SavePlanDto {
  @IsString() @IsNotEmpty() name: string;
  @IsInt() @Min(1) durationDays: number;
  @IsNumber() @Min(0) price: number;
  @IsNumber() @Min(0) originalPrice: number;
  @IsArray() @IsString({ each: true }) benefits: string[];
  @IsOptional() @IsString() badge?: string;
  @IsOptional() @IsBoolean() recommended?: boolean;
  @IsOptional() @IsBoolean() enabled?: boolean;
}

export class SaveCouponDto {
  @IsString() @IsNotEmpty() title: string;
  @IsString() @IsNotEmpty() amount: string;
  @IsString() @IsNotEmpty() threshold: string;
  @IsString() @IsNotEmpty() expireAt: string;
  @IsInt() @Min(0) stock: number;
  @IsOptional() @IsBoolean() membersOnly?: boolean;
  @IsOptional() @IsBoolean() enabled?: boolean;
}
