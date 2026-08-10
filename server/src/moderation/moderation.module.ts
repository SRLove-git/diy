import { Module } from '@nestjs/common';
import { AdminModerationController } from './admin-moderation.controller';
import { ModerationService } from './moderation.service';

@Module({
  controllers: [AdminModerationController],
  providers: [ModerationService],
  exports: [ModerationService],
})
export class ModerationModule {}
