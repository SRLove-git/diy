import { Transform } from 'class-transformer';
import {
  IsDateString,
  IsEmail,
  IsIn,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';

const trim = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim() : value;

const lowerTrim = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim().toLowerCase() : value;

/** 发送邮箱验证码 */
export class SendEmailCodeDto {
  @Transform(lowerTrim)
  @IsEmail({}, { message: '邮箱格式不正确' })
  email: string;
}

/** 注册：用户名 + 密码 + 邮箱绑定（需邮箱验证码） */
export class RegisterDto extends SendEmailCodeDto {
  @Transform(trim)
  @IsString()
  @MinLength(2, { message: '用户名至少 2 位' })
  @MaxLength(30, { message: '用户名最多 30 位' })
  @Matches(/^[a-zA-Z0-9_]+$/, {
    message: '用户名仅支持字母、数字和下划线',
  })
  username: string;

  @IsString()
  @MinLength(6, { message: '密码至少 6 位' })
  @MaxLength(32, { message: '密码最多 32 位' })
  password: string;

  @Matches(/^\d{6}$/, { message: '验证码为 6 位数字' })
  emailCode: string;
}

/** 用户名 / 邮箱 + 密码登录 */
export class LoginDto {
  @Transform(trim)
  @IsString()
  @MinLength(2, { message: '用户名或邮箱至少 2 位' })
  @MaxLength(255, { message: '用户名或邮箱过长' })
  account: string;

  @IsString()
  @MinLength(6, { message: '密码至少 6 位' })
  @MaxLength(32, { message: '密码最多 32 位' })
  password: string;
}

/** 忘记密码：邮箱验证码校验 + 写入新密码 */
export class ResetPasswordDto extends SendEmailCodeDto {
  @Matches(/^\d{6}$/, { message: '验证码为 6 位数字' })
  emailCode: string;

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

  /** 用户名：2-30 位字母/数字/下划线，用于用户名+密码登录 */
  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(30, { message: '用户名最多 30 位' })
  @Matches(/^[a-zA-Z0-9_]*$/, { message: '用户名仅支持字母、数字和下划线' })
  username?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  avatar?: string;

  @IsOptional()
  @IsString()
  @MaxLength(200, { message: '简介最长 200 个字符' })
  bio?: string;

  @IsOptional()
  @IsIn(['male', 'female', 'secret'], { message: '性别取值不合法' })
  gender?: 'male' | 'female' | 'secret';

  @IsOptional()
  @Transform(({ value }: { value: unknown }) =>
    typeof value === 'string'
      ? value.trim() === ''
        ? null
        : value.trim()
      : value,
  )
  @IsDateString({}, { message: '生日格式应为 YYYY-MM-DD' })
  birthday?: string;

  @IsOptional()
  @IsString()
  @MaxLength(60, { message: '所在地最长 60 个字符' })
  location?: string;
}
