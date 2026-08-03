import {
  BadRequestException,
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

async function verifyPassword(password: string, stored: string): Promise<boolean> {
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
const REFRESH_TTL = 30 * 24 * 3600; // 刷新令牌 30 天
const MAX_ATTEMPTS = 5; // 10 分钟内最多尝试 5 次

@Injectable()
export class AuthService {
  constructor(
    @Inject(REDIS_CLIENT) private readonly redis: Redis,
    private readonly users: UsersService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
    private readonly sms: SmsService,
  ) {}

  /** 发送验证码（含防刷） */
  async sendSmsCode(phone: string) {
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
    await this.sms.send(phone, `【DIY手作工坊】您的验证码是 ${code}，5 分钟内有效。`);

    // 开发环境：返回验证码便于联调，生产环境不返回
    const isDev = this.config.get<string>('NODE_ENV') !== 'production';
    return isDev ? { sent: true, code } : { sent: true };
  }

  /** 验证码登录（未注册自动注册） */
  async login(phone: string, code: string) {
    await this.verifySmsCode(phone, code);
    const user = await this.users.findByPhoneOrCreate(phone);
    if (user.isBanned) throw new ForbiddenException('账号已被禁用');

    const tokens = await this.signTokens(user.id);
    return { userId: user.id, ...tokens };
  }

  /** 密码登录（需先用验证码设置过密码） */
  async passwordLogin(phone: string, password: string) {
    const user = await this.users.findByPhone(phone);
    if (!user || !user.passwordHash) {
      throw new UnauthorizedException('该账号未设置密码，请先设置密码');
    }
    if (!(await verifyPassword(password, user.passwordHash))) {
      throw new UnauthorizedException('手机号或密码错误');
    }
    if (user.isBanned) throw new ForbiddenException('账号已被禁用');

    const tokens = await this.signTokens(user.id);
    return { userId: user.id, ...tokens };
  }

  /** 设置/重置密码：短信验证码校验通过后写入新密码 */
  async setPassword(phone: string, code: string, password: string) {
    await this.verifySmsCode(phone, code);
    const user = await this.users.findByPhoneOrCreate(phone);
    if (user.isBanned) throw new ForbiddenException('账号已被禁用');

    await this.users.setPasswordHash(user.id, await hashPassword(password));
    return { sent: true };
  }

  /** 校验短信验证码（含防爆破），校验成功后验证码即焚 */
  private async verifySmsCode(phone: string, code: string) {
    const attemptKey = `sms:attempt:${phone}`;
    const attempts = await this.redis.incr(attemptKey);
    if (attempts === 1) await this.redis.expire(attemptKey, 600);
    if (attempts > MAX_ATTEMPTS) throw new BadRequestException('尝试次数过多，请稍后再试');

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
