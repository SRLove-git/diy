import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from '../users/user.entity';
import { UsersModule } from '../users/users.module';
import { AdminNotificationsController } from './admin-notifications.controller';
import { NotificationsController } from './notifications.controller';
import { NotificationRead } from './notification-read.entity';
import { NotificationTemplate } from './notification-template.entity';
import { Notification } from './notification.entity';
import { NotificationsService } from './notifications.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Notification,
      NotificationTemplate,
      NotificationRead,
      User,
    ]),
    UsersModule,
  ],
  controllers: [AdminNotificationsController, NotificationsController],
  providers: [NotificationsService],
  exports: [NotificationsService],
})
export class NotificationsModule {}
