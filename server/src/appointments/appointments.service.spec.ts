import { BadRequestException } from '@nestjs/common';
import { Activity } from '../activities/activity.entity';
import { ActivitySession } from '../activities/activity-session.entity';
import { Coupon, UserCoupon } from '../members/coupon.entity';
import { Membership } from '../members/membership.entity';
import { Store } from '../stores/store.entity';
import { StorePackage } from '../stores/store-package.entity';
import { StoreTable } from '../stores/store-table.entity';
import { Appointment } from './appointment.entity';
import { AppointmentsService } from './appointments.service';

function dateStr(offsetDays = 0): string {
  const d = new Date();
  d.setDate(d.getDate() + offsetDays);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(
    d.getDate(),
  ).padStart(2, '0')}`;
}

function timeStr(offsetMs: number): string {
  const d = new Date(Date.now() + offsetMs);
  return `${String(d.getHours()).padStart(2, '0')}:${String(
    d.getMinutes(),
  ).padStart(2, '0')}`;
}

function buildService() {
  const appointments = {
    createQueryBuilder: jest.fn(),
    save: jest.fn(),
    findOneBy: jest.fn(),
    findAndCount: jest.fn(),
    find: jest.fn(),
    findBy: jest.fn(),
  };
  const stores = { findOneBy: jest.fn() };
  const tables = { find: jest.fn() };
  const packages = { findOneBy: jest.fn() };
  const activities = { findOneBy: jest.fn() };
  const activitySessionsRepo = { findOneBy: jest.fn(), find: jest.fn() };
  const memberships = { findOneBy: jest.fn() };
  const users = {};
  const gateway = { sendAppointment: jest.fn() };
  const redis = {
    set: jest.fn(),
    del: jest.fn(),
    incr: jest.fn(),
    expire: jest.fn(),
    exists: jest.fn(),
  };
  redis.del.mockResolvedValue(1);
  redis.set.mockResolvedValue('OK');
  const userCouponRepo = { findOne: jest.fn(), save: jest.fn() };
  const couponRepo = { findOneBy: jest.fn() };
  const em = {
    find: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
    findOne: jest.fn(),
    findOneBy: jest.fn(),
    getRepository: jest.fn((cls: unknown) => {
      if (cls === UserCoupon) return userCouponRepo;
      if (cls === Coupon) return couponRepo;
      return {};
    }),
  };
  const dataSource = { transaction: jest.fn((cb) => cb(em)) };

  const svc = new AppointmentsService(
    appointments as never,
    stores as never,
    tables as never,
    packages as never,
    activities as never,
    activitySessionsRepo as never,
    memberships as never,
    users as never,
    gateway as never,
    redis as never,
    dataSource as never,
  );

  return {
    svc,
    appointments,
    stores,
    tables,
    memberships,
    redis,
    userCouponRepo,
    couponRepo,
    em,
  };
}

const baseDto = {
  storeId: 1,
  tableId: 1,
  peopleCount: 2,
  date: dateStr(1),
  startTime: '10:00',
  durationHours: 2,
};

describe('AppointmentsService', () => {
  describe('createStore', () => {
    it('无冲突时创建预约：金额按整数分计算、生成预约码、释放锁', async () => {
      const m = buildService();
      m.stores.findOneBy.mockResolvedValue({
        id: 1,
        name: '门店A',
        businessHours: '09:00-21:00',
        price: 39.9,
        memberPrice: null,
        allDayPrice: null,
      });
      m.tables.find.mockResolvedValue([{ id: 1, name: 'A1', capacity: 4 }]);
      m.memberships.findOneBy.mockResolvedValue(null);
      m.redis.set.mockResolvedValue('OK');
      m.em.find.mockResolvedValue([]);
      m.em.findOne.mockResolvedValue(null);
      m.em.create.mockImplementation((_cls: unknown, data: Record<string, unknown>) => ({
        status: 'booked',
        ...data,
      }));
      m.em.save.mockImplementation((x: unknown) => Promise.resolve(x));

      const result = (await m.svc.create(7, baseDto as never)) as Appointment;

      expect(result.status).toBe('booked');
      expect(result.code).toMatch(/^\d{6}$/);
      // 39.9 元/人/小时 × 2 人 × 2 小时 = 159.6
      expect(result.amount).toBe(159.6);
      expect(result.originalAmount).toBe(159.6);
      expect(m.em.save).toHaveBeenCalled();
      expect(m.redis.del).toHaveBeenCalled(); // 无论成败释放分布式锁
    });

    it('同店同桌同时段重叠时拒绝创建（防超卖）', async () => {
      const m = buildService();
      m.stores.findOneBy.mockResolvedValue({
        id: 1,
        name: '门店A',
        businessHours: '09:00-21:00',
        price: 39.9,
        memberPrice: null,
        allDayPrice: null,
      });
      m.tables.find.mockResolvedValue([{ id: 1, name: 'A1', capacity: 4 }]);
      m.memberships.findOneBy.mockResolvedValue(null);
      m.redis.set.mockResolvedValue('OK');
      m.em.find.mockResolvedValue([
        {
          id: 9,
          tableId: 1,
          tables: [{ id: 1 }],
          startTime: '09:30',
          endTime: '11:00',
          tableName: 'A1',
        },
      ]);

      await expect(
        m.svc.create(7, {
          ...baseDto,
          startTime: '10:00',
          durationHours: 1,
        } as never),
      ).rejects.toThrow(BadRequestException);
    });

    it('拒绝预约已过去的时段（服务端兜底）', async () => {
      const m = buildService();
      m.stores.findOneBy.mockResolvedValue({
        id: 1,
        name: '门店A',
        businessHours: '09:00-21:00',
        price: 39.9,
        memberPrice: null,
        allDayPrice: null,
      });
      m.tables.find.mockResolvedValue([{ id: 1, name: 'A1', capacity: 4 }]);
      m.memberships.findOneBy.mockResolvedValue(null);

      await expect(
        m.svc.create(7, {
          ...baseDto,
          date: dateStr(0),
          startTime: '00:00',
          durationHours: 1,
        } as never),
      ).rejects.toThrow(BadRequestException);
    });

    it('使用优惠券：抵扣后金额与券状态正确', async () => {
      const m = buildService();
      m.stores.findOneBy.mockResolvedValue({
        id: 1,
        name: '门店A',
        businessHours: '09:00-21:00',
        price: 39.9,
        memberPrice: null,
        allDayPrice: null,
      });
      m.tables.find.mockResolvedValue([{ id: 1, name: 'A1', capacity: 4 }]);
      m.memberships.findOneBy.mockResolvedValue(null);
      m.redis.set.mockResolvedValue('OK');
      m.em.find.mockResolvedValue([]);
      m.em.findOne.mockResolvedValue(null);
      m.em.create.mockImplementation((_cls: unknown, data: Record<string, unknown>) => ({
        status: 'booked',
        ...data,
      }));
      m.em.save.mockImplementation((x: unknown) => Promise.resolve(x));
      m.userCouponRepo.findOne.mockResolvedValue({
        id: 9,
        userId: 7,
        couponId: 5,
        status: 'unused',
      });
      m.couponRepo.findOneBy.mockResolvedValue({
        id: 5,
        title: '满100减20',
        amount: '¥20',
        threshold: '无门槛',
        enabled: true,
        expireAt: new Date(Date.now() + 86400_000),
      });

      const result = (await m.svc.create(
        7,
        { ...baseDto, userCouponId: 9 } as never,
      )) as Appointment;

      expect(result.amount).toBe(139.6); // 159.6 - 20
      expect(result.couponDiscount).toBe(20);
      expect(result.couponTitle).toBe('满100减20');
      expect(m.userCouponRepo.save).toHaveBeenCalledWith(
        expect.objectContaining({ status: 'used' }),
      );
    });
  });

  describe('checkIn', () => {
    it('booked → in_service：记录上钟/下钟时间', async () => {
      const m = buildService();
      const endTime = timeStr(2 * 3600_000);
      m.appointments.findOneBy.mockResolvedValue({
        id: 1,
        code: '123456',
        userId: 7,
        status: 'booked',
        date: dateStr(0),
        startTime: '09:00',
        endTime,
        scheduledEnd: () => new Date(`${dateStr(0)}T${endTime}:00`),
      });
      m.appointments.save.mockImplementation((x: unknown) =>
        Promise.resolve(x),
      );

      const result = (await m.svc.checkIn('123456', 7)) as Appointment;

      expect(result.status).toBe('in_service');
      expect(result.checkInTime).toBeInstanceOf(Date);
      expect(result.serviceStartTime).toBeInstanceOf(Date);
      expect(result.checkedInBy).toBe(7);
      expect(m.appointments.save).toHaveBeenCalled();
    });

    it('已核销的预约不可重复核销', async () => {
      const m = buildService();
      m.appointments.findOneBy.mockResolvedValue({
        id: 1,
        code: '123456',
        status: 'in_service',
      });

      await expect(m.svc.checkIn('123456', 7)).rejects.toThrow(
        BadRequestException,
      );
    });
  });

  describe('autoClockoutExpired', () => {
    it('只把已过结束时刻的服务中预约置为 completed', async () => {
      const m = buildService();
      const expired = {
        id: 1,
        date: dateStr(-1),
        startTime: '09:00',
        endTime: '18:00',
        status: 'in_service',
      };
      const qb = {
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        getMany: jest.fn().mockResolvedValue([expired]),
      };
      m.appointments.createQueryBuilder.mockReturnValue(qb);
      m.appointments.save.mockImplementation((x: unknown) =>
        Promise.resolve(x),
      );

      const count = await m.svc.autoClockoutExpired();

      expect(count).toBe(1);
      expect(expired.status).toBe('completed');
      expect(m.appointments.save).toHaveBeenCalledWith(expired);
    });
  });
});
