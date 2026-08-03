import {
  IsBoolean,
  IsIn,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
  Min,
} from 'class-validator';

export class CreateConversationDto {
  @IsInt()
  @Min(1)
  peerUserId: number;
}

export class SendMessageDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(2000)
  content: string;

  /** 消息类型：text（文本/表情，默认）| image（content 为上传后的相对路径）| voice（content 为 {url,duration} JSON） */
  @IsOptional()
  @IsIn(['text', 'image', 'voice'])
  contentType?: 'text' | 'image' | 'voice';
}

export class PinConversationDto {
  @IsBoolean()
  pinned: boolean;
}
