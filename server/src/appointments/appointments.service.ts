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
import { ChatGateway } from '../chat/chat.gateway';
import { Coupon, UserCoupon } from '../members/coupon.entity';
import { Membership } from '../members/membership.entity';
import { Store } from '../stores/store.entity';
import { StoreTable } from '../stores/store-table.entity';
import { StorePackage } from '../stores/store-package.entity';
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
    @InjectRepository(StorePackage)
    private readonly packages: Repository<StorePackage>,
    @InjectRepository(Activity)
    private readonly activities: Repository<Activity>,
    @InjectRepository(ActivitySession)
    private readonly activitySessionsRepo: Repository<ActivitySession>,
    @InjectRepository(Membership)
    private readonly memberships: Repository<Membership>,
    private readonly users: UsersService,
    private readonly gateway: ChatGateway,
    @Inject(REDIS_CLIENT) private readonly redis: Redis,
    @InjectDataSource() private readonly dataSource: DataSource,
  ) {}

  /** 预约状态变更后推送给用户端（msgpack 安全：Date 转 ISO 字符串） */
  private broadcastAppointment(appt: Appointment): void {
    this.gateway.sendAppointment(appt.userId, {
      ...appt,
      checkInTime: appt.checkInTime?.toISOString() ?? null,
      serviceStartTime: appt.serviceStartTime?.toISOString() ?? null,
      serviceEndTime: appt.serviceEndTime?.toISOString() ?? null,
      createdAt: appt.createdAt?.toISOString() ?? null,
    });
  }

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

  /** 预约时段结束时刻（date + endTime，本地时区） */
  private scheduledEnd(appt: Appointment): Date {
    return new Date(`${appt.date}T${appt.endTime}:00`);
  }

  /** 解析营业时间 "09:00-21:00" → {start, end}，解析失败回退 09:00-22:00 */
  private businessHoursRange(store: Store): { start: string; end: string } {
    const m = (store.businessHours || '').match(
      /((?:[01]\d|2[0-3]):[0-5]\d)\s*-\s*((?:[01]\d|2[0-3]):[0-5]\d)/,
    );
    return m
      ? { start: m[1], end: m[2] }
      : { start: '09:00', end: '22:00' };
  }

  private minutes(time: string): number {
    const [h, m] = time.split(':').map(Number);
    return h * 60 + m;
  }

  private formatMinutes(mins: number): string {
    const h = Math.floor(mins / 60);
    const m = mins % 60;
    return `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}`;
  }

  /** 按小时单价（元/人/小时）：会员且配置会员价时用会员价 */
  private hourlyUnitPrice(
    isMember: boolean,
    store: Store,
  ): number {
    if (isMember && store.memberPrice != null) return store.memberPrice;
    return store.price ?? 39.9;
  }

  /** 校验核销时间：仅限预约当天、预约结束前。
   *  先到先得：可提前到店扫码开始计时；不因迟到顺延（结束时间固定为预约时段）。 */
  private assertCheckInTime(appt: Appointment): void {
    const now = new Date();
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
    const today = this.todayStr();
    const nowHM = `${String(now.getHours()).padStart(2, '0')}:${String(
      now.getMinutes(),
    ).padStart(2, '0')}`;
    // 只查「预约日已过」或「当天且时段已结束」的服务中预约，走 (status, date, endTime) 索引
    const expired = await this.appointments
      .createQueryBuilder('a')
      .where('a.status = :status', { status: 'in_service' })
      .andWhere(
        '(a.date < :today OR (a.date = :today AND a.endTime <= :nowHM))',
        { today, nowHM },
      )
      .getMany();
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
    if (dto.storeId == null) {
      throw new BadRequestException('门店预约需要选择门店、桌位和预约方式');
    }
    const store = await this.stores.findOneBy({
      id: dto.storeId,
      enabled: true,
    });
    if (!store) throw new NotFoundException('门店不存在');

    // 桌位解析：支持一单多桌（tableIds），单桌兼容 tableId
    const requestedIds =
      dto.tableIds && dto.tableIds.length
        ? [...new Set(dto.tableIds)]
        : dto.tableId != null
          ? [dto.tableId]
          : [];
    if (!requestedIds.length) {
      throw new BadRequestException('门店预约需要选择桌位');
    }
    const tableRows = await this.tables.find({
      where: { id: In(requestedIds), storeId: dto.storeId, enabled: true },
    });
    if (tableRows.length !== requestedIds.length) {
      throw new NotFoundException('部分桌位不存在或已停用');
    }
    // 按用户选择顺序排序
    tableRows.sort(
      (a, b) => requestedIds.indexOf(a.id) - requestedIds.indexOf(b.id),
    );

    // 人数校验：所选桌位总容量需 ≥ 人数
    const totalCapacity = tableRows.reduce((s, t) => s + t.capacity, 0);
    if (dto.peopleCount > totalCapacity) {
      throw new BadRequestException(
        `所选桌位最多容纳 ${totalCapacity} 人，当前 ${dto.peopleCount} 人，请增加桌位`,
      );
    }
    // 自动分配人数：按用户选择顺序依次坐满
    let remainingPeople = dto.peopleCount;
    const seats = tableRows.map((t) => {
      const people = Math.min(t.capacity, remainingPeople);
      remainingPeople -= people;
      return { id: t.id, name: t.name, capacity: t.capacity, people };
    });

    // 不能预约过去的日期
    const todayStr = this.todayStr();
    if (!dto.date) {
      throw new BadRequestException('门店预约需要选择日期');
    }
    if (dto.date < todayStr) {
      throw new BadRequestException('不能预约过去的日期');
    }

    // 预约方式：按小时（1 小时起）/ 套餐 / 全天不限时
    const bookingType = dto.bookingType ?? 'hourly';
    const range = this.businessHoursRange(store);
    const openMin = this.minutes(range.start);
    const closeMin = Math.min(this.minutes(range.end), 24 * 60 - 1);

    let startTime: string;
    let endTime: string;
    let durationHours: number;
    let packageId: number | null = null;
    let packageName = '';
    let unitPrice: number; // 单人整单价格（非小时价）
    let originalUnit: number;

    if (bookingType === 'all_day') {
      // 全天不限时：营业开始 ~ 营业结束，结束时间固定
      startTime = range.start;
      endTime = range.end;
      durationHours = Math.max(
        1,
        Math.round((closeMin - openMin) / 60),
      );
      const hourly = this.hourlyUnitPrice(isMember, store);
      unitPrice =
        store.allDayPrice != null
          ? store.allDayPrice
          : this.roundMoney(hourly * durationHours);
      originalUnit =
        store.allDayPrice != null
          ? store.allDayPrice
          : this.roundMoney((store.price ?? 39.9) * durationHours);
    } else if (bookingType === 'package') {
      // 时长套餐：选择套餐 + 开始时间
      if (dto.packageId == null) {
        throw new BadRequestException('套餐预约需要选择套餐');
      }
      if (!dto.startTime) {
        throw new BadRequestException('套餐预约需要选择开始时间');
      }
      const pkg = await this.packages.findOneBy({
        id: dto.packageId,
        storeId: dto.storeId,
        enabled: true,
      });
      if (!pkg) throw new NotFoundException('套餐不存在');
      packageId = pkg.id;
      packageName = pkg.name;
      durationHours = pkg.hours;
      startTime = dto.startTime;
      endTime = this.formatMinutes(this.minutes(startTime) + pkg.hours * 60);
      unitPrice = pkg.price;
      originalUnit = pkg.price;
    } else {
      // 按小时：开始时间 + 时长（1 小时起）
      if (!dto.startTime) {
        throw new BadRequestException('按小时预约需要选择开始时间');
      }
      if (dto.durationHours == null) {
        throw new BadRequestException('按小时预约需要选择时长');
      }
      durationHours = dto.durationHours;
      startTime = dto.startTime;
      endTime = this.formatMinutes(
        this.minutes(startTime) + durationHours * 60,
      );
      const hourly = this.hourlyUnitPrice(isMember, store);
      unitPrice = this.roundMoney(hourly * durationHours);
      originalUnit = this.roundMoney(
        (store.price ?? 39.9) * durationHours,
      );
    }

    // 预约时段必须落在营业时间内且不跨天
    const startMin = this.minutes(startTime);
    const endMin = this.minutes(endTime);
    if (startMin < openMin || endMin > closeMin || endMin <= startMin) {
      throw new BadRequestException(
        `预约时段需在营业时间（${range.start}-${range.end}）内`,
      );
    }

    // 已过去的时间段不可预约（服务端兜底）：
    // 按小时/套餐：开始时间必须晚于当前；全天不限时：营业结束时间需晚于当前
    if (bookingType === 'all_day') {
      const endDateTime = new Date(`${dto.date}T${endTime}:00`);
      if (endDateTime.getTime() <= Date.now()) {
        throw new BadRequestException('该日期营业时段已结束，无法预约');
      }
    } else {
      const startDateTime = new Date(`${dto.date}T${startTime}:00`);
      if (startDateTime.getTime() <= Date.now()) {
        throw new BadRequestException('该时段已开始，无法预约');
      }
    }

    const amount = this.roundMoney(unitPrice * dto.peopleCount);
    const originalAmount = this.roundMoney(originalUnit * dto.peopleCount);

    // 1) Redis 分布式锁：串行化同一组桌位同日的创建请求
    const lockKey = `booking:lock:${dto.storeId}:${[...requestedIds]
      .sort((a, b) => a - b)
      .join(',')}:${dto.date}`;
    const acquired = await this.redis.set(lockKey, '1', 'EX', 10, 'NX');
    if (!acquired) {
      throw new BadRequestException(
        '该桌位刚被其他用户预约，请选择其他时段或桌位',
      );
    }

    try {
      // 2) 事务：冲突校验（含 DB 组合索引兜底）+ 预约码生成 + 落库
      return await this.dataSource.transaction(async (em) => {
        // 冲突校验：扫描该门店当日全部有效预约，按桌位（含一单多桌）+ 时间段重叠判断
        const active = await em.find(Appointment, {
          where: {
            storeId: dto.storeId,
            date: dto.date,
            status: Not(In(['cancelled', 'completed'])),
          },
        });
        // 时间段重叠判定：existing.start < new.end && existing.end > new.start
        const conflict = active.find((a) => {
          const apptTableIds = a.tables?.length
            ? a.tables.map((t) => t.id)
            : a.tableId != null
              ? [a.tableId]
              : [];
          const sharesTable = requestedIds.some((id) =>
            apptTableIds.includes(id),
          );
          return sharesTable && a.startTime < endTime && a.endTime > startTime;
        });
        if (conflict) {
          const conflictTables = (conflict.tables?.length
            ? conflict.tables.map((t) => t.name)
            : [conflict.tableName]
          ).join('、');
          throw new BadRequestException(
            `桌位 ${conflictTables} ${conflict.startTime}-${conflict.endTime} 已被预约，请选择其他时段或桌位`,
          );
        }

        // 使用优惠券：同一事务内校验并抵扣，失败则整单不落库
        let finalAmount = amount;
        let couponDiscount = 0;
        let couponTitle = '';
        if (dto.userCouponId != null) {
          const applied = await this.applyCoupon(
            em,
            userId,
            dto.userCouponId,
            amount,
          );
          couponDiscount = applied.discount;
          couponTitle = applied.title;
          finalAmount = this.roundMoney(amount - couponDiscount);
        }

        const appointment = em.create(Appointment, {
          userId,
          storeId: store.id,
          storeName: store.name,
          tableId: seats[0].id,
          tableName: seats[0].name,
          tables: seats,
          slotId: null,
          bookingType,
          durationHours,
          packageId,
          packageName,
          date: dto.date,
          startTime,
          endTime,
          peopleCount: dto.peopleCount,
          code: await this.generateCode(em),
          note: dto.note ?? '',
          amount: finalAmount,
          originalAmount,
          userCouponId: dto.userCouponId ?? null,
          couponTitle,
          couponDiscount,
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

        // 使用优惠券：同一事务内校验并抵扣，失败则整单不落库
        let finalAmount = amount;
        let couponDiscount = 0;
        let couponTitle = '';
        if (dto.userCouponId != null) {
          const applied = await this.applyCoupon(
            em,
            userId,
            dto.userCouponId,
            amount,
          );
          couponDiscount = applied.discount;
          couponTitle = applied.title;
          finalAmount = this.roundMoney(amount - couponDiscount);
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
          amount: finalAmount,
          originalAmount,
          userCouponId: dto.userCouponId ?? null,
          couponTitle,
          couponDiscount,
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

  /**
   * 在创建预约的事务内校验并使用优惠券：
   * 校验归属/状态/有效期/门槛 → 计算抵扣 → 将券标记为已使用。
   * 对用户券行加悲观锁，防止同一张券并发重复使用。
   */
  private async applyCoupon(
    em: EntityManager,
    userId: number,
    userCouponId: number,
    amount: number,
  ): Promise<{ discount: number; title: string }> {
    const ownedRepo = em.getRepository(UserCoupon);
    const couponRepo = em.getRepository(Coupon);

    const owned = await ownedRepo.findOne({
      where: { id: userCouponId, userId },
      lock: { mode: 'pessimistic_write' },
    });
    if (!owned || owned.status !== 'unused') {
      throw new BadRequestException('优惠券不可用（未领取或已使用）');
    }

    const coupon = await couponRepo.findOneBy({ id: owned.couponId });
    if (!coupon || !coupon.enabled || coupon.expireAt <= new Date()) {
      throw new BadRequestException('优惠券不存在或已过期');
    }

    const threshold = this.parseCouponThreshold(coupon.threshold);
    if (amount < threshold) {
      throw new BadRequestException(
        `订单金额未满足优惠券使用门槛（${coupon.threshold}）`,
      );
    }

    const parsed = this.parseCouponAmount(coupon.amount);
    let discount =
      parsed.kind === 'percent'
        ? amount * (1 - parsed.value / 10)
        : Math.min(parsed.value, amount);
    discount = this.roundMoney(Math.max(0, discount));

    owned.status = 'used';
    owned.usedAt = new Date();
    await ownedRepo.save(owned);

    return { discount, title: coupon.title };
  }

  /** 解析券额：`¥20` → 现金 20；`8.8 折` → 88% 支付 */
  private parseCouponAmount(raw: string): {
    kind: 'cash' | 'percent';
    value: number;
  } {
    const percent = raw.match(/(\d+(?:\.\d+)?)\s*折/);
    if (percent) return { kind: 'percent', value: parseFloat(percent[1]) };
    const cash = raw.match(/(\d+(?:\.\d+)?)/);
    return { kind: 'cash', value: cash ? parseFloat(cash[1]) : 0 };
  }

  /** 解析使用门槛：`无门槛` → 0；`满 ¥100 可用` → 100 */
  private parseCouponThreshold(raw: string): number {
    if (/无门槛/.test(raw)) return 0;
    const m = raw.match(/(\d+(?:\.\d+)?)/);
    return m ? parseFloat(m[1]) : 0;
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

  /** 我的预约列表（分页，按时间倒序） */
  async myList(
    userId: number,
    page = 1,
    pageSize = 20,
  ): Promise<{ items: Appointment[]; total: number }> {
    const [items, total] = await this.appointments.findAndCount({
      where: { userId },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
    return { items, total };
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
    const saved = await this.appointments.save(appt);
    this.broadcastAppointment(saved);
    return saved;
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
    // 结束时间固定为预约时段（不因迟到顺延），计时剩余 = 结束时间 - 扫码时间
    appt.serviceEndTime = this.scheduledEnd(appt);
    if (operatorId) appt.checkedInBy = operatorId;
    const saved = await this.appointments.save(appt);
    this.broadcastAppointment(saved);
    return saved;
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
    appt.serviceEndTime = this.scheduledEnd(appt);
    const saved = await this.appointments.save(appt);
    this.broadcastAppointment(saved);
    return saved;
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
    const saved = await this.appointments.save(appt);
    this.broadcastAppointment(saved);
    return saved;
  }

  /** 按预约码查询（运营/核销用） */
  async findByCode(code: string): Promise<Appointment> {
    const appt = await this.appointments.findOneBy({ code });
    if (!appt) throw new NotFoundException('预约码无效');
    return appt;
  }

  /** 管理端：预约列表（分页，可按状态/门店/日期筛选），附带用户邮箱/昵称 */
  async adminFindAll(
    filters?: {
      status?: string;
      storeId?: string;
      date?: string;
      keyword?: string;
      code?: string;
    },
    page = 1,
    pageSize = 20,
  ): Promise<
    [Array<Appointment & { userEmail?: string; userNickname?: string }>, number]
  > {
    const where: any = {};
    if (filters?.status) where.status = filters.status;
    if (filters?.storeId) where.storeId = parseInt(filters.storeId, 10);
    if (filters?.date) where.date = filters.date;
    if (filters?.code?.trim()) where.code = filters.code.trim();
    if (filters?.keyword?.trim()) {
      const matched = await this.users.findByKeyword(filters.keyword);
      const userIds = matched.map((u) => u.id);
      if (!userIds.length) return [[], 0];
      where.userId = In(userIds);
    }
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
          userEmail: user?.email ?? undefined,
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
    const saved = await this.appointments.save(appt);
    this.broadcastAppointment(saved);
    return saved;
  }

  /** 管理端核销（按 ID，店员代操作）：核销即上钟，扫码/输码即开始计时 */
  async adminCheckIn(id: number, operatorId?: number): Promise<Appointment> {
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
    const now = new Date();
    appt.status = 'in_service';
    appt.checkInTime = now;
    appt.serviceStartTime = now;
    appt.serviceEndTime = this.scheduledEnd(appt);
    if (operatorId) appt.checkedInBy = operatorId;
    const saved = await this.appointments.save(appt);
    this.broadcastAppointment(saved);
    return saved;
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
    appt.serviceEndTime = this.scheduledEnd(appt);
    const saved = await this.appointments.save(appt);
    this.broadcastAppointment(saved);
    return saved;
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
    const saved = await this.appointments.save(appt);
    this.broadcastAppointment(saved);
    return saved;
  }

  /** 查询某门店某日桌位可用性：返回每个桌位已占用时段窗口，客户端按预约时段重叠判断 */
  async availability(storeId: number, date: string) {
    const store = await this.stores.findOneBy({ id: storeId, enabled: true });
    if (!store) throw new NotFoundException('门店不存在');

    const tables = await this.tables.find({
      where: { storeId, enabled: true },
      order: { id: 'ASC' },
    });
    const taken = await this.appointments.find({
      where: {
        storeId,
        date,
        status: Not(In(['cancelled', 'completed'])),
      },
    });
    // 按桌位聚合占用窗口（一单多桌：预约的每张桌都算占用）
    const windowByTable = new Map<
      number,
      Array<{ startTime: string; endTime: string; status: string }>
    >();
    for (const a of taken) {
      const ids = a.tables?.length
        ? a.tables.map((t) => t.id)
        : a.tableId != null
          ? [a.tableId]
          : [];
      for (const id of ids) {
        if (!windowByTable.has(id)) windowByTable.set(id, []);
        windowByTable.get(id)!.push({
          startTime: a.startTime,
          endTime: a.endTime,
          status: a.status,
        });
      }
    }

    return tables.map((t) => ({
      id: t.id,
      name: t.name,
      capacity: t.capacity,
      bookedWindows: windowByTable.get(t.id) ?? [],
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
