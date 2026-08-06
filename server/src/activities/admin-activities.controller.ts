import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AdminGuard } from '../stores/admin.guard';
import { SaveActivityDto, UpdateActivityDto } from './activity.dto';
import { ActivitiesService } from './activities.service';

/** 管理端：活动管理 */
@Controller('admin/activities')
@UseGuards(JwtAuthGuard, AdminGuard)
export class AdminActivitiesController {
  constructor(private readonly activities: ActivitiesService) {}

  @Get() list() {
    return this.activities.listAll();
  }

  @Post() create(@Body() dto: SaveActivityDto) {
    return this.activities.create(dto);
  }

  @Patch(':id') update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateActivityDto,
  ) {
    return this.activities.update(id, dto);
  }

  @Patch(':id/enabled') toggle(
    @Param('id', ParseIntPipe) id: number,
    @Body('enabled') enabled: boolean,
  ) {
    return this.activities.toggleEnabled(id, enabled);
  }
}
