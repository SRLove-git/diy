import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/chat_api.dart';
import '../../widgets/state_widgets.dart';
import '../community/user_profile_page.dart';

/// 黑名单管理页：展示我拉黑的用户，支持移出黑名单。
/// 入口：消息页右上角「发起群聊 / 添加好友」底部菜单 -> 黑名单。
class BlacklistPage extends StatefulWidget {
  const BlacklistPage({super.key});

  @override
  State<BlacklistPage> createState() => _BlacklistPageState();
}

class _BlacklistPageState extends State<BlacklistPage> {
  final List<BlockedUser> _items = [];
  final _scroll = ScrollController();
  int _page = 1;
  int _total = 0;
  bool _loading = true;
  bool _loadingMore = false;
  bool _error = false;

  static const _pageSize = 20;

  bool get _hasMore => _items.length < _total;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 120) {
      _loadMore();
    }
  }

  Future<void> _load({required bool reset}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = false;
        _page = 1;
      });
    } else {
      setState(() => _loadingMore = true);
    }
    try {
      final page = reset ? 1 : _page;
      final result = await ChatApi.fetchBlockedUsers(
        page: page,
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        if (reset) {
          _items
            ..clear()
            ..addAll(result.items);
        } else {
          _items.addAll(result.items);
        }
        _total = result.total;
        _page = page + 1;
      });
    } on DioException {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    await _load(reset: false);
  }

  /// 移出黑名单：二次确认后调用接口并从列表移除
  Future<void> _unblock(BlockedUser user) async {
    final colors = AppColors.of(context);
    final name =
        user.nickname.isEmpty ? '用户 #${user.id}' : user.nickname;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('移出黑名单'),
        content: Text('将 $name 移出黑名单后，你们可以重新互发消息。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: colors.danger),
            child: const Text('移出'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ChatApi.setBlock(user.id, blocked: false);
      if (!mounted) return;
      setState(() {
        _items.removeWhere((u) => u.id == user.id);
        _total -= 1;
      });
      _toast('已移出黑名单');
    } catch (_) {
      if (mounted) _toast('操作失败，请稍后再试');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _openProfile(BlockedUser user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfilePage(
          userId: user.id,
          nickname: user.nickname,
          avatar: user.avatar,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.placeholder,
      appBar: AppBar(title: const Text('黑名单')),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(AppColors colors) {
    if (_loading) return const LoadingWidget();
    if (_error) {
      return AppErrorWidget(
        message: '加载失败，请重试',
        onRetry: () => _load(reset: true),
      );
    }
    if (_items.isEmpty) {
      return const EmptyWidget(
        icon: Icons.block_outlined,
        message: '黑名单为空',
      );
    }
    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView.separated(
        controller: _scroll,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _items.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, _) => Divider(
          height: 1,
          indent: 68,
          color: colors.divider,
        ),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return _buildItem(colors, _items[index]);
        },
      ),
    );
  }

  Widget _buildItem(AppColors colors, BlockedUser user) {
    final name = user.nickname.isEmpty ? '用户 #${user.id}' : user.nickname;
    return Material(
      color: colors.surface,
      child: InkWell(
        onTap: () => _openProfile(user),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _Avatar(avatar: user.avatar, nickname: name, colors: colors),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _unblock(user),
                style: TextButton.styleFrom(
                  foregroundColor: colors.primary,
                ),
                child: const Text('移出黑名单'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 黑名单用户头像（圆形，缺失时显示昵称首字占位）
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.avatar,
    required this.nickname,
    required this.colors,
  });

  final String avatar;
  final String nickname;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final url = avatar.trim();
    final hasImage = url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('/uploads/');
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.placeholder,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              ChatApi.resolveUrl(url),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _initial(),
            )
          : _initial(),
    );
  }

  Widget _initial() {
    final name = nickname.trim();
    final initial = name.isEmpty ? '?' : String.fromCharCode(name.runes.first);
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}
