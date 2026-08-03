import {
  IsBoolean,
  IsInt,
  IsNotEmpty,
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
}

export class PinConversationDto {
  @IsBoolean()
  pinned: boolean;
}
