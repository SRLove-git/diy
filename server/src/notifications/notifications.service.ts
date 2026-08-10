import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { ChatGateway } from '../chat/chat.gateway';
import type { AppLocale } from '../common/i18n';
import { User } from '../users/user.entity';
import {
  Notification,
  NotificationCategory,
  NotificationTarget,
} from './notification.entity';
import { NotificationRead } from './notification-read.entity';
import { NotificationTemplate } from './notification-template.entity';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectRepository(Notification)
    private readonly notificationRepo: Repository<Notification>,
    @InjectRepository(NotificationTemplate)
    private readonly templateRepo: Repository<NotificationTemplate>,
    @InjectRepository(NotificationRead)
    private readonly readRepo: Repository<NotificationRead>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    private readonly gateway: ChatGateway,
  ) {}

  // ─── 通知记录 CRUD ───

  /** 创建并发送通知 */
  async createAndSend(dto: {
    title: string;
    content: string;
    titleEn?: string;
    contentEn?: string;
    category?: NotificationCategory;
    targetType: NotificationTarget;
    targetRole?: 'user' | 'admin';
    targetUserIds?: string;
    channels?: string;
    actionType?: 'post' | 'video' | 'user';
    actionId?: number;
  }): Promise<Notification> {
    const notification = this.notificationRepo.create({
      ...dto,
      titleEn: dto.titleEn ?? null,
      contentEn: dto.contentEn ?? null,
      category: dto.category ?? 'system',
      actionType: dto.actionType ?? null,
      actionId: dto.actionId ?? null,
      channels: dto.channels || 'push',
      sent: true,
      sentAt: new Date(),
    });
    const saved = await this.notificationRepo.save(notification);
    // 实时通知在线目标用户刷新未读角标；广播失败不影响通知创建
    void this.notifyTargets(saved).catch(() => {});
    return saved;
  }

  /** 解析通知目标用户并广播实时事件（离线用户下次进入拉取未读数即可） */
  private async notifyTargets(notification: Notification): Promise<void> {
    let ids: number[] = [];
    switch (notification.targetType) {
      case 'all': {
        const rows = await this.userRepo.find({ select: { id: true } });
        ids = rows.map((u) => u.id);
        break;
      }
      case 'role': {
        if (!notification.targetRole) return;
        const rows = await this.userRepo.find({
          where: { role: notification.targetRole },
          select: { id: true },
        });
        ids = rows.map((u) => u.id);
        break;
      }
      case 'user':
        ids = (notification.targetUserIds ?? '')
          .split(',')
          .map(Number)
          .filter(Boolean);
        break;
    }
    if (ids.length) this.gateway.broadcastNotification(ids);
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

  /** 通知总数（用于预置数据判断） */
  async countAll(): Promise<number> {
    return this.notificationRepo.count();
  }

  /** 删除通知 */
  async remove(id: number): Promise<void> {
    await this.notificationRepo.delete(id);
  }

  // ─── 用户端：我的通知 ───

  /** 当前用户可见的通知（全体 / 本人角色 / 定向本人），仅已发送 */
  async myNotifications(
    userId: number,
    page = 1,
    pageSize = 20,
    locale: AppLocale = 'zh',
  ) {
    const role = await this.resolveRole(userId);
    const applicable = await this.applicableNotifications(userId, role);
    const ids = applicable.map((n) => n.id);
    if (!ids.length) return { items: [], total: 0, unread: 0, page, pageSize };

    const readRows = await this.readRepo.find({
      where: { userId, notificationId: In(ids) },
      select: { notificationId: true },
    });
    const readSet = new Set(readRows.map((r) => r.notificationId));

    const total = applicable.length;
    const unread = applicable.filter((n) => !readSet.has(n.id)).length;
    const start = (page - 1) * pageSize;
    const pageItems = applicable.slice(start, start + pageSize);

    return {
      items: pageItems.map((n) => ({
        id: n.id,
        title: locale === 'en' && n.titleEn ? n.titleEn : n.title,
        content: locale === 'en' && n.contentEn ? n.contentEn : n.content,
        category: n.category,
        channel: n.channels,
        createdAt: n.createdAt,
        sentAt: n.sentAt,
        actionType: n.actionType ?? null,
        actionId: n.actionId ?? null,
        read: readSet.has(n.id),
      })),
      total,
      unread,
      page,
      pageSize,
    };
  }

  /** 未读通知数 */
  async unreadCount(userId: number): Promise<number> {
    const role = await this.resolveRole(userId);
    const applicable = await this.applicableNotifications(userId, role);
    if (!applicable.length) return 0;
    const rows = await this.readRepo.find({
      where: { userId },
      select: { notificationId: true },
    });
    const readSet = new Set(rows.map((r) => r.notificationId));
    return applicable.filter((n) => !readSet.has(n.id)).length;
  }

  /** 标记单条已读 */
  async markRead(userId: number, notificationId: number) {
    const notification = await this.notificationRepo.findOneBy({
      id: notificationId,
      sent: true,
    });
    if (!notification) return { ok: true };
    await this.saveRead(userId, notificationId);
    return { ok: true };
  }

  /** 全部标记已读 */
  async markAllRead(userId: number) {
    const role = await this.resolveRole(userId);
    const applicable = await this.applicableNotifications(userId, role);
    for (const n of applicable) {
      await this.saveRead(userId, n.id);
    }
    return { ok: true };
  }

  /** 当前用户可见的通知实体（按发送时间倒序） */
  private async applicableNotifications(
    userId: number,
    role: string,
  ): Promise<Notification[]> {
    const rows = await this.notificationRepo.find({
      where: { sent: true },
      order: { createdAt: 'DESC' },
    });
    return rows.filter((n) => this.appliesTo(n, userId, role));
  }

  /** 用户角色（兜底普通用户） */
  private async resolveRole(userId: number): Promise<string> {
    const user = await this.userRepo.findOneBy({ id: userId });
    return user?.role ?? 'user';
  }

  /** 通知是否对当前用户可见 */
  private appliesTo(n: Notification, userId: number, role: string): boolean {
    switch (n.targetType) {
      case 'all':
        return true;
      case 'role':
        return n.targetRole === role;
      case 'user':
        return (n.targetUserIds ?? '')
          .split(',')
          .map(Number)
          .filter(Boolean)
          .includes(userId);
      default:
        return false;
    }
  }

  /** 幂等写入已读记录 */
  private async saveRead(userId: number, notificationId: number) {
    if (await this.readRepo.existsBy({ userId, notificationId })) {
      return;
    }
    await this.readRepo.save(this.readRepo.create({ userId, notificationId }));
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
      return this.userRepo.find({
        where: { role: targetRole as User['role'], isBanned: false },
      });
    }
    if (targetType === 'user' && targetUserIds) {
      const ids = targetUserIds.split(',').map(Number).filter(Boolean);
      return this.userRepo.find({ where: { id: In(ids), isBanned: false } });
    }
    return [];
  }
}
