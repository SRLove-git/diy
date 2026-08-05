import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/auth_service.dart';
import '../../core/follow_api.dart';
import '../../widgets/follow_button.dart';
import '../../widgets/state_widgets.dart';
import 'author_profile_page.dart';

/// 粉丝 / 关注列表
///
/// 两种模式：粉丝（谁关注了我/目标用户）、关注（我/目标用户关注了谁）。
/// 支持分页加载、下拉刷新、列表内直接关注/取关，点击条目进入对方主页。
enum FollowListMode { followers, following }

class FollowListPage extends StatefulWidget {
  const FollowListPage({
    super.key,
    required this.userId,
    required this.mode,
  });

  /// 列表所属用户（自己或他人主页传入）
  final int userId;

  final FollowListMode mode;

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  final List<FollowListUser> _items = [];
  final _scroll = ScrollController();
  int _page = 1;
  int _total = 0;
  bool _loading = true;
  bool _loadingMore = false;
  bool _error = false;

  static const _pageSize = 20;

  bool get _isSelf => AuthService.instance.user?.id == widget.userId;
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
      final result = widget.mode == FollowListMode.followers
          ? await FollowApi.fetchFollowers(
              widget.userId,
              page: page,
              limit: _pageSize,
            )
          : await FollowApi.fetchUserFollowing(
              widget.userId,
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
    } on DioException catch (_) {
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

  Future<void> _toggleFollow(FollowListUser user) async {
    try {
      final st = await FollowApi.setFollow(
        user.id,
        following: !user.following,
      );
      if (!mounted) return;
      setState(() {
        final idx = _items.indexWhere((x) => x.id == user.id);
        if (idx >= 0) {
          _items[idx] = FollowListUser(
            id: user.id,
            nickname: user.nickname,
            avatar: user.avatar,
            following: st.following,
            followedMe: user.followedMe,
            mutual: st.following && user.followedMe,
          );
        }
      });
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(FollowApi.messageOf(e))),
      );
    }
  }

  Future<void> _openProfile(FollowListUser user) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AuthorProfilePage(userId: user.id)),
    );
    if (mounted) _load(reset: true);
  }

  String get _title => widget.mode == FollowListMode.followers ? '粉丝' : '关注';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingWidget(message: '加载中…');
    if (_error && _items.isEmpty) {
      return AppErrorWidget(message: '加载失败', onRetry: () => _load(reset: true));
    }
    if (_items.isEmpty) {
      return EmptyWidget(
        icon: _title == '粉丝'
            ? Icons.people_outline
            : Icons.person_add_alt_outlined,
        message: _isSelf
            ? (_title == '粉丝' ? '还没有粉丝' : '还没有关注任何人')
            : (_title == '粉丝' ? '暂无粉丝' : '暂未关注任何人'),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView.separated(
        controller: _scroll,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _items.length + 1,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          indent: 72,
          color: Theme.of(context).extension<AppColors>()?.divider,
        ),
        itemBuilder: (context, i) {
          if (i == _items.length) return _buildFooter();
          return _buildItem(_items[i]);
        },
      ),
    );
  }

  Widget _buildItem(FollowListUser user) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: () => _openProfile(user),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _avatar(user, colors),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.nickname,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.mutual) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '互相关注',
                            style: TextStyle(
                              fontSize: 10,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (user.followedMe && !user.mutual) ...[
                    const SizedBox(height: 2),
                    Text(
                      '关注了你',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (user.id != AuthService.instance.user?.id)
              FollowButton(
                following: user.following,
                enabled: true,
                onChanged: (_) => _toggleFollow(user),
              ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(FollowListUser user, AppColors colors) {
    final url = user.resolvedAvatar;
    return ClipOval(
      child: url.isEmpty
          ? Container(
              width: 48,
              height: 48,
              color: colors.placeholder,
              alignment: Alignment.center,
              child: Icon(Icons.person, color: colors.textSecondary),
            )
          : Image.network(
              url,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              cacheWidth: 144,
              errorBuilder: (_, _, _) => Container(
                width: 48,
                height: 48,
                color: colors.placeholder,
                alignment: Alignment.center,
                child: Icon(Icons.person, color: colors.textSecondary),
              ),
            ),
    );
  }

  Widget _buildFooter() {
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (!_hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: Text(
            '共 $_total 人',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.of(context).textSecondary,
            ),
          ),
        ),
      );
    }
    return const SizedBox(height: 8);
  }
}
