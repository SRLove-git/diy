/// 会员领域模型（会员套餐 / 专属体验价 / 优惠券 / 专属活动）
///
/// 与 UI / 数据源解耦：后续接入 API 时仅需替换 data 层实现，
/// 领域模型保持稳定，见 [MemberRepository]。
library;

/// 会员状态：未开通 / 生效中 / 已到期
enum MemberStatus {
  none,
  active,
  expired;

  static MemberStatus fromName(String? name) => switch (name) {
        'active' => MemberStatus.active,
        'expired' => MemberStatus.expired,
        _ => MemberStatus.none,
      };
}

/// 会员套餐（不同期限 + 对应价格）
class MemberPlan {
  const MemberPlan({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.price,
    required this.originalPrice,
    required this.benefits,
    this.badge,
    this.recommended = false,
  });

  final String id;

  /// 套餐名：月卡 / 季卡 / 年卡
  final String name;

  /// 套餐时长（天）
  final int durationDays;

  /// 售价
  final double price;

  /// 原价（划线价）
  final double originalPrice;

  /// 套餐权益列表
  final List<String> benefits;

  /// 角标，如 `推荐` / `最划算`，为空不展示
  final String? badge;

  /// 是否推荐（默认选中）
  final bool recommended;

  String get durationLabel => '$durationDays 天';

  factory MemberPlan.fromJson(Map<String, dynamic> json) => MemberPlan(
        id: '${json['id']}',
        name: (json['name'] ?? '') as String,
        durationDays: (json['durationDays'] ?? 0) as int,
        price: _toDouble(json['price']),
        originalPrice: _toDouble(json['originalPrice']),
        benefits: ((json['benefits'] ?? []) as List)
            .map((item) => item.toString())
            .toList(),
        badge: (json['badge'] as String?)?.trim().isEmpty == true
            ? null
            : json['badge'] as String?,
        recommended: json['recommended'] == true,
      );
}

/// 我的会员信息（会员编号 / 有效期 / 开通续费到期状态）
class MyMembership {
  const MyMembership({
    required this.memberNo,
    required this.levelName,
    required this.status,
    this.expireAt,
  });

  /// 会员编号
  final String memberNo;

  /// 会员等级，如 `黄金会员`
  final String levelName;

  /// 开通 / 续费 / 到期状态
  final MemberStatus status;

  /// 有效期截止日（未开通为 null）
  final DateTime? expireAt;

  /// 剩余有效天数（已到期 / 未开通为 0）
  int get remainingDays {
    if (expireAt == null || status == MemberStatus.expired) return 0;
    final days = expireAt!.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  factory MyMembership.fromJson(Map<String, dynamic> json) => MyMembership(
        memberNo: (json['memberNo'] ?? '') as String,
        levelName: (json['levelName'] ?? '手作会员') as String,
        status: MemberStatus.fromName(json['status'] as String?),
        expireAt: json['expireAt'] == null
            ? null
            : DateTime.tryParse(json['expireAt'].toString()),
      );
}

/// 会员专属预约 / 到店体验价格
class MemberExperience {
  const MemberExperience({
    required this.name,
    required this.desc,
    required this.memberPrice,
    required this.normalPrice,
    required this.quota,
  });

  /// 体验项目名
  final String name;

  /// 项目描述
  final String desc;

  /// 会员专属价
  final double memberPrice;

  /// 门市价（划线对比）
  final double normalPrice;

  /// 每月专属次数
  final int quota;

  factory MemberExperience.fromJson(Map<String, dynamic> json) =>
      MemberExperience(
        name: (json['name'] ?? '') as String,
        desc: (json['desc'] ?? '') as String,
        memberPrice: _toDouble(json['memberPrice']),
        normalPrice: _toDouble(json['normalPrice']),
        quota: (json['quota'] ?? 0) as int,
      );
}

/// 会员优惠券
class MemberCoupon {
  const MemberCoupon({
    required this.id,
    required this.title,
    required this.amount,
    required this.threshold,
    required this.expireAt,
    this.received = false,
    this.membersOnly = false,
  });

  final String id;

  /// 券名称
  final String title;

  /// 券额文案，如 `¥20` / `8.8 折`
  final String amount;

  /// 使用门槛，如 `满 100 可用` / `无门槛`
  final String threshold;

  /// 有效期截止日
  final DateTime expireAt;

  /// 是否已领取
  final bool received;

  /// 是否会员专享
  final bool membersOnly;

  MemberCoupon copyWith({bool? received}) => MemberCoupon(
        id: id,
        title: title,
        amount: amount,
        threshold: threshold,
        expireAt: expireAt,
        received: received ?? this.received,
        membersOnly: membersOnly,
      );

  factory MemberCoupon.fromJson(Map<String, dynamic> json) => MemberCoupon(
        id: '${json['id']}',
        title: (json['title'] ?? '') as String,
        amount: (json['amount'] ?? '') as String,
        threshold: (json['threshold'] ?? '') as String,
        expireAt: DateTime.tryParse(json['expireAt'].toString()) ??
            DateTime.now(),
        received: json['received'] == true,
        membersOnly: json['membersOnly'] == true,
      );
}

class MemberWalletCoupon {
  const MemberWalletCoupon({
    required this.userCouponId,
    required this.title,
    required this.amount,
    required this.threshold,
    required this.expireAt,
    required this.status,
    required this.receivedAt,
  });

  final String userCouponId;
  final String title;
  final String amount;
  final String threshold;
  final DateTime expireAt;
  final String status;
  final DateTime? receivedAt;

  factory MemberWalletCoupon.fromJson(Map<String, dynamic> json) =>
      MemberWalletCoupon(
        userCouponId: '${json['userCouponId']}',
        title: (json['title'] ?? '') as String,
        amount: (json['amount'] ?? '') as String,
        threshold: (json['threshold'] ?? '') as String,
        expireAt: DateTime.tryParse(json['expireAt'].toString()) ??
            DateTime.now(),
        status: (json['status'] ?? 'unused') as String,
        receivedAt: json['receivedAt'] == null
            ? null
            : DateTime.tryParse(json['receivedAt'].toString()),
      );
}

/// 会员专属活动
class MemberActivity {
  const MemberActivity({
    required this.id,
    required this.title,
    required this.date,
    required this.desc,
    required this.tag,
  });

  factory MemberActivity.fromJson(Map<String, dynamic> json) =>
      MemberActivity(
        id: '${json['id']}',
        title: (json['title'] ?? '') as String,
        date: (json['date'] ?? '') as String,
        desc: (json['desc'] ?? '') as String,
        tag: (json['tag'] ?? '') as String,
      );

  final String id;

  /// 活动名
  final String title;

  /// 活动时间，如 `08-16 14:00`
  final String date;

  /// 活动简介
  final String desc;

  /// 标签，如 `限会员` / `双倍积分`
  final String tag;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
