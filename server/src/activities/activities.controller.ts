import { Controller, Get } from '@nestjs/common';
import { ActivitiesService } from './activities.service';

/** 客户端：活动专区 / 会员套餐页共用 */
@Controller('activities')
export class ActivitiesController {
  constructor(private readonly activities: ActivitiesService) {}

  @Get()
  list() {
    return this.activities.list();
  }
}
