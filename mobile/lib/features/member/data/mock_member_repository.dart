import '../domain/member_models.dart';
import '../domain/member_repository.dart';

/// Mock 仓库实现
///
/// 模拟网络延迟与本地开通 / 续费状态，用于 UI 联调演示。
/// 后续接入后端：新建 `ApiMemberRepository implements MemberRepository`，
/// 将页面依赖注入处替换即可，页面代码无需改动。
class MockMemberRepository implements MemberRepository {
  static const _latency = Duration(milliseconds: 450);

  /// 当前会员状态（模拟服务端持久化）
  MyMembership _membership = MyMembership(
    memberNo: 'NO.202608040126',
    levelName: '黄金会员',
    status: MemberStatus.active,
    expireAt: DateTime(2026, 9, 12),
  );

  /// 会员套餐：月卡 / 季卡 / 年卡
  static const plans = [
    MemberPlan(
      id: 'monthly',
      name: '月卡',
      durationDays: 30,
      price: 38,
      originalPrice: 58,
      benefits: [
        '到店体验项目会员专属价',
        '每月 2 张会员优惠券',
        '生日当月双倍积分',
      ],
    ),
    MemberPlan(
      id: 'quarterly',
      name: '季卡',
      durationDays: 90,
      price: 98,
      originalPrice: 174,
      badge: '推荐',
      recommended: true,
      benefits: [
        '到店体验项目会员专属价',
        '每月 3 张会员优惠券',
        '专属活动优先报名',
        '生日当月双倍积分',
      ],
    ),
    MemberPlan(
      id: 'yearly',
      name: '年卡',
      durationDays: 365,
      price: 328,
      originalPrice: 696,
      badge: '最划算',
      benefits: [
        '到店体验项目会员专属价',
        '每月 5 张会员优惠券',
        '专属活动优先报名 + 免排队',
        '生日当月双倍积分 + 手作礼盒',
        '每月 1 杯免费饮品',
      ],
    ),
  ];

  /// 会员专属预约 / 到店体验价格
  static const experiences = [
    MemberExperience(
      name: '奶油胶手机壳 DIY',
      desc: '含手机壳材料一份，成品可带走',
      memberPrice: 49,
      normalPrice: 68,
      quota: 2,
    ),
    MemberExperience(
      name: '陶艺拉坯体验',
      desc: '含拉坯 + 上釉，作品烧制寄送',
      memberPrice: 59,
      normalPrice: 88,
      quota: 1,
    ),
    MemberExperience(
      name: '拼豆挂件 DIY',
      desc: '含拼豆材料包，成品可带走',
      memberPrice: 29,
      normalPrice: 39,
      quota: 3,
    ),
    MemberExperience(
      name: '香薰蜡烛手作',
      desc: '含精油与模具，成品可带走',
      memberPrice: 79,
      normalPrice: 109,
      quota: 1,
    ),
  ];

  /// 会员优惠券
  static final coupons = [
    MemberCoupon(
      id: 'c1',
      title: '新人专享券',
      amount: '¥20',
      threshold: '满 ¥100 可用',
      expireAt: DateTime(2026, 8, 31),
    ),
    MemberCoupon(
      id: 'c2',
      title: '会员 8.8 折券',
      amount: '8.8 折',
      threshold: '无门槛',
      expireAt: DateTime(2026, 8, 20),
    ),
    MemberCoupon(
      id: 'c3',
      title: '满减专享券',
      amount: '¥30',
      threshold: '满 ¥200 可用',
      expireAt: DateTime(2026, 9, 30),
    ),
  ];

  /// 会员专属活动
  static const activities = [
    MemberActivity(
      id: 'a1',
      title: '周末会员沙龙「奶油胶手作日」',
      date: '08-16 14:00',
      desc: '会员免费参与，到场即送材料包一份，成品可带走。',
      tag: '限会员',
    ),
    MemberActivity(
      id: 'a2',
      title: '拼豆作品大赛',
      date: '08-22 起',
      desc: '上传拼豆作品参与评选，会员投稿双倍积分，前三名赢大奖。',
      tag: '双倍积分',
    ),
    MemberActivity(
      id: 'a3',
      title: '中秋月饼 DIY 特别场',
      date: '09-06 起',
      desc: '会员早鸟预约享 8 折，含月饼礼盒一份。',
      tag: '早鸟 8 折',
    ),
  ];

  Future<T> _delay<T>(T value) => Future.delayed(_latency, () => value);

  @override
  Future<MyMembership> fetchMyMembership() => _delay(_membership);

  @override
  Future<List<MemberPlan>> fetchPlans() => _delay(plans);

  @override
  Future<List<MemberExperience>> fetchExperiences() => _delay(experiences);

  @override
  Future<List<MemberCoupon>> fetchCoupons() => _delay(coupons);

  @override
  Future<List<MemberActivity>> fetchActivities() => _delay(activities);

  /// 开通 / 续费：有效期按所选套餐时长顺延
  @override
  Future<MyMembership> purchase(String planId) {
    final plan = plans.firstWhere((p) => p.id == planId);
    _membership = MyMembership(
      memberNo: _membership.memberNo,
      levelName: _membership.levelName,
      status: MemberStatus.active,
      expireAt: DateTime.now().add(Duration(days: plan.durationDays)),
    );
    return _delay(_membership);
  }
}
