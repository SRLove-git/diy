import {
  Body,
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
import { AdminGuard } from '../stores/admin.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import type { AuthUser } from '../auth/current-user.decorator';
import { CommunityService } from './community.service';
import { CreateReportDto } from './report.dto';

/** 管理端：举报管理 */
@Controller('admin/reports')
@UseGuards(JwtAuthGuard, AdminGuard)
export class AdminReportsController {
  constructor(private readonly community: CommunityService) {}

  /** 列表举报（可按状态筛选） */
  @Get()
  findAll(
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('status') status?: string,
  ) {
    return this.community.findAllReports(status, page);
  }

  /** 举报作品 */
  @Post()
  createReport(@CurrentUser() user: AuthUser, @Body() dto: CreateReportDto) {
    return this.community.createReport(user.id, dto.reason, {
      postId: dto.postId,
    });
  }

  /** 受理举报 */
  @Post(':id/resolve')
  resolve(@Param('id', ParseIntPipe) id: number) {
    return this.community.resolveReport(id);
  }

  /** 驳回举报 */
  @Post(':id/dismiss')
  dismiss(@Param('id', ParseIntPipe) id: number) {
    return this.community.dismissReport(id);
  }
}
