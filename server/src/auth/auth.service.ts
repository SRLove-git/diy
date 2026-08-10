import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Inject,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService, type JwtSignOptions } from '@nestjs/jwt';
import { randomUUID } from 'crypto';
import type Redis from 'ioredis';
import { EmailService } from '../email/email.service';
import { REDIS_CLIENT } from '../redis/redis.module';
import { UsersService } from '../users/users.service';
import { hashPassword, verifyPassword } from './password.util';
import { kickKey } from './session-keys';

export interface JwtPayload {
  sub: number;
  type: 'access' | 'refresh';
  jti?: string;
}

const EMAIL_CODE_TTL = 300; // 验证码 5 分钟有效
const EMAIL_LIMIT_TTL = 60; // 同一邮箱 60 秒限发一次
const EMAIL_IP_LIMIT_TTL = 3600; // 同一 IP 每小时限发次数窗口
const EMAIL_IP_LIMIT_MAX = 10; // 同一 IP 每小时最多发送 10 条
const REFRESH_TTL = 30 * 24 * 3600; // 刷新令牌 30 天
const MAX_ATTEMPTS = 5; // 验证码 10 分钟内最多尝试 5 次
const PASSWORD_ATTEMPT_MAX = 5; // 密码登录 10 分钟内最多失败 5 次
const PASSWORD_LOCK_TTL = 600; // 连续失败后锁定 10 分钟

@Injectable()
export class AuthService {
  constructor(
    @Inject(REDIS_CLIENT) private readonly redis: Redis,
    private readonly users: UsersService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
    private readonly email: EmailService,
  ) {}

  /** 发送邮箱验证码（含防刷：60 秒/邮箱 + 每小时/IP 上限） */
  async sendEmailCode(email: string, ip?: string) {
    const normalized = email.trim().toLowerCase();
    // 先做 IP 维度限流（有则计次），再锁邮箱，避免被批量刷号
    if (ip) {
      const ipKey = `email:limit-ip:${ip}`;
      const ipCount = await this.redis.incr(ipKey);
      if (ipCount === 1) await this.redis.expire(ipKey, EMAIL_IP_LIMIT_TTL);
      if (ipCount > EMAIL_IP_LIMIT_MAX) {
        throw new BadRequestException('发送过于频繁，请稍后再试');
      }
    }
    const locked = await this.redis.set(
      `email:limit:${normalized}`,
      '1',
      'EX',
      EMAIL_LIMIT_TTL,
      'NX',
    );
    if (!locked) throw new BadRequestException('发送过于频繁，请 60 秒后再试');

    const code = String(Math.floor(100000 + Math.random() * 900000));
    await this.redis.set(
      `email:code:${normalized}`,
      code,
      'EX',
      EMAIL_CODE_TTL,
    );
    await this.email.send(
      normalized,
      '【DIY手作工坊】邮箱验证码',
      `您的验证码是 ${code}，5 分钟内有效。请勿泄露给他人。`,
    );

    // 开发环境：返回验证码便于联调，生产环境不返回
    const isDev = this.config.get<string>('NODE_ENV') !== 'production';
    return isDev ? { sent: true, code } : { sent: true };
  }

  /** 注册：用户名 + 密码 + 邮箱绑定（邮箱验证码校验通过后建号并自动登录） */
  async register(dto: {
    username: string;
    email: string;
    password: string;
    emailCode: string;
  }) {
    const username = dto.username.trim();
    const email = dto.email.trim().toLowerCase();
    await this.verifyEmailCode(email, dto.emailCode);

    if (await this.users.findByUsername(username)) {
      throw new ConflictException('用户名已被占用');
    }
    if (await this.users.findByEmail(email)) {
      throw new ConflictException('该邮箱已注册');
    }

    const user = await this.users.create({
      username,
      email,
      passwordHash: await hashPassword(dto.password),
      nickname: username,
    });
    const tokens = await this.signTokens(user.id);
    return { userId: user.id, isNewUser: true, ...tokens };
  }

  /** 用户名 / 邮箱 + 密码登录 */
  async login(account: string, password: string) {
    const normalized = account.trim();
    const lockKey = `acct:${normalized.toLowerCase()}`;
    await this.checkLoginLock(lockKey);
    const user = await this.users.findByUsernameOrEmail(normalized);
    if (!user || !user.passwordHash) {
      await this.recordLoginFailure(lockKey);
      throw new UnauthorizedException('用户名或密码错误');
    }
    if (!(await verifyPassword(password, user.passwordHash))) {
      await this.recordLoginFailure(lockKey);
      throw new UnauthorizedException('用户名或密码错误');
    }
    await this.clearLoginFailures(lockKey);
    if (user.isBanned) throw new ForbiddenException('账号已被禁用');
    // 强制下线/封禁的旧会话标记随重新登录清除
    await this.redis.del(kickKey(user.id));

    const tokens = await this.signTokens(user.id);
    return { userId: user.id, ...tokens };
  }

  /** 忘记密码：邮箱验证码校验通过后写入新密码 */
  async resetPassword(email: string, code: string, password: string) {
    const normalized = email.trim().toLowerCase();
    await this.verifyEmailCode(normalized, code);
    const user = await this.users.findByEmail(normalized);
    if (!user) {
      throw new BadRequestException('该邮箱未注册，请先注册账号');
    }
    if (user.isBanned) throw new ForbiddenException('账号已被禁用');
    await this.users.setPasswordHash(user.id, await hashPassword(password));
    return { sent: true };
  }

  /** 修改登录密码（登录态下）：校验原密码后写入新密码 */
  async changePassword(
    userId: number,
    oldPassword: string | undefined,
    newPassword: string,
  ) {
    const user = await this.users.findById(userId);
    if (!user) throw new NotFoundException('用户不存在');
    if (user.isBanned) throw new ForbiddenException('账号已被禁用');
    if (user.passwordHash) {
      if (!oldPassword) {
        throw new BadRequestException('请输入原密码');
      }
      if (!(await verifyPassword(oldPassword, user.passwordHash))) {
        throw new BadRequestException('原密码不正确');
      }
    }
    await this.users.setPasswordHash(user.id, await hashPassword(newPassword));
    return { sent: true };
  }

  /** 密码登录锁检查：锁定期间直接拒绝 */
  private async checkLoginLock(key: string) {
    if (await this.redis.exists(`login:lock:${key}`)) {
      throw new UnauthorizedException('尝试次数过多，请 10 分钟后再试');
    }
  }

  /** 记录一次密码登录失败，连续失败达到上限后锁定 */
  private async recordLoginFailure(key: string) {
    const attemptKey = `login:attempt:${key}`;
    const attempts = await this.redis.incr(attemptKey);
    if (attempts === 1) await this.redis.expire(attemptKey, 600);
    if (attempts >= PASSWORD_ATTEMPT_MAX) {
      await this.redis.set(`login:lock:${key}`, '1', 'EX', PASSWORD_LOCK_TTL);
      await this.redis.del(attemptKey);
      throw new UnauthorizedException('尝试次数过多，请 10 分钟后再试');
    }
  }

  /** 登录成功后清除失败计数与锁定 */
  private async clearLoginFailures(key: string) {
    await this.redis.del(`login:attempt:${key}`, `login:lock:${key}`);
  }

  /** 校验邮箱验证码（含防爆破），校验成功后验证码即焚 */
  private async verifyEmailCode(email: string, code: string) {
    const attemptKey = `email:attempt:${email}`;
    const attempts = await this.redis.incr(attemptKey);
    if (attempts === 1) await this.redis.expire(attemptKey, 600);
    if (attempts > MAX_ATTEMPTS)
      throw new BadRequestException('尝试次数过多，请稍后再试');

    const saved = await this.redis.get(`email:code:${email}`);
    if (!saved || saved !== code) {
      throw new BadRequestException('验证码错误或已过期');
    }

    // 一次性验证码，用后即焚
    await this.redis.del(`email:code:${email}`, attemptKey);
  }

  /** 刷新令牌（轮换制：旧 refresh 立即失效） */
  async refresh(refreshToken: string) {
    let payload: JwtPayload;
    try {
      payload = await this.jwt.verifyAsync(refreshToken, {
        secret: this.config.get<string>('JWT_REFRESH_SECRET'),
      });
    } catch {
      throw new UnauthorizedException('登录已过期，请重新登录');
    }
    const key = `refresh:${payload.sub}:${payload.jti}`;
    const exists = await this.redis.exists(key);
    if (!exists) throw new UnauthorizedException('登录已过期，请重新登录');

    // 账号已删除/被禁用：禁止续期（封禁在登录处拦截，此处兜底已登录会话）
    const user = await this.users.findById(payload.sub);
    if (!user || user.isBanned) {
      throw new UnauthorizedException('账号已被禁用，请重新登录');
    }
    // 强制下线：禁止用旧 refresh token 续期
    if (await this.redis.exists(kickKey(payload.sub))) {
      throw new UnauthorizedException('账号已被强制下线，请重新登录');
    }

    await this.redis.del(key);
    return this.signTokens(payload.sub);
  }

  private async signTokens(userId: number) {
    const accessToken = await this.jwt.signAsync(
      { sub: userId, type: 'access' },
      {
        secret: this.config.get<string>('JWT_SECRET'),
        // access token 有效期默认 2h，可用环境变量 JWT_ACCESS_TTL 覆盖
        expiresIn: this.config.get<string>(
          'JWT_ACCESS_TTL',
          '2h',
        ) as JwtSignOptions['expiresIn'],
      },
    );
    const jti = randomUUID();
    const refreshToken = await this.jwt.signAsync(
      { sub: userId, type: 'refresh', jti },
      {
        secret: this.config.get<string>('JWT_REFRESH_SECRET'),
        expiresIn: '30d',
      },
    );
    await this.redis.set(`refresh:${userId}:${jti}`, '1', 'EX', REFRESH_TTL);
    return { accessToken, refreshToken };
  }
}
