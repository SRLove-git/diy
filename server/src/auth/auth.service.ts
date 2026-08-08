import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Inject,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService, type JwtSignOptions } from '@nestjs/jwt';
import { randomBytes, scrypt as scryptCb, timingSafeEqual } from 'crypto';
import { promisify } from 'util';
import type Redis from 'ioredis';
import { randomUUID } from 'crypto';
import { REDIS_CLIENT } from '../redis/redis.module';
import { SmsService } from '../sms/sms.service';
import { UsersService } from '../users/users.service';
import { kickKey } from './session-keys';

const scrypt = promisify(scryptCb) as (
  password: string,
  salt: Buffer,
  keylen: number,
) => Promise<Buffer>;

/** scrypt 哈希密码，格式：scrypt$<salt hex>:<hash hex> */
async function hashPassword(password: string): Promise<string> {
  const salt = randomBytes(16);
  const hash = await scrypt(password, salt, 64);
  return `scrypt$${salt.toString('hex')}:${hash.toString('hex')}`;
}

async function verifyPassword(
  password: string,
  stored: string,
): Promise<boolean> {
  const [scheme, rest] = stored.split('$');
  if (scheme !== 'scrypt' || !rest) return false;
  const [saltHex, hashHex] = rest.split(':');
  if (!saltHex || !hashHex) return false;
  const salt = Buffer.from(saltHex, 'hex');
  const expected = Buffer.from(hashHex, 'hex');
  const actual = await scrypt(password, salt, expected.length);
  return expected.length === actual.length && timingSafeEqual(expected, actual);
}

export interface JwtPayload {
  sub: number;
  type: 'access' | 'refresh';
  jti?: string;
}

const SMS_CODE_TTL = 300; // 验证码 5 分钟有效
const SMS_LIMIT_TTL = 60; // 同一手机号 60 秒限发一次
const SMS_IP_LIMIT_TTL = 3600; // 同一 IP 每小时限发次数窗口
const SMS_IP_LIMIT_MAX = 10; // 同一 IP 每小时最多发送 10 条
const REFRESH_TTL = 30 * 24 * 3600; // 刷新令牌 30 天
const MAX_ATTEMPTS = 5; // 10 分钟内最多尝试 5 次
const PASSWORD_ATTEMPT_MAX = 5; // 密码登录 10 分钟内最多失败 5 次
const PASSWORD_LOCK_TTL = 600; // 连续失败后锁定 10 分钟

@Injectable()
export class AuthService {
  constructor(
    @Inject(REDIS_CLIENT) private readonly redis: Redis,
    private readonly users: UsersService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
    private readonly sms: SmsService,
  ) {}

  /** 发送验证码（含防刷：60 秒/手机号 + 每小时/IP 上限） */
  async sendSmsCode(phone: string, ip?: string) {
    // 先做 IP 维度限流（有则计次），再锁手机号，避免被批量刷号
    if (ip) {
      const ipKey = `sms:limit-ip:${ip}`;
      const ipCount = await this.redis.incr(ipKey);
      if (ipCount === 1) await this.redis.expire(ipKey, SMS_IP_LIMIT_TTL);
      if (ipCount > SMS_IP_LIMIT_MAX) {
        throw new BadRequestException('发送过于频繁，请稍后再试');
      }
    }
    const locked = await this.redis.set(
      `sms:limit:${phone}`,
      '1',
      'EX',
      SMS_LIMIT_TTL,
      'NX',
    );
    if (!locked) throw new BadRequestException('发送过于频繁，请 60 秒后再试');

    const code = String(Math.floor(100000 + Math.random() * 900000));
    await this.redis.set(`sms:code:${phone}`, code, 'EX', SMS_CODE_TTL);
    await this.sms.send(
      phone,
      `【DIY手作工坊】您的验证码是 ${code}，5 分钟内有效。`,
    );

    // 开发环境：返回验证码便于联调，生产环境不返回
    const isDev = this.config.get<string>('NODE_ENV') !== 'production';
    return isDev ? { sent: true, code } : { sent: true };
  }

  /** 验证码登录（未注册自动注册） */
  async login(phone: string, code: string) {
    await this.verifySmsCode(phone, code);
    const { user, created } =
      await this.users.findByPhoneOrCreateWithFlag(phone);
    if (user.isBanned) throw new ForbiddenException('账号已被禁用');
    // 强制下线/封禁的旧会话标记随重新登录清除
    await this.redis.del(kickKey(user.id));

    const tokens = await this.signTokens(user.id);
    // isNewUser：首次验证码登录自动注册，客户端可据此引导完善资料
    return { userId: user.id, isNewUser: created, ...tokens };
  }

  /** 密码登录（需先用验证码设置过密码） */
  async passwordLogin(phone: string, password: string) {
    const lockKey = `pw:${phone}`;
    await this.checkLoginLock(lockKey);
    const user = await this.users.findByPhone(phone);
    if (!user || !user.passwordHash) {
      await this.recordLoginFailure(lockKey);
      throw new UnauthorizedException('该账号未设置密码，请先设置密码');
    }
    if (!(await verifyPassword(password, user.passwordHash))) {
      await this.recordLoginFailure(lockKey);
      throw new UnauthorizedException('手机号或密码错误');
    }
    await this.clearLoginFailures(lockKey);
    if (user.isBanned) throw new ForbiddenException('账号已被禁用');
    await this.redis.del(kickKey(user.id));

    const tokens = await this.signTokens(user.id);
    return { userId: user.id, ...tokens };
  }

  /** 用户名 + 密码登录 */
  async usernameLogin(username: string, password: string) {
    const lockKey = `un:${username}`;
    await this.checkLoginLock(lockKey);
    const user = await this.users.findByUsername(username);
    if (!user || !user.passwordHash) {
      await this.recordLoginFailure(lockKey);
      throw new UnauthorizedException('用户名不存在或未设置密码');
    }
    if (!(await verifyPassword(password, user.passwordHash))) {
      await this.recordLoginFailure(lockKey);
      throw new UnauthorizedException('用户名或密码错误');
    }
    await this.clearLoginFailures(lockKey);
    if (user.isBanned) throw new ForbiddenException('账号已被禁用');
    await this.redis.del(kickKey(user.id));

    const tokens = await this.signTokens(user.id);
    return { userId: user.id, ...tokens };
  }

  /** 设置/重置密码（找回密码 / 修改密码共用）：短信验证码校验通过后写入新密码。
   *  仅限已注册手机号——微信式逻辑中注册由验证码登录自动完成，这里不再隐式建号。 */
  async setPassword(
    phone: string,
    code: string,
    password: string,
    username?: string,
  ) {
    await this.verifySmsCode(phone, code);
    const user = await this.users.findByPhone(phone);
    if (!user) {
      throw new BadRequestException('该手机号未注册，请先通过验证码登录');
    }
    if (user.isBanned) throw new ForbiddenException('账号已被禁用');

    await this.users.setPasswordHash(user.id, await hashPassword(password));
    if (username) {
      const existing = await this.users.findByUsername(username);
      if (existing && existing.id !== user.id) {
        throw new ConflictException('用户名已被占用');
      }
      await this.users.setUsername(user.id, username);
    }
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

  /** 校验短信验证码（含防爆破），校验成功后验证码即焚 */
  private async verifySmsCode(phone: string, code: string) {
    const attemptKey = `sms:attempt:${phone}`;
    const attempts = await this.redis.incr(attemptKey);
    if (attempts === 1) await this.redis.expire(attemptKey, 600);
    if (attempts > MAX_ATTEMPTS)
      throw new BadRequestException('尝试次数过多，请稍后再试');

    const saved = await this.redis.get(`sms:code:${phone}`);
    if (!saved || saved !== code) {
      throw new BadRequestException('验证码错误或已过期');
    }

    // 一次性验证码，用后即焚
    await this.redis.del(`sms:code:${phone}`, attemptKey);
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
