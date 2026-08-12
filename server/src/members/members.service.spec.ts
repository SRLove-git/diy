import { BadRequestException, NotFoundException } from '@nestjs/common';
import { MembersService } from './members.service';

function buildService() {
  const plans = { findOneBy: jest.fn() };
  const memberships = {
    findOneBy: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
  };
  const coupons = {};
  const userCoupons = {};
  const experiences = {};
  const orders = {
    create: jest.fn(),
    save: jest.fn(),
    find: jest.fn(),
    findOne: jest.fn(),
    findOneBy: jest.fn(),
    findAndCount: jest.fn(),
  };
  const dataSource = {
    transaction: jest.fn((cb: (manager: unknown) => Promise<unknown>) =>
      cb({
        getRepository: jest.fn(() => orders),
      }),
    ),
  };
  const users = { findByKeyword: jest.fn(), findByIds: jest.fn() };
  const svc = new MembersService(
    plans as never,
    memberships as never,
    coupons as never,
    userCoupons as never,
    experiences as never,
    orders as never,
    dataSource as never,
    users as never,
  );
  return { svc, plans, memberships, orders, users };
}

describe('MembersService', () => {
  describe('purchase', () => {
    it('提交订单只生成待确认申请，不直接开通会员', async () => {
      const m = buildService();
      m.plans.findOneBy.mockResolvedValue({
        id: 1,
        name: '月卡会员',
        durationDays: 30,
        price: '19.90',
        enabled: true,
      });
      m.orders.create.mockImplementation((data: unknown) => ({
        status: 'pending',
        ...(data as object),
      }));
      m.orders.save.mockImplementation((x: unknown) => Promise.resolve(x));

      const result = await m.svc.purchase(7, 1);

      expect(result.status).toBe('pending');
      expect(result.planName).toBe('月卡会员');
      expect(result.amount).toBe(19.9);
      expect(m.memberships.save).not.toHaveBeenCalled();
    });

    it('套餐不存在时拒绝下单', async () => {
      const m = buildService();
      m.plans.findOneBy.mockResolvedValue(null);

      await expect(m.svc.purchase(7, 999)).rejects.toThrow(NotFoundException);
    });

    it('已有待确认申请时拒绝再次提交（开通/续费同一规则）', async () => {
      const m = buildService();
      m.plans.findOneBy.mockResolvedValue({
        id: 1,
        name: '月卡会员',
        durationDays: 30,
        price: '19.90',
        enabled: true,
      });
      m.orders.findOne.mockResolvedValue({
        id: 9,
        userId: 7,
        status: 'pending',
      });

      await expect(m.svc.purchase(7, 1)).rejects.toThrow(BadRequestException);
      expect(m.orders.create).not.toHaveBeenCalled();
      expect(m.orders.save).not.toHaveBeenCalled();
    });
  });

  describe('adminConfirmOrder', () => {
    it('确认待申请：开通会员并将申请置为已开通', async () => {
      const m = buildService();
      m.orders.findOneBy.mockResolvedValue({
        id: 1,
        userId: 7,
        planId: 1,
        planName: '月卡会员',
        durationDays: 30,
        amount: 19.9,
        status: 'pending',
      });
      // 第一次查询（是否已有会员）返回 null；确认开通保存后，
      // myMembership 再查时应返回刚创建的会员记录。
      let saved: Record<string, unknown> | null = null;
      m.memberships.findOneBy.mockImplementation(() => saved);
      m.memberships.create.mockImplementation((data: unknown) => {
        saved = { ...(data as object) };
        return saved;
      });
      m.memberships.save.mockImplementation((x: unknown) => {
        saved = x as Record<string, unknown>;
        return x;
      });
      m.orders.save.mockImplementation((x: unknown) => Promise.resolve(x));

      const result = await m.svc.adminConfirmOrder(1);

      expect(result.status).toBe('active');
      expect(m.memberships.create).toHaveBeenCalledWith(
        expect.objectContaining({ userId: 7, memberNo: 'M00000007' }),
      );
      expect(m.orders.save).toHaveBeenCalledWith(
        expect.objectContaining({ status: 'confirmed' }),
      );
    });

    it('续费：从当前有效期顺延，不覆盖已有会员期', async () => {
      const m = buildService();
      const existingExpire = new Date(Date.now() + 10 * 86400000);
      m.orders.findOneBy.mockResolvedValue({
        id: 1,
        userId: 7,
        planId: 1,
        planName: '月卡会员',
        durationDays: 30,
        amount: 19.9,
        status: 'pending',
      });
      m.memberships.findOneBy.mockResolvedValue({
        userId: 7,
        expireAt: existingExpire,
      });
      m.memberships.save.mockImplementation((x: unknown) => Promise.resolve(x));
      m.orders.save.mockImplementation((x: unknown) => Promise.resolve(x));

      const result = await m.svc.adminConfirmOrder(1);

      const expected = new Date(existingExpire.getTime() + 30 * 86400000);
      // 已确认开通必然返回有效会员记录，expireAt 为 Date（类型联合含 null，此处断言非空）
      expect(result.expireAt).toBeInstanceOf(Date);
      expect((result.expireAt as Date).getTime()).toBe(expected.getTime());
    });

    it('已确认的申请不可重复确认', async () => {
      const m = buildService();
      m.orders.findOneBy.mockResolvedValue({
        id: 1,
        userId: 7,
        status: 'confirmed',
      });

      await expect(m.svc.adminConfirmOrder(1)).rejects.toThrow(
        BadRequestException,
      );
    });
  });

  describe('adminCancelOrder', () => {
    it('待确认申请可取消', async () => {
      const m = buildService();
      m.orders.findOneBy.mockResolvedValue({
        id: 1,
        userId: 7,
        status: 'pending',
      });
      m.orders.save.mockImplementation((x: unknown) => Promise.resolve(x));

      const result = await m.svc.adminCancelOrder(1);

      expect(result.status).toBe('cancelled');
    });

    it('已确认的申请不可取消', async () => {
      const m = buildService();
      m.orders.findOneBy.mockResolvedValue({
        id: 1,
        userId: 7,
        status: 'confirmed',
      });

      await expect(m.svc.adminCancelOrder(1)).rejects.toThrow(
        BadRequestException,
      );
    });
  });
});
