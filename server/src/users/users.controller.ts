import { Body, Controller, Patch, UseGuards } from '@nestjs/common';
import { UpdateProfileDto } from '../auth/auth.dto';
import { CurrentUser } from '../auth/current-user.decorator';
import type { AuthUser } from '../auth/current-user.decorator';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { UsersService } from './users.service';

@Controller('users')
export class UsersController {
  constructor(private readonly users: UsersService) {}

  /** 编辑个人资料（昵称 / 头像） */
  @Patch('me')
  @UseGuards(JwtAuthGuard)
  async updateMe(@CurrentUser() user: AuthUser, @Body() dto: UpdateProfileDto) {
    await this.users.updateProfile(user.id, dto);
    return this.users.findById(user.id);
  }
}
