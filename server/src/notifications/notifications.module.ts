import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from '../users/user.entity';
import { UsersModule } from '../users/users.module';
import { AdminNotificationsController } from './admin-notifications.controller';
import { NotificationTemplate } from './notification-template.entity';
import { Notification } from './notification.entity';
import { NotificationsService } from './notifications.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([Notification, NotificationTemplate, User]),
    UsersModule,
  ],
  controllers: [AdminNotificationsController],
  providers: [NotificationsService],
  exports: [NotificationsService],
})
export class NotificationsModule {}
