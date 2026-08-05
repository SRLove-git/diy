import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/admin_api.dart';
import '../../core/app_colors.dart';
import '../../widgets/state_widgets.dart';

/// 数据看板：核心指标卡片 + 近 7 天趋势表 + 简易柱状图（对齐网页管理端）
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  DashboardOverview? _overview;
  List<TrendItem> _trends = [];
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
      final results = await Future.wait([
        AdminApi.fetchOverview(),
        AdminApi.fetchTrends(),
      ]);
      if (!mounted) return;
      setState(() {
        _overview = results[0] as DashboardOverview;
        _trends = results[1] as List<TrendItem>;
      });
    } on DioException catch (e) {
      if (mounted) setState(() => _error = AdminApi.messageOf(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据看板'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingWidget();
    if (_error != null) {
      return AppErrorWidget(message: _error!, onRetry: _load);
    }
    final ov = _overview!;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 核心指标
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 7,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.9,
            ),
            itemBuilder: (context, i) => _MetricCard(
              label: _labels[i],
              value: _values(ov)[i],
              sub: _subs(ov)[i],
            ),
          ),
          const SizedBox(height: 24),
          Text('待办审核', style: _sectionTitle(context)),
          const SizedBox(height: 8),
          _PendingRow(pending: ov.pending),
          const SizedBox(height: 24),
          Text('近 7 天趋势', style: _sectionTitle(context)),
          const SizedBox(height: 8),
          _TrendTable(trends: _trends),
          const SizedBox(height: 24),
          Text('数据趋势图', style: _sectionTitle(context)),
          const SizedBox(height: 8),
          _TrendChart(trends: _trends),
          const SizedBox(height: 8),
          const _Legend(),
        ],
      ),
    );
  }

  static const _labels = [
    '累计用户',
    '累计预约',
    '核销中',
    '已完成订单',
    '累计作品',
    '今日互动',
    '短视频 / 照片',
  ];

  List<String> _values(DashboardOverview ov) => [
        '${ov.users.total}',
        '${ov.appointments.total}',
        '${ov.appointments.checkedIn}',
        '${ov.appointments.completed}',
        '${ov.community.totalPosts}',
        '${ov.community.todayLikes + ov.community.todayComments}',
        '${ov.videos.total}',
      ];

  List<String> _subs(DashboardOverview ov) => [
        '今日新增 ${ov.users.today}',
        '今日新增 ${ov.appointments.today}',
        '服务中 ${ov.appointments.inService}',
        '预约完成数',
        '今日 ${ov.community.todayPosts} 篇',
        '点赞 ${ov.community.todayLikes} · 评论 ${ov.community.todayComments}',
        '今日新增 ${ov.videos.today}',
      ];

  TextStyle _sectionTitle(BuildContext context) {
    final colors = AppColors.of(context);
    return TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary);
  }
}

class _PendingRow extends StatelessWidget {
  const _PendingRow({required this.pending});

  final ({int posts, int videos, int reports}) pending;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    Widget item(String label, int count) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Palette.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: colors.textSecondary),
                ),
              ],
            ),
          ),
        );

    return Row(
      children: [
        item('作品待审', pending.posts),
        const SizedBox(width: 10),
        item('视频待审', pending.videos),
        const SizedBox(width: 10),
        item('举报待处', pending.reports),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.sub,
  });

  final String label;
  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(sub, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
        ],
      ),
    );
  }
}

class _TrendTable extends StatelessWidget {
  const _TrendTable({required this.trends});

  final List<TrendItem> trends;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 表头
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: const [
                _Cell('日期', flex: 2),
                _Cell('注册', flex: 1),
                _Cell('预约', flex: 1),
                _Cell('作品', flex: 1),
                _Cell('赞', flex: 1),
                _Cell('评', flex: 1),
                _Cell('视频', flex: 1),
              ],
            ),
          ),
          Divider(height: 1, color: colors.divider),
          for (final t in trends)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  _Cell(t.date, flex: 2, alignLeft: true),
                  _Cell('${t.users}', flex: 1),
                  _Cell('${t.appointments}', flex: 1),
                  _Cell('${t.posts}', flex: 1),
                  _Cell('${t.likes}', flex: 1),
                  _Cell('${t.comments}', flex: 1),
                  _Cell('${t.videos}', flex: 1),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.text, {required this.flex, this.alignLeft = false});

  final String text;
  final int flex;
  final bool alignLeft;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: alignLeft ? TextAlign.left : TextAlign.center,
        style: TextStyle(fontSize: 12, color: colors.textPrimary),
      ),
    );
  }
}

/// 简易柱状图：每日 注册/预约/作品 三色柱
class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.trends});

  final List<TrendItem> trends;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    var maxVal = 1;
    for (final t in trends) {
      maxVal = maxVal > t.users ? maxVal : t.users;
      maxVal = maxVal > t.appointments ? maxVal : t.appointments;
      maxVal = maxVal > t.posts ? maxVal : t.posts;
      maxVal = maxVal > t.videos ? maxVal : t.videos;
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final t in trends)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _bar(t.users / maxVal, Palette.purple),
                        _bar(t.appointments / maxVal, Palette.primary),
                        _bar(t.posts / maxVal, Palette.success),
                        _bar(t.videos / maxVal, Palette.accent),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.date.length >= 10 ? t.date.substring(5) : t.date,
                    style: TextStyle(fontSize: 11, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _bar(double ratio, Color color) {
    // 高度按比例缩放，最小值保底可见
    final height = (ratio * 110).clamp(4, 110).toDouble();
    return Container(
      width: 12,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    Widget dot(Color c) => Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2)),
        );
    Widget item(Color c, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            dot(c),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
          ],
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        item(Palette.purple, '新注册'),
        const SizedBox(width: 20),
        item(Palette.primary, '新预约'),
        const SizedBox(width: 20),
        item(Palette.success, '新作品'),
        const SizedBox(width: 20),
        item(Palette.accent, '短视频'),
      ],
    );
  }
}
