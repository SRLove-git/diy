import { Module } from '@nestjs/common';
import { DevEmailService, EmailService } from './email.service';

@Module({
  providers: [{ provide: EmailService, useClass: DevEmailService }],
  exports: [EmailService],
})
export class EmailModule {}
