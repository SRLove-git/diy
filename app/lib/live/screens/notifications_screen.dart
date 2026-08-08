import 'package:flutter/material.dart';

import '../../api/api_client.dart';
import '../../api/chat_services.dart';
import '../../api/models.dart';
import '../live_theme.dart';
import '../live_widgets.dart';

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
        showLiveSnack(context, '已全部标记为已读');
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
                const LiveAppBar(title: '通知'),
                Expanded(child: ErrorView(message: _msg(snap.error), onRetry: _retry)),
              ],
            );
          }
          if (!snap.hasData) {
            return const Column(
              children: [LiveAppBar(title: '通知'), Expanded(child: LoadingView())],
            );
          }
          final data = snap.data!;
          return Column(
            children: [
              LiveAppBar(
                title: '通知',
                actions: [
                  TextButton(
                    onPressed: data.unread > 0 ? _readAll : null,
                    child: Text(
                      '全部已读',
                      style: TextStyle(
                        fontSize: 13,
                        color: data.unread > 0 ? LiveColors.brand : LiveColors.textTertiary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              Expanded(
                child: data.items.isEmpty
                    ? const EmptyView(text: '暂无通知', icon: Icons.notifications_none)
                    : RefreshIndicator(
                        onRefresh: () async => _retry(),
                        child: _NotificationList(
                          items: data.items,
                          onRead: (id) async {
                            try {
                              await NotificationService.instance.read(id);
                              _retry();
                            } on ApiException catch (e) {
                              if (mounted) showLiveSnack(context, e.message);
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

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.items, required this.onRead});

  final List<AppNotification> items;
  final ValueChanged<int> onRead;

  static const _interactKeys = ['赞', '评论', '收藏', '关注', '回复'];

  bool _isInteract(AppNotification n) =>
      _interactKeys.any((k) => n.title.contains(k) || n.content.contains(k));

  @override
  Widget build(BuildContext context) {
    final interact = items.where(_isInteract).toList();
    final system = items.where((n) => !_isInteract(n)).toList();

    Widget row(AppNotification n) {
      return InkWell(
        onTap: () {
          if (!n.read) onRead(n.id);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: n.read ? Colors.transparent : LiveColors.danger,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: n.read ? FontWeight.w400 : FontWeight.w700,
                        color: LiveColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.content,
                      style: const TextStyle(fontSize: 12, color: LiveColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fmtTime(n.createdAt, withYear: true),
                      style: const TextStyle(fontSize: 11, color: LiveColors.textTertiary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget header(String title, int count) {
      return Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 2),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: LiveColors.textPrimary),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Text('$count', style: const TextStyle(fontSize: 13, color: LiveColors.danger)),
            ],
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        if (interact.isNotEmpty) ...[
          header('互动', interact.length),
          ...interact.map(row),
          const Divider(height: 24, color: LiveColors.divider),
        ],
        if (system.isNotEmpty) ...[
          header('系统消息', system.length),
          ...system.map(row),
        ],
      ],
    );
  }
}

String _msg(Object? e) =>
    e is ApiException ? e.message : '加载失败，请确认后端服务已启动';
