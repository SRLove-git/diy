import { Module } from '@nestjs/common';
import { UsersModule } from '../users/users.module';
import { AdminGuard } from '../stores/admin.guard';
import { AdminModerationController } from './admin-moderation.controller';
import { ModerationService } from './moderation.service';

@Module({
  imports: [UsersModule],
  controllers: [AdminModerationController],
  providers: [ModerationService, AdminGuard],
  exports: [ModerationService],
})
export class ModerationModule {}
