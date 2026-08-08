import 'package:flutter/material.dart';

import '../../api/api_client.dart';
import '../../api/models.dart';
import '../../api/services.dart';
import '../live_routes.dart';
import '../live_theme.dart';
import '../live_widgets.dart';

class ActivityListScreen extends StatefulWidget {
  const ActivityListScreen({super.key});

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  late Future<List<Activity>> _future;

  @override
  void initState() {
    super.initState();
    _future = ActivityService.instance.list();
  }

  void _retry() => setState(() => _future = ActivityService.instance.list());

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: FutureBuilder<List<Activity>>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Column(
              children: [
                const LiveAppBar(title: '活动专区'),
                Expanded(child: ErrorView(message: _msg(snap.error), onRetry: _retry)),
              ],
            );
          }
          if (!snap.hasData) {
            return const Column(
              children: [LiveAppBar(title: '活动专区'), Expanded(child: LoadingView())],
            );
          }
          final list = snap.data!;
          return Column(
            children: [
              const LiveAppBar(title: '活动专区'),
              Expanded(
                child: list.isEmpty
                    ? const EmptyView(text: '暂无活动')
                    : RefreshIndicator(
                        onRefresh: () async => _retry(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(18),
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) => _ActivityCard(
                            activity: list[i],
                            onTap: () => LiveRoutes.pushId(
                              context,
                              RoutePaths.activityDetail,
                              list[i].id,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity, required this.onTap});

  final Activity activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LiveColors.brandLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (activity.tag.isNotEmpty) TagChip(label: activity.tag, color: LiveColors.blue),
                if (activity.membersOnly) ...[
                  const SizedBox(width: 6),
                  const TagChip(label: '限会员', color: LiveColors.warning),
                ],
                const Spacer(),
                Text(
                  activity.date,
                  style: const TextStyle(fontSize: 12, color: LiveColors.brand, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              activity.title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: LiveColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              activity.desc.isEmpty ? '详情敬请期待' : activity.desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: LiveColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  activity.price > 0 ? '¥${activity.price.toStringAsFixed(0)}/人' : '免费',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: LiveColors.brand),
                ),
                if (activity.bookable) ...[
                  const Spacer(),
                  const Text('可预约', style: TextStyle(fontSize: 12, color: LiveColors.success)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityDetailScreen extends StatefulWidget {
  const ActivityDetailScreen({super.key, required this.activityId});

  final int activityId;

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  late Future<Activity> _future;
  ActivitySession? _session;
  final _noteCtrl = TextEditingController();
  int _people = 2;

  @override
  void initState() {
    super.initState();
    _future = ActivityService.instance.detail(widget.activityId);
  }

  void _retry() => setState(() {
        _future = ActivityService.instance.detail(widget.activityId);
        _session = null;
      });

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: FutureBuilder<Activity>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Column(
              children: [
                const LiveAppBar(title: '活动详情'),
                Expanded(child: ErrorView(message: _msg(snap.error), onRetry: _retry)),
              ],
            );
          }
          if (!snap.hasData) {
            return const Column(
              children: [LiveAppBar(title: '活动详情'), Expanded(child: LoadingView())],
            );
          }
          final activity = snap.data!;
          final sessions = activity.sessions;
          return Column(
            children: [
              const LiveAppBar(title: '活动详情'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            activity.title,
                            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: LiveColors.textPrimary),
                          ),
                        ),
                        if (activity.tag.isNotEmpty) TagChip(label: activity.tag),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${activity.date}${activity.address.isNotEmpty ? ' · ${activity.address}' : ''}',
                      style: const TextStyle(fontSize: 13, color: LiveColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: LiveColors.card,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        activity.desc.isEmpty ? '活动详情敬请期待' : activity.desc,
                        style: const TextStyle(fontSize: 13, color: LiveColors.textPrimary, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('价格', style: TextStyle(fontSize: 14, color: LiveColors.textSecondary)),
                        const Spacer(),
                        Text(
                          activity.price > 0 ? '¥${activity.price.toStringAsFixed(2)}/人' : '免费',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: LiveColors.brand),
                        ),
                        if (activity.memberPrice != null && activity.memberPrice! < activity.price)
                          Text(
                            '  会员 ¥${activity.memberPrice!.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 12, color: LiveColors.success),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (activity.bookable) ...[
                      const Text('选择场次', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      if (sessions.isEmpty)
                        const EmptyView(text: '暂无可约场次')
                      else
                        ...sessions.map((s) {
                          final sel = _session?.id == s.id;
                          final full = s.remainingCount <= 0;
                          return InkWell(
                            onTap: full ? null : () => setState(() => _session = s),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: sel ? LiveColors.brandLight : LiveColors.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: sel ? LiveColors.brand : LiveColors.divider,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    sel ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                    size: 18,
                                    color: sel ? LiveColors.brand : LiveColors.textTertiary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${s.date} ${s.startTime}-${s.endTime}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: LiveColors.textPrimary),
                                    ),
                                  ),
                                  Text(
                                    full
                                        ? '已满员'
                                        : '剩余 ${s.remainingCount}/${s.capacity}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: full ? LiveColors.danger : LiveColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 14),
                      const Text('人数', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: _people > 1
                                ? () => setState(() => _people--)
                                : null,
                            customBorder: const CircleBorder(),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _people > 1
                                    ? LiveColors.textPrimary
                                    : const Color(0xFFEFEFEF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.remove,
                                color: _people > 1
                                    ? Colors.white
                                    : LiveColors.textTertiary,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Text(
                              '$_people',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: LiveColors.textPrimary,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: _people < 8
                                ? () => setState(() => _people++)
                                : null,
                            customBorder: const CircleBorder(),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _people < 8
                                    ? LiveColors.textPrimary
                                    : const Color(0xFFEFEFEF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add,
                                color: _people < 8
                                    ? Colors.white
                                    : LiveColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _noteCtrl,
                        decoration: const InputDecoration(
                          hintText: '备注（选填），如：两人同行',
                        ),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: '立即预约',
                        onTap: _session == null
                            ? null
                            : () => LiveRoutes.push(
                                context,
                                RoutePaths.appointmentConfirm,
                                extra: {
                                  'type': 'activity',
                                  'activity': activity,
                                  'session': _session,
                                  'date': _session!.date,
                                  'peopleCount': _people,
                                  'note': _noteCtrl.text.trim(),
                                },
                              ),
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: LiveColors.card,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: LiveColors.textSecondary),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text('该活动暂不支持线上预约，敬请期待',
                                  style: TextStyle(fontSize: 13, color: LiveColors.textSecondary)),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _msg(Object? e) =>
    e is ApiException ? e.message : '加载失败，请确认后端服务已启动';
