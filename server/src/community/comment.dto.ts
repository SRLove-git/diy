import { IsString, MaxLength } from 'class-validator';

export class CreateCommentDto {
  @IsString()
  @MaxLength(500, { message: '评论不能超过 500 字' })
  content: string;
}
