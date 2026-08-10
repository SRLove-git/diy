import { Body, Controller, Get, Ip, Post, UseGuards } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { AuthService } from './auth.service';
import {
  ChangePasswordDto,
  LoginDto,
  RefreshDto,
  RegisterDto,
  ResetPasswordDto,
  SendEmailCodeDto,
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

  /** 发送邮箱验证码（防刷：60 秒/邮箱，每小时/IP 上限） */
  @Post('email-code')
  sendEmailCode(@Body() dto: SendEmailCodeDto, @Ip() ip: string) {
    return this.auth.sendEmailCode(dto.email, ip);
  }

  /** 注册：用户名 + 密码 + 邮箱绑定（需邮箱验证码） */
  @Post('register')
  register(@Body() dto: RegisterDto) {
    return this.auth.register(dto);
  }

  /** 用户名 / 邮箱 + 密码登录 */
  @Post('login')
  login(@Body() dto: LoginDto) {
    return this.auth.login(dto.account, dto.password);
  }

  /** 忘记密码：邮箱验证码校验 + 写入新密码 */
  @Post('reset-password')
  resetPassword(@Body() dto: ResetPasswordDto) {
    return this.auth.resetPassword(dto.email, dto.emailCode, dto.password);
  }

  /** 修改登录密码（登录态下）：原密码 + 新密码 */
  @Post('change-password')
  @UseGuards(JwtAuthGuard)
  changePassword(@CurrentUser() user: AuthUser, @Body() dto: ChangePasswordDto) {
    return this.auth.changePassword(user.id, dto.oldPassword, dto.newPassword);
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
