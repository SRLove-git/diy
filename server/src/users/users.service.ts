import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User) private readonly users: Repository<User>,
  ) {}

  findByPhone(phone: string): Promise<User | null> {
    return this.users.findOneBy({ phone });
  }

  /** 按手机号查用户，不存在则创建（并发下靠唯一约束兜底） */
  async findByPhoneOrCreate(phone: string): Promise<User> {
    const existing = await this.findByPhone(phone);
    if (existing) return existing;
    try {
      return await this.create({ phone });
    } catch {
      const again = await this.findByPhone(phone);
      if (again) return again;
      throw new Error('用户创建失败');
    }
  }

  findById(id: number): Promise<User | null> {
    return this.users.findOneBy({ id });
  }

  create(data: Partial<User>): Promise<User> {
    return this.users.save(this.users.create(data));
  }

  updateProfile(id: number, patch: { nickname?: string; avatar?: string }) {
    return this.users.update({ id }, patch);
  }

  setRole(id: number, role: 'admin' | 'user') {
    return this.users.update({ id }, { role });
  }
}
