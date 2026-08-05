import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersModule } from '../users/users.module';
import { ActivitiesController } from './activities.controller';
import { ActivitiesService } from './activities.service';
import { Activity } from './activity.entity';
import { AdminActivitiesController } from './admin-activities.controller';

/** 活动模块：活动专区 / 会员套餐页的数据源 */
@Module({
  imports: [TypeOrmModule.forFeature([Activity]), UsersModule],
  controllers: [ActivitiesController, AdminActivitiesController],
  providers: [ActivitiesService],
  exports: [ActivitiesService],
})
export class ActivitiesModule {}
