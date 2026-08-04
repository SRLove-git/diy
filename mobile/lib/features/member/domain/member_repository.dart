import 'member_models.dart';

/// 会员数据仓库抽象接口
///
/// 页面只依赖该抽象，不感知数据来源：
/// 当前接入 `MockMemberRepository` 演示，后续接入后端时
/// 新建 `ApiMemberRepository` 实现同一接口即可无缝替换。
abstract interface class MemberRepository {
  /// 我的会员信息（会员编号 / 有效期 / 状态）
  Future<MyMembership> fetchMyMembership();

  /// 不同期限的会员套餐及价格
  Future<List<MemberPlan>> fetchPlans();

  /// 会员专属预约 / 到店体验价格
  Future<List<MemberExperience>> fetchExperiences();

  /// 会员优惠券
  Future<List<MemberCoupon>> fetchCoupons();

  /// 我的卡包
  Future<List<MemberWalletCoupon>> fetchWallet();

  /// 领取优惠券
  Future<void> receiveCoupon(String couponId);

  /// 会员专属活动
  Future<List<MemberActivity>> fetchActivities();

  /// 开通 / 续费套餐，返回开通后的最新会员信息
  Future<MyMembership> purchase(String planId);
}
