import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { JwtPayload } from './auth.service';

/** 校验 Authorization: Bearer <accessToken>，通过后注入 req.user = { id } */
@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
  ) {}

  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    const req = ctx.switchToHttp().getRequest();
    const header = req.headers.authorization;
    if (!header?.startsWith('Bearer ')) throw new UnauthorizedException('未登录');

    try {
      const payload = (await this.jwt.verifyAsync(header.slice(7), {
        secret: this.config.get<string>('JWT_SECRET'),
      })) as JwtPayload;
      if (payload.type !== 'access') throw new Error('wrong token type');
      req.user = { id: payload.sub };
      return true;
    } catch {
      throw new UnauthorizedException('登录已过期');
    }
  }
}
