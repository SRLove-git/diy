import { IsNumber, IsString, MaxLength } from 'class-validator';

export class CreateReportDto {
  @IsString()
  @MaxLength(500, { message: '举报原因不能超过 500 字' })
  reason: string;

  @IsNumber()
  postId: number;
}
