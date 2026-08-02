import {
  Body,
  Controller,
  DefaultValuePipe,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AdminGuard } from '../stores/admin.guard';
import { UsersService } from './users.service';

/** 管理端：用户管理 */
@Controller('admin/users')
@UseGuards(JwtAuthGuard, AdminGuard)
export class AdminUsersController {
  constructor(private readonly users: UsersService) {}

  /** 用户列表（分页，可选手机号搜索） */
  @Get()
  findAll(
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('phone') phone?: string,
  ) {
    return this.users.findAll(page, phone);
  }

  /** 封禁/解封用户 */
  @Patch(':id/ban')
  ban(
    @Param('id', ParseIntPipe) id: number,
    @Body('isBanned') isBanned: boolean,
  ) {
    return this.users.toggleBan(id, isBanned);
  }
}
