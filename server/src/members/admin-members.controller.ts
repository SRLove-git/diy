import {
  Body,
  Controller,
  DefaultValuePipe,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AdminGuard } from '../stores/admin.guard';
import { SaveCouponDto, SavePlanDto } from './member.dto';
import { MembersService } from './members.service';

@Controller('admin/members')
@UseGuards(JwtAuthGuard, AdminGuard)
export class AdminMembersController {
  constructor(private readonly members: MembersService) {}
  @Get() memberships(
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
  ) {
    return this.members.listMemberships(page);
  }
  @Get('plans') plans() {
    return this.members.listPlans(true);
  }
  @Post('plans') createPlan(@Body() dto: SavePlanDto) {
    return this.members.savePlan(dto);
  }
  @Patch('plans/:id') updatePlan(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: SavePlanDto,
  ) {
    return this.members.savePlan(dto, id);
  }
  @Patch('plans/:id/enabled') togglePlan(
    @Param('id', ParseIntPipe) id: number,
    @Body('enabled') enabled: boolean,
  ) {
    return this.members.togglePlan(id, enabled);
  }
  @Get('coupons') coupons() {
    return this.members.listAllCoupons();
  }
  @Post('coupons') createCoupon(@Body() dto: SaveCouponDto) {
    return this.members.saveCoupon(dto);
  }
  @Patch('coupons/:id') updateCoupon(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: SaveCouponDto,
  ) {
    return this.members.saveCoupon(dto, id);
  }
  @Patch('coupons/:id/enabled') toggleCoupon(
    @Param('id', ParseIntPipe) id: number,
    @Body('enabled') enabled: boolean,
  ) {
    return this.members.toggleCoupon(id, enabled);
  }
}
