import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/appointment_api.dart';
import '../../features/home/presentation/palette.dart';
import '../../widgets/state_widgets.dart';
import '../booking/booking_flow_page.dart';

/// 活动专区
///
/// 展示平台近期活动：会员沙龙、作品大赛、节日 DIY 特别场等。
/// 活动数据来自服务端 /activities 接口（ApiMemberRepository.fetchActivities）。
class ActivityZonePage extends StatefulWidget {
  const ActivityZonePage({super.key});

  @override
  State<ActivityZonePage> createState() => _ActivityZonePageState();
}

class _ActivityZonePageState extends State<ActivityZonePage> {
  List<Activity> _activities = [];
  bool _loading = true;
  String? _error;

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
      final activities = await AppointmentApi.fetchAllActivities();
      if (!mounted) return;
      setState(() {
        _activities = activities;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '加载失败，请重试';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('活动专区')),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(AppColors colors) {
    if (_loading) return const LoadingWidget(message: '加载中…');
    if (_error != null) {
      return AppErrorWidget(message: _error!, onRetry: _load);
    }
    if (_activities.isEmpty) {
      return const EmptyWidget(
        icon: Icons.celebration_outlined,
        message: '暂无活动，敬请期待',
      );
    }
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        _buildHeroBanner(colors),
        const SizedBox(height: 24),
        _buildSectionHeader(colors),
        const SizedBox(height: 12),
        for (var index = 0; index < _activities.length; index++) ...[
          _ActivityCard(activity: _activities[index]),
          if (index != _activities.length - 1) const SizedBox(height: 12),
        ],
        const SizedBox(height: 20),
        Center(
          child: Text(
            '更多活动持续更新，敬请关注',
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBanner(AppColors colors) {
    return Container(
      height: 148,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
          gradient: Palette.gradientSunset,
        boxShadow: const [
          BoxShadow(
            color: Color(0x33B8A7FF),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -22,
            child: Icon(
              Icons.celebration_rounded,
              size: 120,
              color: Colors.white.withValues(alpha: 0.22),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Text(
                '活动专区',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '拼出乐趣 · 一起玩',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(AppColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '近期活动',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${_activities.length} 场进行中',
          style: TextStyle(fontSize: 12, color: colors.textSecondary),
        ),
        const Spacer(),
        Container(
          width: 28,
          height: 4,
          decoration: BoxDecoration(
            color: HomePalette.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.textPrimary),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D7A4754),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  activity.tag,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    activity.date,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            activity.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            activity.desc,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: colors.textSecondary,
            ),
          ),
          if (activity.bookable) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  activity.memberPrice != null
                      ? '会员 ${_fmtPrice(activity.memberPrice!)} / ${_fmtPrice(activity.price)}'
                      : '${_fmtPrice(activity.price)} /人',
                  style: TextStyle(
                    color: Palette.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const BookingFlowPage(initialType: 'activity'),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Palette.accent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('去预约'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

String _fmtPrice(double value) {
  if (value == value.roundToDouble()) return '¥${value.toInt()}';
  return '¥${value.toStringAsFixed(2)}';
}
