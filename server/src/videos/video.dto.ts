import {
  IsArray,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min,
} from 'class-validator';

/** 发布短视频 */
export class CreateVideoDto {
  /** 标题 / 文案（信息流展示区显示） */
  @IsString()
  @MaxLength(200, { message: '标题不能超过 200 字' })
  @IsOptional()
  title?: string;

  /** 视频描述（发布页文案） */
  @IsString()
  @MaxLength(5000, { message: '文案不能超过 5000 字' })
  @IsOptional()
  content?: string;

  /** 封面 URL（可空：无封面时客户端展示占位图） */
  @IsString()
  @MaxLength(500)
  @IsOptional()
  cover?: string;

  /** 视频文件 URL */
  @IsString()
  @MaxLength(500)
  videoUrl: string;

  /** 视频时长（秒，缺省默认 15，客户端未解析出真实时长时用） */
  @IsInt()
  @Min(1, { message: '时长必须大于 0 秒' })
  @IsOptional()
  duration?: number;

  /** 配乐名称 */
  @IsString()
  @MaxLength(200)
  @IsOptional()
  music?: string;

  /** 话题标签列表 */
  @IsArray()
  @IsOptional()
  tags?: string[];

  /** 发布地点 */
  @IsString()
  @MaxLength(200)
  @IsOptional()
  location?: string;
}

/** 添加视频评论 */
export class CreateVideoCommentDto {
  @IsString()
  @MaxLength(500, { message: '评论不能超过 500 字' })
  content: string;
}
