import {
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';

/** 中国大陆手机号 */
export class SendCodeDto {
  @Matches(/^1[3-9]\d{9}$/, { message: '手机号格式不正确' })
  phone: string;
}

export class LoginDto extends SendCodeDto {
  @Matches(/^\d{6}$/, { message: '验证码为 6 位数字' })
  code: string;
}

/** 密码登录 */
export class PasswordLoginDto extends SendCodeDto {
  @IsString()
  @MinLength(6, { message: '密码至少 6 位' })
  @MaxLength(32, { message: '密码最多 32 位' })
  password: string;
}

/** 设置/重置密码（需短信验证码） */
export class SetPasswordDto extends PasswordLoginDto {
  @Matches(/^\d{6}$/, { message: '验证码为 6 位数字' })
  code: string;

  @IsOptional()
  @IsString()
  @MinLength(2, { message: '用户名至少 2 位' })
  @MaxLength(30, { message: '用户名最多 30 位' })
  username?: string;
}

/** 用户名 + 密码登录 */
export class UsernameLoginDto {
  @IsString()
  @MinLength(2, { message: '用户名至少 2 位' })
  @MaxLength(30, { message: '用户名最多 30 位' })
  username: string;

  @IsString()
  @MinLength(6, { message: '密码至少 6 位' })
  @MaxLength(32, { message: '密码最多 32 位' })
  password: string;
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
