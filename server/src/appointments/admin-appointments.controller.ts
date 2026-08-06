import {
  Controller,
  Get,
  DefaultValuePipe,
  Param,
  ParseIntPipe,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AdminGuard } from '../stores/admin.guard';
import { AppointmentsService } from './appointments.service';

/** 管理端：预约订单管理（需 admin 角色） */
@Controller('admin/appointments')
@UseGuards(JwtAuthGuard, AdminGuard)
export class AdminAppointmentsController {
  constructor(private readonly appointments: AppointmentsService) {}

  /** 所有预约列表（分页，可按状态/门店/日期筛选） */
  @Get()
  list(
    @Query('status') status?: string,
    @Query('storeId') storeId?: string,
    @Query('date') date?: string,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page?: number,
    @Query('limit', new DefaultValuePipe(20), ParseIntPipe) limit?: number,
  ) {
    return this.appointments.adminFindAll(
      { status, storeId, date },
      page,
      limit,
    );
  }

  /** 核销（店员代操作） */
  @Post(':id/checkin')
  checkIn(@Param('id', ParseIntPipe) id: number) {
    // 管理端核销暂按 ID 直接操作（店员身份通过 admin guard 验证）
    return this.appointments.adminCheckIn(id);
  }

  /** 取消预约（店员代操作） */
  @Post(':id/cancel')
  cancel(@Param('id', ParseIntPipe) id: number) {
    return this.appointments.adminCancel(id);
  }

  /** 上钟（店员代操作） */
  @Post(':id/clockin')
  clockIn(@Param('id', ParseIntPipe) id: number) {
    return this.appointments.adminClockIn(id);
  }

  /** 下钟（店员代操作） */
  @Post(':id/clockout')
  clockOut(@Param('id', ParseIntPipe) id: number) {
    return this.appointments.adminClockOut(id);
  }
}
