import { Module } from '@nestjs/common';
import { DevSmsService, SmsService } from './sms.service';

@Module({
  providers: [{ provide: SmsService, useClass: DevSmsService }],
  exports: [SmsService],
})
export class SmsModule {}
