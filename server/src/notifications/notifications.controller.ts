import {
  Controller,
  DefaultValuePipe,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import type { AuthUser } from '../auth/current-user.decorator';
import { NotificationsService } from './notifications.service';

/** 客户端：我的通知（列表 / 未读数 / 已读） */
@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
  constructor(private readonly svc: NotificationsService) {}

  @Get()
  mine(
    @CurrentUser() user: AuthUser,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('pageSize', new DefaultValuePipe(20), ParseIntPipe)
    pageSize: number,
  ) {
    return this.svc.myNotifications(
      user.id,
      Math.max(1, page),
      Math.min(50, Math.max(1, pageSize)),
    );
  }

  @Get('unread-count')
  unreadCount(@CurrentUser() user: AuthUser) {
    return this.svc.unreadCount(user.id).then((count) => ({ count }));
  }

  @Post('read-all')
  readAll(@CurrentUser() user: AuthUser) {
    return this.svc.markAllRead(user.id);
  }

  @Post(':id/read')
  read(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.svc.markRead(user.id, id);
  }
}
