import { IsOptional, IsString, Matches, MaxLength } from 'class-validator';

/** 中国大陆手机号 */
export class SendCodeDto {
  @Matches(/^1[3-9]\d{9}$/, { message: '手机号格式不正确' })
  phone: string;
}

export class LoginDto extends SendCodeDto {
  @Matches(/^\d{6}$/, { message: '验证码为 6 位数字' })
  code: string;
}

export class RefreshDto {
  @IsString()
  refreshToken: string;
}

export class UpdateProfileDto {
  @IsOptional()
  @IsString()
  @MaxLength(30, { message: '昵称最长 30 个字符' })
  nickname?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  avatar?: string;
}
