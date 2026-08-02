import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { User } from '../users/user.entity';
import { Notification, NotificationTarget } from './notification.entity';
import { NotificationTemplate } from './notification-template.entity';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectRepository(Notification)
    private readonly notificationRepo: Repository<Notification>,
    @InjectRepository(NotificationTemplate)
    private readonly templateRepo: Repository<NotificationTemplate>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
  ) {}

  // ─── 通知记录 CRUD ───

  /** 创建并发送通知 */
  async createAndSend(dto: {
    title: string;
    content: string;
    targetType: NotificationTarget;
    targetRole?: 'user' | 'admin';
    targetUserIds?: string;
    channels?: string;
  }): Promise<Notification> {
    const notification = this.notificationRepo.create({
      ...dto,
      channels: dto.channels || 'push',
      sent: true,
      sentAt: new Date(),
    });
    return this.notificationRepo.save(notification);
  }

  /** 分页查询通知列表 */
  async findAll(page = 1, pageSize = 20) {
    const [items, total] = await this.notificationRepo.findAndCount({
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
    return { items, total, page, pageSize };
  }

  /** 删除通知 */
  async remove(id: number): Promise<void> {
    await this.notificationRepo.delete(id);
  }

  // ─── 模板 CRUD ───

  /** 获取所有模板 */
  async findAllTemplates(): Promise<NotificationTemplate[]> {
    return this.templateRepo.find({ order: { createdAt: 'DESC' } });
  }

  /** 创建模板 */
  async createTemplate(dto: {
    name: string;
    titleTemplate: string;
    contentTemplate: string;
    category: 'system' | 'booking' | 'community' | 'activity';
  }): Promise<NotificationTemplate> {
    return this.templateRepo.save(this.templateRepo.create(dto));
  }

  /** 更新模板 */
  async updateTemplate(
    id: number,
    dto: Partial<{
      name: string;
      titleTemplate: string;
      contentTemplate: string;
      category: 'system' | 'booking' | 'community' | 'activity';
      enabled: boolean;
    }>,
  ): Promise<NotificationTemplate> {
    await this.templateRepo.update(id, dto);
    return this.templateRepo.findOneOrFail({ where: { id } });
  }

  /** 删除模板 */
  async removeTemplate(id: number): Promise<void> {
    await this.templateRepo.delete(id);
  }

  /** 获取目标用户列表（用于定向发送） */
  async getTargetUsers(
    targetType: NotificationTarget,
    targetRole?: string,
    targetUserIds?: string,
  ): Promise<User[]> {
    if (targetType === 'all') {
      return this.userRepo.find({ where: { isBanned: false } });
    }
    if (targetType === 'role' && targetRole) {
      return this.userRepo.find({ where: { role: targetRole as any, isBanned: false } });
    }
    if (targetType === 'user' && targetUserIds) {
      const ids = targetUserIds.split(',').map(Number).filter(Boolean);
      return this.userRepo.find({ where: { id: In(ids), isBanned: false } });
    }
    return [];
  }
}
