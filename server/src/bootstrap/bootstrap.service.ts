import { Injectable, Logger, OnApplicationBootstrap } from '@nestjs/common';
import { UsersService } from '../users/users.service';

/** 启动初始化：开发环境预置管理员账号（手机号验证码登录即为 admin） */
@Injectable()
export class BootstrapService implements OnApplicationBootstrap {
  private readonly logger = new Logger(BootstrapService.name);
  private readonly ADMIN_PHONE = '13800000000';

  constructor(private readonly users: UsersService) {}

  async onApplicationBootstrap() {
    if (process.env.NODE_ENV === 'production') return;
    if (!(await this.users.findByPhone(this.ADMIN_PHONE))) {
      await this.users.create({
        phone: this.ADMIN_PHONE,
        role: 'admin',
        nickname: '管理员',
      });
      this.logger.log(`已创建开发管理员账号：${this.ADMIN_PHONE}（admin）`);
    }
  }
}
