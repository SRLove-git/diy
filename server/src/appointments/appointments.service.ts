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
import { Store } from '../stores/store.entity';
import { StoreTable } from '../stores/store-table.entity';
import { TimeSlot } from '../stores/time-slot.entity';
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
  async create(userId: number, dto: CreateAppointmentDto): Promise<Appointment> {
    const store = await this.stores.findOneBy({ id: dto.storeId, enabled: true });
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
    if (dto.date < todayStr) {
      throw new BadRequestException('不能预约过去的日期');
    }

    // 1) Redis 分布式锁：串行化同一桌位同时段的创建请求
    const lockKey = `booking:lock:${dto.storeId}:${dto.tableId}:${dto.date}:${dto.slotId}`;
    const acquired = await this.redis.set(lockKey, '1', 'EX', 10, 'NX');
    if (!acquired) {
      throw new BadRequestException('该时段刚被其他用户预约，请选择其他时段或桌位');
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
          throw new BadRequestException('该桌位此时段已被预约，请选择其他时段或桌位');
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
        });
        return em.save(appointment);
      });
    } finally {
      await this.redis.del(lockKey).catch(() => undefined);
    }
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

  /** 管理端：全量预约列表（可按状态/门店/日期筛选） */
  async findAll(filters?: {
    status?: string;
    storeId?: string;
    date?: string;
  }): Promise<Appointment[]> {
    const where: any = {};
    if (filters?.status) where.status = filters.status;
    if (filters?.storeId) where.storeId = parseInt(filters.storeId, 10);
    if (filters?.date) where.date = filters.date;
    return this.appointments.find({
      where,
      order: { createdAt: 'DESC' },
    });
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
