import {
  ArrayNotEmpty,
  IsArray,
  IsIn,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
  Min,
} from 'class-validator';

export class CreateGroupDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(30)
  name: string;

  /** 群成员用户 ID（不含创建者本人） */
  @IsArray()
  @ArrayNotEmpty()
  @IsInt({ each: true })
  @Min(1, { each: true })
  memberIds: number[];
}

export class SendGroupMessageDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(2000)
  content: string;

  @IsOptional()
  @IsIn(['text', 'image', 'voice'])
  contentType?: 'text' | 'image' | 'voice';
}

export class MarkGroupReadDto {
  @IsInt()
  @Min(0)
  lastMessageId: number;
}
