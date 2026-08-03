import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/auth_service.dart';
import '../core/post_api.dart';
import '../widgets/state_widgets.dart';
import 'admin/admin_home_page.dart';
import 'community/create_post_page.dart';
import 'community/post_detail_page.dart';

/// 个人主页：对齐《个人页面设计初稿》
/// 顶部导航 + 头像/数据区 + 横幅 + 操作按钮 + 推荐卡片 + 内容 Tab + 三列作品宫格
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _posts = <Post>[];
  bool _loading = true;
  String? _error;
  int _tab = 0; // 0 帖子 / 1 Reels / 2 标记

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await PostApi.fetchMine();
      if (mounted) {
        setState(() {
          _posts.clear();
          _posts.addAll(result.items);
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = '加载失败，请下拉重试');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openCreate() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreatePostPage()),
    );
    if (created == true) _loadPosts(); // 发布成功后刷新作品
  }

  void _openDetail(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostDetailPage(postId: post.id)),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// 仅对合法的 http(s) 图片地址走网络加载，避免脏数据触发图片解析异常
  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  /// 编辑主页 → 修改昵称
  Future<void> _editProfile() async {
    final controller = TextEditingController(
      text: AuthService.instance.user?.nickname ?? '',
    );
    final nickname = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('编辑昵称'),
        content: TextField(
          controller: controller,
          maxLength: 30,
          decoration: const InputDecoration(hintText: '请输入昵称'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (nickname != null && nickname.isNotEmpty && mounted) {
      try {
        await AuthService.instance.updateNickname(nickname);
      } on DioException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(PostApi.messageOf(e))));
        }
      }
    }
  }

  /// 账号菜单（☰ 或用户名下拉）：账号设置 / 切换账号 / 退出登录
  void _openAccountMenu() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 管理员专属：管理后台入口
            if (AuthService.instance.isAdmin)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined),
                title: const Text('管理后台'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AdminHomePage()),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('账号设置'),
              onTap: () {
                Navigator.pop(ctx);
                _toast('账号设置功能开发中');
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('切换账号'),
              onTap: () {
                Navigator.pop(ctx);
                _toast('切换账号功能开发中');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: AppColors.of(ctx).danger),
              title: Text(
                '退出登录',
                style: TextStyle(color: AppColors.of(ctx).danger),
              ),
              onTap: () {
                Navigator.pop(ctx);
                AuthService.instance.logout();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: AuthService.instance,
          builder: (context, _) {
            final user = AuthService.instance.user;
            return RefreshIndicator(
              onRefresh: _loadPosts,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHeader(user),
                  _buildProfileInfo(user),
                  _buildActionButtons(),
                  _buildContentTabs(),
                  _tab == 0 ? _buildPostGrid() : _buildTabEmpty(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── 1. 顶部导航栏（60px） ───
  Widget _buildHeader(User? user) {
    final name = user?.nickname.isNotEmpty == true ? user!.nickname : '手作新人';
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 中间：用户名 + 下拉箭头（切换账号/账号设置）
          GestureDetector(
            onTap: _openAccountMenu,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
          // 左侧：发布入口
          Positioned(
            left: 4,
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: _openCreate,
            ),
          ),
          // 右侧：菜单
          Positioned(
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: _openAccountMenu,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 3. 用户信息区（头像 + 昵称 + 数据） ───
  Widget _buildProfileInfo(User? user) {
    final name = user?.nickname.isNotEmpty == true ? user!.nickname : '手作新人';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          // 头像 90×90 + 右下角悬浮 +
          GestureDetector(
            onTap: () => _toast('添加头像动态功能开发中'),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE8C9B8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _isValidImageUrl(user?.avatar)
                      ? Image.network(
                          user!.avatar,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.person, size: 48, color: Colors.white),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.of(context).surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.of(context).divider),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 16,
                      color: AppColors.of(context).textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // 昵称 + 帖子/粉丝/关注
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStat(_posts.length, '帖子'),
                    // 粉丝/关注后端暂未支持，先按设计稿占位
                    _buildStat(4, '粉丝'),
                    _buildStat(9, '关注'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(int value, String label) {
    final colors = AppColors.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ─── 4. 操作按钮（编辑/分享） ───
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(child: _buildActionButton('编辑主页', _editProfile)),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton('分享主页', () => _toast('分享主页功能开发中')),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  // ─── 5. 内容导航 Tab（帖子 / Reels / 标记） ───
  Widget _buildContentTabs() {
    final colors = AppColors.of(context);
    const tabs = [
      (icon: Icons.grid_view_rounded, label: '帖子'),
      (icon: Icons.play_circle_outline, label: 'Reels'),
      (icon: Icons.person_pin_outlined, label: '标记'),
    ];
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.divider)),
      ),
      child: Row(
        children: List.generate(3, (i) {
          final active = _tab == i;
          final color = active ? colors.textPrimary : colors.textSecondary;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Icon(tabs[i].icon, size: 22, color: color),
                  const SizedBox(height: 4),
                  Text(
                    tabs[i].label,
                    style: TextStyle(fontSize: 11, color: color),
                  ),
                  const SizedBox(height: 6),
                  // 激活 tab 底部黑线
                  Container(
                    height: 2,
                    color: active ? colors.textPrimary : Colors.transparent,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── 6. 内容展示：三列宫格 ───
  Widget _buildPostGrid() {
    if (_loading) {
      return const SizedBox(height: 280, child: LoadingWidget());
    }
    if (_error != null) {
      return SizedBox(
        height: 280,
        child: AppErrorWidget(message: _error!, onRetry: _loadPosts),
      );
    }
    if (_posts.isEmpty) {
      return const SizedBox(
        height: 280,
        child: EmptyWidget(
          icon: Icons.brush_outlined,
          message: '还没有作品，点右上角 + 发布',
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _posts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemBuilder: (_, i) => _GridCell(
        post: _posts[i],
        onTap: () => _openDetail(_posts[i]),
      ),
    );
  }

  Widget _buildTabEmpty() {
    return SizedBox(
      height: 280,
      child: EmptyWidget(
        icon: _tab == 1 ? Icons.movie_outlined : Icons.person_pin_outlined,
        message: _tab == 1 ? '还没有视频作品' : '暂无标记内容',
      ),
    );
  }
}

/// 宫格单元：作品封面图
class _GridCell extends StatelessWidget {
  const _GridCell({required this.post, required this.onTap});

  final Post post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: post.images.isNotEmpty &&
              (post.images.first.startsWith('http://') ||
                  post.images.first.startsWith('https://'))
          ? Image.network(
              post.images.first,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _placeholder(context),
            )
          : _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      color: colors.placeholder,
      child: Icon(Icons.image_outlined, color: colors.textSecondary),
    );
  }
}
