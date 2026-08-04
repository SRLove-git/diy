import { Body, Controller, Get, Param, ParseIntPipe, Post, UseGuards } from '@nestjs/common';
import { CurrentUser } from '../auth/current-user.decorator';
import type { AuthUser } from '../auth/current-user.decorator';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { MembersService } from './members.service';

@Controller('members')
@UseGuards(JwtAuthGuard)
export class MembersController {
  constructor(private readonly members: MembersService) {}
  @Get('me') me(@CurrentUser() user: AuthUser) { return this.members.myMembership(user.id); }
  @Get('plans') plans() { return this.members.listPlans(); }
  @Post('purchase') purchase(@CurrentUser() user: AuthUser, @Body('planId', ParseIntPipe) planId: number) { return this.members.purchase(user.id, planId); }
  @Get('coupons') coupons(@CurrentUser() user: AuthUser) { return this.members.listCoupons(user.id); }
  @Post('coupons/:id/receive') receive(@CurrentUser() user: AuthUser, @Param('id', ParseIntPipe) id: number) { return this.members.receive(user.id, id); }
  @Get('wallet') wallet(@CurrentUser() user: AuthUser) { return this.members.wallet(user.id); }
}
