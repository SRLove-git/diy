import { BadRequestException, Injectable, NotFoundException, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, In, MoreThan, Repository } from 'typeorm';
import { Coupon, UserCoupon } from './coupon.entity';
import { SaveCouponDto, SavePlanDto } from './member.dto';
import { MemberPlan } from './member-plan.entity';
import { Membership } from './membership.entity';

@Injectable()
export class MembersService implements OnModuleInit {
  constructor(
    @InjectRepository(MemberPlan) private readonly plans: Repository<MemberPlan>,
    @InjectRepository(Membership) private readonly memberships: Repository<Membership>,
    @InjectRepository(Coupon) private readonly coupons: Repository<Coupon>,
    @InjectRepository(UserCoupon) private readonly userCoupons: Repository<UserCoupon>,
    private readonly dataSource: DataSource,
  ) {}

  async onModuleInit() {
    if (await this.plans.count()) return;
    await this.plans.save([
      this.plans.create({ name: '月卡', durationDays: 30, price: '38', originalPrice: '58', benefits: ['会员专属体验价', '每月会员优惠券'], badge: '', recommended: false }),
      this.plans.create({ name: '季卡', durationDays: 90, price: '98', originalPrice: '174', benefits: ['会员专属体验价', '会员优惠券', '专属活动优先报名'], badge: '推荐', recommended: true }),
      this.plans.create({ name: '年卡', durationDays: 365, price: '328', originalPrice: '696', benefits: ['会员专属体验价', '会员优惠券', '专属活动优先报名', '每月免费饮品'], badge: '最划算', recommended: false }),
    ]);
  }

  listPlans(admin = false) {
    return this.plans.find({ where: admin ? {} : { enabled: true }, order: { durationDays: 'ASC' } });
  }

  async myMembership(userId: number) {
    const item = await this.memberships.findOneBy({ userId });
    if (!item) return { memberNo: '', levelName: '手作会员', status: 'none', expireAt: null };
    return { ...item, status: item.expireAt > new Date() ? 'active' : 'expired' };
  }

  async purchase(userId: number, planId: number) {
    const plan = await this.plans.findOneBy({ id: planId, enabled: true });
    if (!plan) throw new NotFoundException('套餐不存在或已下架');
    const current = await this.memberships.findOneBy({ userId });
    const now = new Date();
    const base = current?.expireAt && current.expireAt > now ? current.expireAt : now;
    const expireAt = new Date(base.getTime() + plan.durationDays * 86400000);
    const member = current ?? this.memberships.create({ userId, memberNo: `M${String(userId).padStart(8, '0')}`, levelName: '手作会员', expireAt });
    member.expireAt = expireAt;
    await this.memberships.save(member);
    return this.myMembership(userId);
  }

  async listCoupons(userId: number) {
    const [items, owned] = await Promise.all([
      this.coupons.find({ where: { enabled: true, expireAt: MoreThan(new Date()) }, order: { createdAt: 'DESC' } }),
      this.userCoupons.findBy({ userId }),
    ]);
    const ownedIds = new Set(owned.map((x) => x.couponId));
    return items.map((x) => ({ ...x, received: ownedIds.has(x.id) }));
  }

  async wallet(userId: number) {
    const rows = await this.userCoupons.find({ where: { userId }, order: { receivedAt: 'DESC' } });
    if (!rows.length) return [];
    const coupons = await this.coupons.findBy({ id: In(rows.map((x) => x.couponId)) });
    const map = new Map(coupons.map((x) => [x.id, x]));
    return rows.flatMap((x) => {
      const coupon = map.get(x.couponId);
      if (!coupon) return [];
      const status = x.status === 'unused' && coupon.expireAt <= new Date() ? 'expired' : x.status;
      return [{ ...coupon, userCouponId: x.id, status, receivedAt: x.receivedAt }];
    });
  }

  async receive(userId: number, couponId: number) {
    const active = await this.myMembership(userId);
    return this.dataSource.transaction(async (manager) => {
      const couponRepo = manager.getRepository(Coupon);
      const ownedRepo = manager.getRepository(UserCoupon);
      const coupon = await couponRepo.findOne({ where: { id: couponId }, lock: { mode: 'pessimistic_write' } });
      if (!coupon || !coupon.enabled || coupon.expireAt <= new Date()) throw new NotFoundException('优惠券不存在或已过期');
      if (coupon.membersOnly && active.status !== 'active') throw new BadRequestException('仅限有效会员领取');
      if (await ownedRepo.existsBy({ userId, couponId })) throw new BadRequestException('已经领取过了');
      if (coupon.stock <= 0) throw new BadRequestException('优惠券已领完');
      coupon.stock -= 1;
      await couponRepo.save(coupon);
      return ownedRepo.save(ownedRepo.create({ userId, couponId, status: 'unused', usedAt: null }));
    });
  }

  listMemberships(page = 1) {
    return this.memberships.findAndCount({
      order: { updatedAt: 'DESC' },
      skip: (page - 1) * 20,
      take: 20,
    });
  }

  listAllCoupons() {
    return this.coupons.find({ order: { createdAt: 'DESC' } });
  }

  savePlan(dto: SavePlanDto, id?: number) {
    return this.plans.save(
      this.plans.create({
        ...dto,
        id,
        price: String(dto.price),
        originalPrice: String(dto.originalPrice),
        badge: dto.badge ?? '',
        enabled: dto.enabled ?? true,
        recommended: dto.recommended ?? false,
      }),
    );
  }

  async togglePlan(id: number, enabled: boolean) {
    await this.plans.update(id, { enabled });
    return this.plans.findOneBy({ id });
  }

  saveCoupon(dto: SaveCouponDto, id?: number) {
    return this.coupons.save(
      this.coupons.create({
        ...dto,
        id,
        expireAt: new Date(dto.expireAt),
        membersOnly: dto.membersOnly ?? true,
        enabled: dto.enabled ?? true,
      }),
    );
  }

  async toggleCoupon(id: number, enabled: boolean) {
    await this.coupons.update(id, { enabled });
    return this.coupons.findOneBy({ id });
  }
}
