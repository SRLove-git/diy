import { PartialType } from '@nestjs/mapped-types';
import {
  IsBoolean,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';

export class SaveActivityDto {
  @IsString() @IsNotEmpty() title: string;
  @IsString() @IsNotEmpty() date: string;
  @IsOptional() @IsString() desc?: string;
  @IsOptional() @IsString() tag?: string;
  @IsOptional() @IsBoolean() membersOnly?: boolean;
  @IsOptional() @IsBoolean() enabled?: boolean;
  @IsOptional() @IsInt() @Min(0) sort?: number;
}

/** 部分更新：PATCH 时只校验传入的字段 */
export class UpdateActivityDto extends PartialType(SaveActivityDto) {}
