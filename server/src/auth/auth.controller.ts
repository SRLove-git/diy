import { Body, Controller, Get, Ip, Post, UseGuards } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { AuthService } from './auth.service';
import {
  LoginDto,
  PasswordLoginDto,
  RefreshDto,
  SendCodeDto,
  SetPasswordDto,
  UsernameLoginDto,
} from './auth.dto';
import { CurrentUser } from './current-user.decorator';
import type { AuthUser } from './current-user.decorator';
import { JwtAuthGuard } from './jwt-auth.guard';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly auth: AuthService,
    private readonly users: UsersService,
  ) {}

  /** 发送短信验证码（防刷：60 秒/手机号） */
  @Post('sms-code')
  sendSmsCode(@Body() dto: SendCodeDto, @Ip() ip: string) {
    return this.auth.sendSmsCode(dto.phone, ip);
  }

  /** 验证码登录（未注册自动注册） */
  @Post('login')
  login(@Body() dto: LoginDto) {
    return this.auth.login(dto.phone, dto.code);
  }

  /** 密码登录（需先用验证码设置过密码） */
  @Post('password-login')
  passwordLogin(@Body() dto: PasswordLoginDto) {
    return this.auth.passwordLogin(dto.phone, dto.password);
  }

  /** 用户名 + 密码登录 */
  @Post('username-login')
  usernameLogin(@Body() dto: UsernameLoginDto) {
    return this.auth.usernameLogin(dto.username, dto.password);
  }

  /** 设置/重置密码（短信验证码校验） */
  @Post('set-password')
  setPassword(@Body() dto: SetPasswordDto) {
    return this.auth.setPassword(
      dto.phone,
      dto.code,
      dto.password,
      dto.username,
    );
  }

  /** 刷新令牌（轮换制） */
  @Post('refresh')
  refresh(@Body() dto: RefreshDto) {
    return this.auth.refresh(dto.refreshToken);
  }

  /** 当前登录用户 */
  @Get('me')
  @UseGuards(JwtAuthGuard)
  me(@CurrentUser() user: AuthUser) {
    return this.users.findById(user.id);
  }
}
