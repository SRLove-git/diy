import {
  Body,
  Controller,
  DefaultValuePipe,
  Delete,
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

  /** 用户列表（分页，可选用户名/邮箱/昵称搜索） */
  @Get()
  findAll(
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('search') search?: string,
  ) {
    return this.users.findAll(page, search);
  }

  /** 封禁/解封用户 */
  @Patch(':id/ban')
  ban(
    @Param('id', ParseIntPipe) id: number,
    @Body('isBanned') isBanned: boolean,
  ) {
    return this.users.toggleBan(id, isBanned);
  }

  /** 强制下线：立即使该用户现有会话失效，需重新登录 */
  @Patch(':id/offline')
  forceOffline(@Param('id', ParseIntPipe) id: number) {
    return this.users.forceOffline(id);
  }

  /** 删除用户全部作品（社区帖子 + 短视频/照片，含关联互动数据） */
  @Delete(':id/works')
  deleteWorks(@Param('id', ParseIntPipe) id: number) {
    return this.users.deleteWorks(id);
  }

  /** 删除用户（含作品、互动、关注、会员、预约、聊天等全部关联数据） */
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.users.remove(id);
  }
}
