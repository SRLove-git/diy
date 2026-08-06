import 'package:flutter/material.dart';

import '../../core/auth_service.dart';
import '../../core/chat_api.dart';
import '../../core/chat_service.dart';
import '../../core/post_api.dart';
import '../community/post_card.dart';
import '../dev/gallery_page.dart';
import '../post/post_detail_page.dart';

/// 我的主页：个人资料 + 数据统计 + 作品网格 + 功能入口
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _worksCount = 0;
  int _favoritesCount = 0;
  int _likedCount = 0;
  List<Post> _works = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        PostApi.fetchMine(),
        PostApi.fetchFavorites(),
        PostApi.fetchLikedPosts(),
      ]);
      if (!mounted) return;
      setState(() {
        final mine = results[0] as ({List<Post> items, int total});
        final fav = results[1] as ({List<Post> items, int total});
        final liked = results[2] as ({List<Post> items, int total});
        _worksCount = mine.total;
        _favoritesCount = fav.total;
        _likedCount = liked.total;
        _works = mine.items;
        _loading = false;
      });
    } on Exception {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出当前账号吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFED4956)),
            child: const Text('退出'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await AuthService.instance.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.user;
    final nickname = user?.nickname ?? '手作人';
    final bio = (user?.bio ?? '').isEmpty ? '这个人很懒，什么都没写' : user!.bio;
    final avatar = user != null && user.avatar.isNotEmpty
        ? ChatApi.resolveUrl(user.avatar)
        : '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  _ProfileAvatar(url: avatar, nickname: nickname),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nickname,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF737373),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _Stat(label: '作品', value: _worksCount),
                  _Stat(label: '收藏', value: _favoritesCount),
                  _Stat(label: '喜欢', value: _likedCount),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('编辑资料即将上线')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF111111),
                      side: const BorderSide(color: Color(0xFFDBDBDB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('编辑资料'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                '我的作品',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 10),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_works.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      '还没有发布作品',
                      style: TextStyle(color: Color(0xFFA8A8A8)),
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: _works.length,
                  itemBuilder: (context, i) {
                    final post = _works[i];
                    final image = _firstImage(post);
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PostDetailPage(postId: post.id),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: image.isEmpty
                            ? const ColoredBox(
                                color: Color(0xFFF5F5F5),
                                child: Icon(Icons.image_outlined,
                                    color: Color(0xFFA8A8A8)),
                              )
                            : Image.network(
                                image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const ColoredBox(
                                  color: Color(0xFFF5F5F5),
                                ),
                              ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
              _MenuCard(
                children: [
                  _MenuItem(
                    icon: Icons.workspace_premium_outlined,
                    label: '会员中心',
                    onTap: () => _toast('会员中心即将上线'),
                  ),
                  _MenuItem(
                    icon: Icons.calendar_month_outlined,
                    label: '我的预约',
                    onTap: () => _toast('预约列表即将上线'),
                  ),
                  _MenuItem(
                    icon: Icons.receipt_long_outlined,
                    label: '我的订单',
                    onTap: () => _toast('订单列表即将上线'),
                  ),
                  _MenuItem(
                    icon: Icons.notifications_none,
                    label: '通知',
                    onTap: () => _toast('通知列表即将上线'),
                  ),
                  _MenuItem(
                    icon: Icons.palette_outlined,
                    label: '设计稿预览（82 屏）',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GalleryPage()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _MenuCard(
                children: [
                  _MenuItem(
                    icon: Icons.logout,
                    label: '退出登录',
                    color: const Color(0xFFED4956),
                    onTap: _logout,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _firstImage(Post post) {
    for (final m in post.medias) {
      if (m.type == 'image' && m.url.isNotEmpty) {
        return ChatApi.resolveUrl(m.url);
      }
    }
    for (final i in post.images) {
      if (i.isNotEmpty) return ChatApi.resolveUrl(i);
    }
    return '';
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.url, required this.nickname});

  final String url;
  final String nickname;

  @override
  Widget build(BuildContext context) {
    final initial =
        nickname.isEmpty ? '?' : String.fromCharCode(nickname.runes.first);
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFEDA75),
            Color(0xFFFA7E1E),
            Color(0xFFD62976),
            Color(0xFF962FBF),
            Color(0xFF4F5BD5),
          ],
        ),
      ),
      child: url.isEmpty
          ? Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : ClipOval(
              child: Image.network(
                url,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFFA8A8A8)),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = const Color(0xFF111111),
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14.5,
                  color: Color(0xFF111111),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFFA8A8A8)),
          ],
        ),
      ),
    );
  }
}
