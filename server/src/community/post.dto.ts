import {
  IsArray,
  IsIn,
  IsOptional,
  IsString,
  ArrayMaxSize,
  MaxLength,
} from 'class-validator';

/** 发布作品 */
export class CreatePostDto {
  @IsString()
  @MaxLength(5000, { message: '文案不能超过 5000 字' })
  content: string;

  @IsArray()
  @ArrayMaxSize(9, { message: '最多上传 9 张图片' })
  images: string[];

  @IsArray()
  @IsOptional()
  tags: string[];
}

/** 审核作品：通过或驳回 */
export class UpdatePostStatusDto {
  @IsIn(['approved', 'rejected'], { message: '状态仅可为 approved 或 rejected' })
  status: 'approved' | 'rejected';

  @IsOptional()
  @IsString()
  @MaxLength(500)
  rejectReason?: string;
}
