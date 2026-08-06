import {
  BadRequestException,
  ForbiddenException,
  Inject,
  Injectable,
  Logger,
  NotFoundException,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { InjectDataSource, InjectRepository } from '@nestjs/typeorm';
import { randomInt } from 'crypto';
import Redis from 'ioredis';
import { DataSource, EntityManager, In, Not, Repository } from 'typeorm';
import { REDIS_CLIENT } from '../redis/redis.module';
import { Activity } from '../activities/activity.entity';
import { ActivitySession } from '../activities/activity-session.entity';
import { Membership } from '../members/membership.entity';
import { Store } from '../stores/store.entity';
import { StoreTable } from '../stores/store-table.entity';
import { TimeSlot } from '../stores/time-slot.entity';
import { UsersService } from '../users/users.service';
import { Appointment } from './appointment.entity';
import { CreateAppointmentDto } from './appointment.dto';

@Injectable()
export class AppointmentsService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(AppointmentsService.name);
  private autoClockoutTimer: NodeJS.Timeout | null = null;
  private autoClockoutRunning = false;

  constructor(
    @InjectRepository(Appointment)
    private readonly appointments: Repository<Appointment>,
    @InjectRepository(Store)
    private readonly stores: Repository<Store>,
    @InjectRepository(StoreTable)
    private readonly tables: Repository<StoreTable>,
    @InjectRepository(TimeSlot)
    private readonly slots: Repository<TimeSlot>,
    @InjectRepository(Activity)
    private readonly activities: Repository<Activity>,
    @InjectRepository(ActivitySession)
    private readonly activitySessionsRepo: Repository<ActivitySession>,
    @InjectRepository(Membership)
    private readonly memberships: Repository<Membership>,
    private readonly users: UsersService,
    @Inject(REDIS_CLIENT) private readonly redis: Redis,
    @InjectDataSource() private readonly dataSource: DataSource,
  ) {}

  /** 启动后周期兜底：预约时段到点后自动下钟（未在读操作中即时结束的预约） */
  onModuleInit() {
    this.autoClockoutTimer = setInterval(async () => {
      if (this.autoClockoutRunning) return;
      this.autoClockoutRunning = true;
      try {
        await this.autoClockoutExpired();
      } catch (e) {
        this.logger.warn(`自动下钟失败：${(e as Error).message}`);
      } finally {
        this.autoClockoutRunning = false;
      }
    }, 30_000);
  }

  onModuleDestroy() {
    if (this.autoClockoutTimer) clearInterval(this.autoClockoutTimer);
  }

  /** 预约时段开始时刻（date + startTime，本地时区） */
  private scheduledStart(appt: Appointment): Date {
    return new Date(`${appt.date}T${appt.startTime}:00`);
  }

  /** 预约时段结束时刻（date + endTime，本地时区） */
  private scheduledEnd(appt: Appointment): Date {
    return new Date(`${appt.date}T${appt.endTime}:00`);
  }

  /** 校验核销时间：仅可在预约时段（date + startTime ~ endTime）内核销 */
  private assertCheckInTime(appt: Appointment): void {
    const now = new Date();
    if (now < this.scheduledStart(appt)) {
      throw new BadRequestException(
        `未到预约时段（${appt.startTime}-${appt.endTime}），请于开始时间后到店核销`,
      );
    }
    if (now > this.scheduledEnd(appt)) {
      throw new BadRequestException(
        `预约时段（${appt.startTime}-${appt.endTime}）已结束，无法核销`,
      );
    }
  }

  /**
   * 自动下钟：将预约时段已结束但仍处于服务中的预约置为已完成，
   * 下钟时间记为预约时段结束时刻（而不是任务执行时刻）。
   */
  async autoClockoutExpired(): Promise<number> {
    const now = new Date();
    const expired = await this.appointments.findBy({ status: 'in_service' });
    let count = 0;
    for (const appt of expired) {
      const end = this.scheduledEnd(appt);
      if (end <= now) {
        appt.status = 'completed';
        appt.serviceEndTime = end;
        await this.appointments.save(appt);
        count++;
      }
    }
    if (count > 0) this.logger.log(`自动下钟 ${count} 条预约`);
    return count;
  }

  /**
   * 创建预约：门店/时段/人数校验 → Redis 分布式锁 → 事务内冲突校验 + 落库。
   * 防超卖策略：同店同桌同时段仅允许 1 条未取消预约，先经 Redis 锁串行化，
   * 再由数据库唯一组合兜底（@Index 四列 + 事务内再查）。
   */
  async create(
    userId: number,
    dto: CreateAppointmentDto,
  ): Promise<Appointment> {
    const type = dto.type ?? 'store';
    const isMember = await this.isMemberActive(userId);
    if (type === 'activity') {
      return this.createActivity(userId, dto, isMember);
    }
    return this.createStore(userId, dto, isMember);
  }

  /** 是否有效会员（预约价按会员价计算） */
  private async isMemberActive(userId: number): Promise<boolean> {
    const membership = await this.memberships.findOneBy({ userId });
    return !!membership && membership.expireAt > new Date();
  }

  /**
   * 创建门店预约：门店/时段/人数校验 → Redis 分布式锁 → 事务内冲突校验 + 落库。
   * 防超卖策略：同店同桌同时段仅允许 1 条未取消预约，先经 Redis 锁串行化，
   * 再由数据库唯一组合兜底（@Index 四列 + 事务内再查）。
   */
  private async createStore(
    userId: number,
    dto: CreateAppointmentDto,
    isMember: boolean,
  ): Promise<Appointment> {
    if (dto.storeId == null || dto.tableId == null || dto.slotId == null) {
      throw new BadRequestException('门店预约需要选择门店、桌位和时段');
    }
    const store = await this.stores.findOneBy({
      id: dto.storeId,
      enabled: true,
    });
    if (!store) throw new NotFoundException('门店不存在');

    const slot = await this.slots.findOneBy({
      id: dto.slotId,
      storeId: dto.storeId,
      enabled: true,
    });
    if (!slot) throw new NotFoundException('时段不存在');

    const table = await this.tables.findOneBy({
      id: dto.tableId,
      storeId: dto.storeId,
      enabled: true,
    });
    if (!table) throw new NotFoundException('桌位不存在');

    // 人数超限校验
    if (dto.peopleCount > table.capacity) {
      throw new BadRequestException(
        `桌位「${table.name}」最多容纳 ${table.capacity} 人`,
      );
    }

    // 不能预约过去的日期
    const todayStr = this.todayStr();
    if (!dto.date) {
      throw new BadRequestException('门店预约需要选择日期');
    }
    if (dto.date < todayStr) {
      throw new BadRequestException('不能预约过去的日期');
    }

    // 价格：会员且配置了会员价时按会员价（0 元 = 会员免费），否则按门市价
    const unitPrice = this.unitPrice(
      isMember,
      store.price ?? 39.9,
      store.memberPrice,
    );
    const originalUnit = store.price ?? 39.9;
    const amount = this.roundMoney(unitPrice * dto.peopleCount);
    const originalAmount = this.roundMoney(originalUnit * dto.peopleCount);

    // 1) Redis 分布式锁：串行化同一桌位同时段的创建请求
    const lockKey = `booking:lock:${dto.storeId}:${dto.tableId}:${dto.date}:${dto.slotId}`;
    const acquired = await this.redis.set(lockKey, '1', 'EX', 10, 'NX');
    if (!acquired) {
      throw new BadRequestException(
        '该时段刚被其他用户预约，请选择其他时段或桌位',
      );
    }

    try {
      // 2) 事务：冲突校验（含 DB 组合索引兜底）+ 预约码生成 + 落库
      return await this.dataSource.transaction(async (em) => {
        const conflict = await em.findOne(Appointment, {
          where: {
            storeId: dto.storeId,
            tableId: dto.tableId,
            date: dto.date,
            slotId: dto.slotId,
            status: Not(In(['cancelled', 'completed'])),
          },
        });
        if (conflict) {
          throw new BadRequestException(
            '该桌位此时段已被预约，请选择其他时段或桌位',
          );
        }

        const appointment = em.create(Appointment, {
          userId,
          storeId: store.id,
          storeName: store.name,
          tableId: table.id,
          tableName: table.name,
          slotId: slot.id,
          date: dto.date,
          startTime: slot.startTime,
          endTime: slot.endTime,
          peopleCount: dto.peopleCount,
          code: await this.generateCode(em),
          note: dto.note ?? '',
          amount,
          originalAmount,
          payStatus: dto.payMethod ? ('paid' as const) : ('unpaid' as const),
          payMethod: dto.payMethod ?? '',
          paidAt: dto.payMethod ? new Date() : null,
        });
        return em.save(appointment);
      });
    } finally {
      await this.redis.del(lockKey).catch(() => undefined);
    }
  }

  /**
   * 创建活动预约：活动/场次/名额校验 → Redis 分布式锁 → 事务内名额校验 + 落库。
   * 防超卖：同一场次已预约人数 + 本次人数 ≤ 场次名额上限。
   */
  private async createActivity(
    userId: number,
    dto: CreateAppointmentDto,
    isMember: boolean,
  ): Promise<Appointment> {
    if (dto.activityId == null || dto.activitySessionId == null) {
      throw new BadRequestException('活动预约需要选择活动和场次');
    }
    const activity = await this.activities.findOneBy({
      id: dto.activityId,
      enabled: true,
      bookable: true,
    });
    if (!activity) throw new NotFoundException('活动不存在或不可预约');

    const session = await this.activitySessionsRepo.findOneBy({
      id: dto.activitySessionId,
      activityId: dto.activityId,
      enabled: true,
    });
    if (!session) throw new NotFoundException('活动场次不存在');

    if (dto.peopleCount > session.capacity) {
      throw new BadRequestException(
        `该场次最多容纳 ${session.capacity} 人`,
      );
    }
    if (session.date < this.todayStr()) {
      throw new BadRequestException('不能预约过去的场次');
    }

    // 价格：会员且配置了会员价时按会员价（0 元 = 会员免费），否则按门市价
    const unitPrice = this.unitPrice(
      isMember,
      activity.price ?? 0,
      activity.memberPrice,
    );
    const originalUnit = activity.price ?? 0;
    const amount = this.roundMoney(unitPrice * dto.peopleCount);
    const originalAmount = this.roundMoney(originalUnit * dto.peopleCount);

    const lockKey = `booking:activity:${dto.activityId}:${dto.activitySessionId}`;
    const acquired = await this.redis.set(lockKey, '1', 'EX', 10, 'NX');
    if (!acquired) {
      throw new BadRequestException(
        '该场次名额刚被其他用户抢走，请选择其他场次',
      );
    }

    try {
      return await this.dataSource.transaction(async (em) => {
        const booked = await em.find(Appointment, {
          where: {
            activitySessionId: dto.activitySessionId,
            status: Not(In(['cancelled', 'completed'])),
          },
        });
        const bookedCount = booked.reduce(
          (sum, a) => sum + a.peopleCount,
          0,
        );
        if (bookedCount + dto.peopleCount > session.capacity) {
          throw new BadRequestException(
            `该场次剩余名额不足，剩余 ${
              session.capacity - bookedCount
            } 人`,
          );
        }

        const appointment = em.create(Appointment, {
          userId,
          type: 'activity',
          storeId: null,
          storeName: activity.title,
          tableId: null,
          tableName: '',
          slotId: null,
          activityId: activity.id,
          activitySessionId: session.id,
          activityName: activity.title,
          date: session.date,
          startTime: session.startTime,
          endTime: session.endTime,
          peopleCount: dto.peopleCount,
          code: await this.generateCode(em),
          note: dto.note ?? '',
          amount,
          originalAmount,
          payStatus: dto.payMethod ? ('paid' as const) : ('unpaid' as const),
          payMethod: dto.payMethod ?? '',
          paidAt: dto.payMethod ? new Date() : null,
        });
        return em.save(appointment);
      });
    } finally {
      await this.redis.del(lockKey).catch(() => undefined);
    }
  }

  /** 会员价计算：会员且 memberPrice 已配置（含 0 元免费）时用会员价 */
  private unitPrice(
    isMember: boolean,
    normalPrice: number,
    memberPrice: number | null | undefined,
  ): number {
    if (isMember && memberPrice != null) return memberPrice;
    return normalPrice;
  }

  private roundMoney(value: number): number {
    return Math.round(value * 100) / 100;
  }

  /** 活动场次列表（含剩余名额），预约流程选场次用 */
  async activitySessions(activityId: number) {
    const activity = await this.activities.findOneBy({
      id: activityId,
      enabled: true,
      bookable: true,
    });
    if (!activity) throw new NotFoundException('活动不存在或不可预约');
    const sessions = await this.activitySessionsRepo.find({
      where: { activityId, enabled: true },
      order: { date: 'ASC', startTime: 'ASC' },
    });
    if (!sessions.length) return [];
    const ids = sessions.map((s) => s.id);
    const booked = await this.appointments.find({
      where: {
        activitySessionId: In(ids),
        status: Not(In(['cancelled', 'completed'])),
      },
    });
    const bookedMap = new Map<number, number>();
    for (const a of booked) {
      bookedMap.set(
        a.activitySessionId!,
        (bookedMap.get(a.activitySessionId!) ?? 0) + a.peopleCount,
      );
    }
    return sessions.map((s) => {
      const bookedCount = bookedMap.get(s.id) ?? 0;
      return {
        ...s,
        bookedCount,
        remaining: Math.max(0, s.capacity - bookedCount),
      };
    });
  }

  /** 我的预约列表（按时间倒序） */
  myList(userId: number): Promise<Appointment[]> {
    return this.appointments.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  /** 预约详情（仅本人或核销人） */
  async detail(userId: number, id: number): Promise<Appointment> {
    const appt = await this.appointments.findOneBy({ id });
    if (!appt) throw new NotFoundException('预约单不存在');
    if (appt.userId !== userId && appt.checkedInBy !== userId) {
      throw new ForbiddenException('无权查看该预约单');
    }
    // 自动下钟：预约时段到点后，读详情时即时结束服务，无需等定时任务
    if (appt.status === 'in_service' && this.scheduledEnd(appt) <= new Date()) {
      appt.status = 'completed';
      appt.serviceEndTime = this.scheduledEnd(appt);
      await this.appointments.save(appt);
    }
    return appt;
  }

  /** 取消预约（仅待核销状态） */
  async cancel(userId: number, id: number): Promise<Appointment> {
    const appt = await this.detail(userId, id);
    if (appt.status !== 'booked') {
      throw new BadRequestException('仅待核销状态的预约可取消');
    }
    appt.status = 'cancelled';
    return this.appointments.save(appt);
  }

  /** 扫码/输码核销：顾客到店核销即上钟，状态 booked → in_service（上钟时间以扫码时刻为准） */
  async checkIn(code: string, operatorId?: number): Promise<Appointment> {
    const appt = await this.appointments.findOneBy({ code });
    if (!appt) throw new NotFoundException('预约码无效');
    if (appt.status !== 'booked') {
      throw new BadRequestException(
        appt.status === 'cancelled'
          ? '该预约已取消'
          : '该预约码已核销，不可重复核销',
      );
    }

    // 校验预约日期：仅可当天核销
    const today = this.todayStr();
    if (appt.date !== today) {
      throw new BadRequestException(
        `预约日期为 ${appt.date}，仅可在预约当天核销`,
      );
    }
    // 校验核销时间：仅可在预约时段内核销
    this.assertCheckInTime(appt);

    // 核销即上钟：无需用户端再手动启动，计时从扫码时刻开始
    const now = new Date();
    appt.status = 'in_service';
    appt.checkInTime = now;
    appt.serviceStartTime = now;
    if (operatorId) appt.checkedInBy = operatorId;
    return this.appointments.save(appt);
  }

  /** 上钟：checked_in → in_service（兼容路径：历史数据/管理端核销后单独上钟） */
  async clockIn(userId: number, id: number): Promise<Appointment> {
    const appt = await this.appointments.findOneBy({ id });
    if (!appt) throw new NotFoundException('预约单不存在');

    // 用户本人或门店店员（checkedInBy）可操作
    if (appt.userId !== userId && appt.checkedInBy !== userId) {
      throw new ForbiddenException('无权操作该预约单');
    }

    if (appt.status !== 'checked_in') {
      throw new BadRequestException('仅已核销状态的预约可上钟');
    }

    appt.status = 'in_service';
    appt.serviceStartTime = new Date();
    return this.appointments.save(appt);
  }

  /** 下钟：状态 in_service → completed，记录结束时间 */
  async clockOut(userId: number, id: number): Promise<Appointment> {
    const appt = await this.appointments.findOneBy({ id });
    if (!appt) throw new NotFoundException('预约单不存在');

    if (appt.userId !== userId && appt.checkedInBy !== userId) {
      throw new ForbiddenException('无权操作该预约单');
    }

    if (appt.status !== 'in_service') {
      throw new BadRequestException('仅服务中状态的预约可下钟');
    }

    appt.status = 'completed';
    appt.serviceEndTime = new Date();
    return this.appointments.save(appt);
  }

  /** 按预约码查询（运营/核销用） */
  async findByCode(code: string): Promise<Appointment> {
    const appt = await this.appointments.findOneBy({ code });
    if (!appt) throw new NotFoundException('预约码无效');
    return appt;
  }

  /** 管理端：预约列表（分页，可按状态/门店/日期筛选），附带用户手机号/昵称 */
  async adminFindAll(
    filters?: {
      status?: string;
      storeId?: string;
      date?: string;
    },
    page = 1,
    pageSize = 20,
  ): Promise<
    [Array<Appointment & { userPhone?: string; userNickname?: string }>, number]
  > {
    const where: any = {};
    if (filters?.status) where.status = filters.status;
    if (filters?.storeId) where.storeId = parseInt(filters.storeId, 10);
    if (filters?.date) where.date = filters.date;
    const [items, total] = await this.appointments.findAndCount({
      where,
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
    const userIds = Array.from(new Set(items.map((i) => i.userId)));
    const users = await this.users.findByIds(userIds);
    const userMap = new Map(users.map((u) => [u.id, u]));
    return [
      items.map((i) => {
        const user = userMap.get(i.userId);
        return {
          ...i,
          userPhone: user?.phone,
          userNickname: user?.nickname || `用户 #${i.userId}`,
        };
      }),
      total,
    ];
  }

  /** 管理端取消预约（仅待核销/已核销状态，服务开始前） */
  async adminCancel(id: number): Promise<Appointment> {
    const appt = await this.appointments.findOneBy({ id });
    if (!appt) throw new NotFoundException('预约单不存在');
    if (appt.status !== 'booked' && appt.status !== 'checked_in') {
      throw new BadRequestException('仅待核销或已核销状态的预约可取消');
    }
    appt.status = 'cancelled';
    return this.appointments.save(appt);
  }

  /** 管理端核销（按 ID，管理员/店员代操作） */
  async adminCheckIn(id: number): Promise<Appointment> {
    const appt = await this.appointments.findOneBy({ id });
    if (!appt) throw new NotFoundException('预约单不存在');
    if (appt.status !== 'booked') {
      throw new BadRequestException(
        appt.status === 'cancelled'
          ? '该预约已取消'
          : '该预约码已核销，不可重复核销',
      );
    }
    // 校验核销日期/时间：仅可在预约当天且预约时段内核销
    if (appt.date !== this.todayStr()) {
      throw new BadRequestException(
        `预约日期为 ${appt.date}，仅可在预约当天核销`,
      );
    }
    this.assertCheckInTime(appt);
    appt.status = 'checked_in';
    appt.checkInTime = new Date();
    return this.appointments.save(appt);
  }

  /** 管理端上钟 */
  async adminClockIn(id: number): Promise<Appointment> {
    const appt = await this.appointments.findOneBy({ id });
    if (!appt) throw new NotFoundException('预约单不存在');
    if (appt.status !== 'checked_in') {
      throw new BadRequestException('仅已核销状态的预约可上钟');
    }
    appt.status = 'in_service';
    appt.serviceStartTime = new Date();
    return this.appointments.save(appt);
  }

  /** 管理端下钟 */
  async adminClockOut(id: number): Promise<Appointment> {
    const appt = await this.appointments.findOneBy({ id });
    if (!appt) throw new NotFoundException('预约单不存在');
    if (appt.status !== 'in_service') {
      throw new BadRequestException('仅服务中状态的预约可下钟');
    }
    appt.status = 'completed';
    appt.serviceEndTime = new Date();
    return this.appointments.save(appt);
  }

  /** 查询某门店某日某时段的桌位可用性（按人数过滤后，available=false 表示已被约） */
  async availability(storeId: number, date: string, slotId: number) {
    const store = await this.stores.findOneBy({ id: storeId, enabled: true });
    if (!store) throw new NotFoundException('门店不存在');
    const slot = await this.slots.findOneBy({
      id: slotId,
      storeId,
      enabled: true,
    });
    if (!slot) throw new NotFoundException('时段不存在');

    const tables = await this.tables.find({
      where: { storeId, enabled: true },
      order: { id: 'ASC' },
    });
    // 占用桌位的预约：待核销/已核销/服务中；已完成（已下钟）与已取消不占位
    const taken = await this.appointments.find({
      where: {
        storeId,
        date,
        slotId,
        status: Not(In(['cancelled', 'completed'])),
      },
    });
    const takenTableIds = new Set(taken.map((t) => t.tableId));

    return tables.map((t) => ({
      id: t.id,
      name: t.name,
      capacity: t.capacity,
      available: !takenTableIds.has(t.id),
    }));
  }

  /** 生成唯一 6 位数字预约码（重试兜底） */
  private async generateCode(em: EntityManager): Promise<string> {
    for (let i = 0; i < 5; i++) {
      const code = String(randomInt(0, 1_000_000)).padStart(6, '0');
      const exists = await em.findOne(Appointment, { where: { code } });
      if (!exists) return code;
    }
    throw new Error('预约码生成失败，请重试');
  }

  private todayStr(): string {
    const now = new Date();
    const y = now.getFullYear();
    const m = String(now.getMonth() + 1).padStart(2, '0');
    const d = String(now.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  }
}
