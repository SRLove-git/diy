import 'package:flutter/material.dart';

import '../../api/api_client.dart';
import '../../api/chat_services.dart';
import '../../api/models.dart';
import '../../api/services.dart';
import '../live_routes.dart';
import '../live_theme.dart';
import '../live_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.root = false});

  final bool root;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<({List<Activity> activities, int unread})> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<({List<Activity> activities, int unread})> _load() async {
    final results = await Future.wait([
      ActivityService.instance.list(),
      NotificationService.instance.unreadCount().catchError((_) => 0),
    ]);
    return (
      activities: results[0] as List<Activity>,
      unread: results[1] as int,
    );
  }

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: FutureBuilder(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Column(
              children: [
                _TopBar(unread: 0),
                Expanded(
                  child: ErrorView(
                    message: snap.error is ApiException
                        ? (snap.error as ApiException).message
                        : '加载失败',
                    onRetry: _retry,
                  ),
                ),
              ],
            );
          }
          if (!snap.hasData) {
            return Column(
              children: [
                _TopBar(unread: 0),
                const Expanded(child: LoadingView()),
              ],
            );
          }
          final data = snap.data!;
          return RefreshIndicator(
            onRefresh: () async => _retry(),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                _TopBar(unread: data.unread),
                // 「拼豆」板块：入口卡（预约 / 到店 / 会员套餐）
                _SectionHeader(
                  title: '拼豆',
                  badge: '人气手作',
                  more: '查看全部 ›',
                  onMore: () => LiveRoutes.push(context, RoutePaths.activityList),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: _EntryCardsRow(
                    onTap: (key) {
                      switch (key) {
                        case 'appoint':
                          LiveRoutes.push(context, RoutePaths.storeList);
                        case 'checkin':
                          LiveRoutes.push(context, RoutePaths.storeCheckin);
                        case 'member':
                          LiveRoutes.push(context, RoutePaths.memberCenter);
                      }
                    },
                  ),
                ),
                // 「敬请期待」板块：直播专区 / 手作商城占位
                _SectionHeader(
                  title: '敬请期待',
                  trailing: '更多精彩即将上线',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: _ComingSoonRow(
                    onTap: () => showLiveSnack(context, '敬请期待，更多精彩即将上线'),
                  ),
                ),
                // 「活动推荐」板块
                _SectionHeader(
                  title: '活动推荐',
                  more: '查看全部 ›',
                  onMore: () => LiveRoutes.push(context, RoutePaths.activityList),
                ),
                if (data.activities.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _ActivityGrid(activities: data.activities),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: EmptyView(text: '暂无活动，敬请期待'),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 顶部：手作星球 + 搜索 + 通知铃铛（角标）
class _TopBar extends StatelessWidget {
  const _TopBar({required this.unread});

  final int unread;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 10, 2),
      child: Row(
        children: [
          const Text(
            '手作星球',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: LiveColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: LiveColors.textPrimary, size: 24),
            onPressed: () => LiveRoutes.push(context, RoutePaths.search),
          ),
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none, color: LiveColors.textPrimary, size: 24),
                if (unread > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                      decoration: const BoxDecoration(
                        color: LiveColors.danger,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unread > 99 ? '99+' : '$unread',
                        style: const TextStyle(color: Colors.white, fontSize: 8),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => LiveRoutes.push(context, RoutePaths.notifications),
          ),
        ],
      ),
    );
  }
}

/// 区块标题：标题 + 可选徽标 + 可选「查看全部 ›」/ 右侧灰字
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.badge,
    this.more,
    this.trailing,
    this.onMore,
  });

  final String title;
  final String? badge;
  final String? more;
  final String? trailing;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 21.6,
              fontWeight: FontWeight.w800,
              color: LiveColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: LiveColors.textPrimary,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  fontSize: 10.6,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (more != null)
            InkWell(
              onTap: onMore,
              child: Text(
                more!,
                style: const TextStyle(fontSize: 13, color: LiveColors.textSecondary),
              ),
            )
          else if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(fontSize: 11.6, color: LiveColors.textSecondary),
            ),
        ],
      ),
    );
  }
}

/// 三入口卡（预约 / 到店 / 会员套餐），使用设计稿资源图 + 三等分点击区。
class _EntryCardsRow extends StatelessWidget {
  const _EntryCardsRow({required this.onTap});

  final void Function(String key) onTap;

  static const _keys = ['appoint', 'checkin', 'member'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 124,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/divrowgap30.png', fit: BoxFit.fill),
          Row(
            children: [
              for (final key in _keys)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(key),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 「敬请期待」占位卡（直播专区 / 手作商城）。
class _ComingSoonRow extends StatelessWidget {
  const _ComingSoonRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/divrowgap3.png', fit: BoxFit.fill),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 活动推荐：两列 221×135 活动卡（实时数据）。
class _ActivityGrid extends StatelessWidget {
  const _ActivityGrid({required this.activities});

  final List<Activity> activities;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < activities.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: _ActivityCard(
                    activity: activities[i],
                    onTap: () => LiveRoutes.pushId(
                      context,
                      RoutePaths.activityDetail,
                      activities[i].id,
                    ),
                  ),
                ),
                if (i + 1 < activities.length) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActivityCard(
                      activity: activities[i + 1],
                      onTap: () => LiveRoutes.pushId(
                        context,
                        RoutePaths.activityDetail,
                        activities[i + 1].id,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 135,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LiveColors.brandLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (activity.tag.isNotEmpty)
                  TagChip(label: activity.tag, color: LiveColors.blue),
                const Spacer(),
                Text(
                  activity.date,
                  style: const TextStyle(fontSize: 10.6, color: LiveColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              activity.title.startsWith('#') ? activity.title : '# ${activity.title}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: LiveColors.textPrimary,
                height: 1.3,
              ),
            ),
            const Spacer(),
            Text(
              activity.price > 0 ? '¥${activity.price.toStringAsFixed(0)} 起' : '免费',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: LiveColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
