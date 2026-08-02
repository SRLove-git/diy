import {
  BadRequestException,
  ForbiddenException,
  Inject,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectDataSource, InjectRepository } from '@nestjs/typeorm';
import { randomInt } from 'crypto';
import Redis from 'ioredis';
import { DataSource, EntityManager, Not, Repository } from 'typeorm';
import { REDIS_CLIENT } from '../redis/redis.module';
import { Store } from '../stores/store.entity';
import { StoreTable } from '../stores/store-table.entity';
import { TimeSlot } from '../stores/time-slot.entity';
import { Appointment } from './appointment.entity';
import { CreateAppointmentDto } from './appointment.dto';

@Injectable()
export class AppointmentsService {
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
            status: Not('cancelled'),
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

  /** 预约详情（仅本人） */
  async detail(userId: number, id: number): Promise<Appointment> {
    const appt = await this.appointments.findOneBy({ id });
    if (!appt) throw new NotFoundException('预约单不存在');
    if (appt.userId !== userId) throw new ForbiddenException('无权查看该预约单');
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

  /** 输码核销：通过预约码核销，状态 booked → checked_in */
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

    appt.status = 'checked_in';
    appt.checkInTime = new Date();
    if (operatorId) appt.checkedInBy = operatorId;
    return this.appointments.save(appt);
  }

  /** 上钟：状态 checked_in → in_service，记录开始时间 */
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
    const taken = await this.appointments.find({
      where: { storeId, date, slotId, status: Not('cancelled') },
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
