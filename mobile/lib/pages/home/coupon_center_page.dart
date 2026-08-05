import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/post_api.dart';
import '../../features/member/data/api_member_repository.dart';
import '../../features/member/domain/member_models.dart';
import '../../features/member/domain/member_repository.dart';
import '../../widgets/state_widgets.dart';

/// 领券中心
///
/// 展示平台可领优惠券，支持一键领取（会员专享券需会员身份，
/// 后端校验失败时提示原因）。
class CouponCenterPage extends StatefulWidget {
  const CouponCenterPage({super.key});

  @override
  State<CouponCenterPage> createState() => _CouponCenterPageState();
}

class _CouponCenterPageState extends State<CouponCenterPage> {
  final MemberRepository _repo = const ApiMemberRepository();

  List<MemberCoupon> _coupons = [];
  bool _loading = true;
  String? _error;
  final Set<String> _receiving = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final coupons = await _repo.fetchCoupons();
      if (!mounted) return;
      setState(() {
        _coupons = coupons;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '加载失败，请重试';
        });
      }
    }
  }

  Future<void> _receive(MemberCoupon coupon) async {
    if (coupon.received || _receiving.contains(coupon.id)) return;
    setState(() => _receiving.add(coupon.id));
    try {
      await _repo.receiveCoupon(coupon.id);
      if (!mounted) return;
      setState(() {
        _coupons = [
          for (final c in _coupons)
            c.id == coupon.id ? c.copyWith(received: true) : c,
        ];
      });
      _toast('${coupon.title} 领取成功');
    } catch (e) {
      if (!mounted) return;
      final message = e is DioException ? PostApi.messageOf(e) : '领取失败，请稍后再试';
      _toast(message);
    } finally {
      if (mounted) setState(() => _receiving.remove(coupon.id));
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('领券中心')),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(AppColors colors) {
    if (_loading) return const LoadingWidget(message: '加载优惠券…');
    if (_error != null) {
      return AppErrorWidget(message: _error!, onRetry: _load);
    }
    if (_coupons.isEmpty) {
      return const EmptyWidget(
        icon: Icons.redeem_outlined,
        message: '暂无可用优惠券',
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _coupons.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final coupon = _coupons[index];
          return _CouponCard(
            coupon: coupon,
            busy: _receiving.contains(coupon.id),
            onReceive: () => _receive(coupon),
          );
        },
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.coupon,
    required this.busy,
    required this.onReceive,
  });

  final MemberCoupon coupon;
  final bool busy;
  final VoidCallback onReceive;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // 券额区
          Container(
            width: 96,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
            ),
            child: Column(
              children: [
                Text(
                  coupon.amount,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  coupon.threshold,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          // 券信息区
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          coupon.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      if (coupon.membersOnly) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '会员专享',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Palette.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '有效期至 ${_formatDate(coupon.expireAt)}',
                    style: TextStyle(fontSize: 11, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: coupon.received
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: colors.placeholder,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '已领取',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.textSecondary,
                              ),
                            ),
                          )
                        : FilledButton(
                            onPressed: busy ? null : onReceive,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 30),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              busy ? '领取中…' : '立即领取',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}
