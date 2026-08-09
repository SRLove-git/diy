import { Injectable, Logger } from '@nestjs/common';

/** 邮件发送抽象：生产接入 SMTP 邮件服务，开发用 DevEmailService 打印日志 */
export abstract class EmailService {
  abstract send(to: string, subject: string, content: string): Promise<void>;
}

@Injectable()
export class DevEmailService extends EmailService {
  private readonly logger = new Logger(DevEmailService.name);

  async send(to: string, subject: string, content: string) {
    // 开发环境验证码直接打印到服务端日志，便于本地联调
    this.logger.log(`[DevEmail] 发送至 ${to}：${subject} / ${content}`);
  }
}
