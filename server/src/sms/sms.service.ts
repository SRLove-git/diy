import { Injectable, Logger } from '@nestjs/common';

/** 短信发送抽象：生产接入阿里云/腾讯云短信，开发用 DevSmsService 打印日志 */
export abstract class SmsService {
  abstract send(phone: string, content: string): Promise<void>;
}

@Injectable()
export class DevSmsService extends SmsService {
  private readonly logger = new Logger(DevSmsService.name);

  async send(phone: string, content: string) {
    // 开发环境验证码直接打印到服务端日志，便于本地联调
    this.logger.log(`[DevSMS] 发送至 ${phone}：${content}`);
  }
}
