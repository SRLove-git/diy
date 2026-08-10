import 'package:flutter/material.dart';

import '../../api/api_client.dart';
import '../../api/chat_services.dart';
import '../../api/models.dart';
import '../../l10n/l10n_ext.dart';
import '../live_theme.dart';
import '../live_widgets.dart';
// import '../live_routes.dart'; // 社区/Reels 前期暂不开放（跳转已注释）

/// 通知页：按 Pixso 设计稿「31-通知」重做。
/// 结构：顶部导航（返回 / 通知 / 全部已读）→ 互动分组（红色未读角标）→
/// 系统消息分组；每条通知为「渐变图标盒 + 标题 + 相对时间 + 摘要」卡片行，
/// 未读行右侧带红色圆点，行间以 1px 分割线隔开。
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<({List<AppNotification> items, int total, int unread})> _future;

  @override
  void initState() {
    super.initState();
    _future = NotificationService.instance.mine();
  }

  void _retry() => setState(() => _future = NotificationService.instance.mine());

  Future<void> _readAll() async {
    try {
      await NotificationService.instance.readAll();
      if (mounted) {
        showLiveSnack(context, context.l10n.notificationMarkAllRead);
        _retry();
      }
    } on ApiException catch (e) {
      if (mounted) showLiveSnack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LivePage(
      child: FutureBuilder(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Column(
              children: [
                const _NotificationAppBar(),
                Expanded(child: ErrorView(message: _msg(snap.error), onRetry: _retry)),
              ],
            );
          }
          if (!snap.hasData) {
            return const Column(
              children: [_NotificationAppBar(), Expanded(child: LoadingView())],
            );
          }
          final data = snap.data!;
          return Column(
            children: [
              _NotificationAppBar(
                enabled: data.unread > 0,
                onReadAll: _readAll,
              ),
              Expanded(
                child: data.items.isEmpty
                    ? EmptyView(
                        text: context.l10n.notificationEmpty,
                        icon: Icons.notifications_none,
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _retry(),
                        child: _NotificationList(
                          items: data.items,
                          onRead: (id) async {
                            try {
                              await NotificationService.instance.read(id);
                              _retry();
                            } on ApiException catch (e) {
                              if (context.mounted) {
                                showLiveSnack(context, e.message);
                              }
                            }
                          },
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

/// 顶部导航：左侧返回、居中「通知」、右侧「全部已读」。
class _NotificationAppBar extends StatelessWidget {
  const _NotificationAppBar({this.enabled = false, this.onReadAll});

  final bool enabled;
  final VoidCallback? onReadAll;

  @override
  Widget build(BuildContext context) {
    return LiveAppBar(
      title: context.l10n.notificationTitle,
      actions: [
        TextButton(
          onPressed: enabled ? onReadAll : null,
          child: Text(
            context.l10n.notificationMarkAllRead,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: LiveColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.items, required this.onRead});

  final List<AppNotification> items;
  final ValueChanged<int> onRead;

  @override
  Widget build(BuildContext context) {
    final interact = items.where(_isInteract).toList();
    final system = items.where((n) => !_isInteract(n)).toList();
    final interactUnread = interact.where((n) => !n.read).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        if (interact.isNotEmpty) ...[
          _SectionHeader(title: context.l10n.notificationInteract, count: interactUnread),
          const SizedBox(height: 8),
          _Card(
            children: [
              for (final n in interact) _NotificationRow(n: n, onRead: onRead),
            ],
          ),
          if (system.isNotEmpty) const SizedBox(height: 23),
        ],
        if (system.isNotEmpty) ...[
          _SectionHeader(title: context.l10n.notificationSystem),
          const SizedBox(height: 13),
          _Card(
            children: [
              for (final n in system) _NotificationRow(n: n, onRead: onRead),
            ],
          ),
        ],
      ],
    );
  }
}

/// 分组标题：17px 粗体 + 可选的红色未读数角标。
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.count = 0});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: LiveColors.textPrimary,
          ),
        ),
        if (count > 0) ...[
          const SizedBox(width: 12),
          Container(
            constraints: const BoxConstraints(minWidth: 18),
            height: 20,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LiveColors.danger,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 通知卡片：白底、1px 描边、16 圆角，行间 1px 分割线。
class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 6),
      decoration: BoxDecoration(
        color: LiveColors.bg,
        border: Border.all(color: const Color(0xFFEFEFEF)),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: Color(0xFFEFEFEF)),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// 单条通知：渐变图标盒 + 标题 + 相对时间 + 摘要，未读时右侧红点。
class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.n, required this.onRead});

  final AppNotification n;
  final ValueChanged<int> onRead;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!n.read) onRead(n.id);
        _open(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconBox(icon: _iconFor(n)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: LiveColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        fmtRelTime(n.createdAt ?? n.sentAt),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: LiveColors.textTertiary,
                        ),
                      ),
                      if (!n.read) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: LiveColors.danger,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.content,
                    style: const TextStyle(
                      fontSize: 13,
                      color: LiveColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 点击通知跳转到对应内容：作品 / 短视频 / 用户主页。
  /// 社区 / Reels 前期暂不开放，跳转先注释，点击仅提示。
  void _open(BuildContext context) {
    switch (n.actionType) {
      case 'post':
        // if (id != null) LiveRoutes.pushId(context, RoutePaths.postDetail, id);
        showLiveSnack(context, context.l10n.notificationCommunitySoon);
        break;
      case 'video':
        // if (id != null) LiveRoutes.pushId(context, RoutePaths.videoDetail, id);
        showLiveSnack(context, context.l10n.notificationReelsSoon);
        break;
      case 'user':
        // if (id != null) LiveRoutes.pushId(context, RoutePaths.userDetail, id);
        showLiveSnack(context, context.l10n.notificationCommunitySoon);
        break;
    }
  }
}

/// 40x40 圆角图标盒：浅灰渐变底（对应设计稿 iconbox.soft）。
class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF4F4F6), Color(0xFFECECEF)],
        ),
      ),
      child: Icon(icon, size: 20, color: LiveColors.textPrimary),
    );
  }
}

const _interactKeys = ['赞', '评论', '收藏', '关注', '回复'];

bool _isInteract(AppNotification n) =>
    _interactKeys.any((k) => n.title.contains(k) || n.content.contains(k));

IconData _iconFor(AppNotification n) {
  final text = '${n.title}${n.content}';
  if (_isInteract(n)) {
    if (text.contains('赞')) return Icons.favorite;
    if (text.contains('评论') || text.contains('回复')) return Icons.chat_bubble;
    if (text.contains('收藏')) return Icons.bookmark;
    if (text.contains('关注')) return Icons.person;
    return Icons.favorite;
  }
  if (text.contains('会员') || text.contains('优惠券') || text.contains('券')) {
    return Icons.card_giftcard;
  }
  if (text.contains('预约')) return Icons.schedule;
  if (text.contains('审核')) return Icons.diamond;
  return Icons.campaign;
}

String _msg(Object? e) =>
    e is ApiException ? e.message : '加载失败，请确认后端服务已启动';
