import '../../../core/api_client.dart';
import '../domain/member_models.dart';
import '../domain/member_repository.dart';

class ApiMemberRepository implements MemberRepository {
  const ApiMemberRepository();

  @override
  Future<MyMembership> fetchMyMembership() async {
    final resp = await ApiClient.instance.get('/members/me');
    return MyMembership.fromJson(resp.data as Map<String, dynamic>);
  }

  @override
  Future<List<MemberPlan>> fetchPlans() async {
    final resp = await ApiClient.instance.get('/members/plans');
    return ((resp.data ?? []) as List)
        .map((item) => MemberPlan.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MemberExperience>> fetchExperiences() async {
    final resp = await ApiClient.instance.get('/members/experiences');
    return ((resp.data ?? []) as List)
        .map((item) => MemberExperience.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MemberCoupon>> fetchCoupons() async {
    final resp = await ApiClient.instance.get('/members/coupons');
    return ((resp.data ?? []) as List)
        .map((item) => MemberCoupon.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MemberWalletCoupon>> fetchWallet() async {
    final resp = await ApiClient.instance.get('/members/wallet');
    return ((resp.data ?? []) as List)
        .map((item) =>
            MemberWalletCoupon.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> receiveCoupon(String couponId) async {
    await ApiClient.instance.post('/members/coupons/$couponId/receive');
  }

  @override
  Future<List<MemberActivity>> fetchActivities() async {
    final resp = await ApiClient.instance.get('/activities');
    return ((resp.data ?? []) as List)
        .map((item) => MemberActivity.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MyMembership> purchase(String planId) async {
    final resp = await ApiClient.instance.post(
      '/members/purchase',
      data: {'planId': int.tryParse(planId) ?? 0},
    );
    return MyMembership.fromJson(resp.data as Map<String, dynamic>);
  }
}
