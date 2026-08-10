import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import type { Request } from 'express';
import { UsersService } from '../users/users.service';

interface AuthedRequest extends Request {
  user?: { id: number };
}

/** 管理员校验：user.role === 'admin'（依赖 JwtAuthGuard 先注入 req.user） */
@Injectable()
export class AdminGuard implements CanActivate {
  constructor(private readonly users: UsersService) {}

  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    const req = ctx.switchToHttp().getRequest<AuthedRequest>();
    const user = req.user ? await this.users.findById(req.user.id) : null;
    if (!user || user.role !== 'admin' || user.isBanned) {
      throw new ForbiddenException('无管理权限');
    }
    return true;
  }
}
