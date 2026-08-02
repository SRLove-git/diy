import { Controller, Get, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AdminGuard } from '../stores/admin.guard';
import { DashboardService } from './dashboard.service';

/** 管理端：数据看板（需 admin 角色） */
@Controller('admin/dashboard')
@UseGuards(JwtAuthGuard, AdminGuard)
export class AdminDashboardController {
  constructor(private readonly dashboard: DashboardService) {}

  @Get('overview')
  overview() {
    return this.dashboard.getOverview();
  }

  @Get('trends')
  trends() {
    return this.dashboard.getTrends();
  }
}
