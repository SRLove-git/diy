import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_colors.dart';
import '../core/auth_service.dart';
import '../core/chat_api.dart';
import '../core/follow_api.dart';
import '../core/post_api.dart';
import '../core/video_api.dart';
import '../features/member/presentation/member_plan_page.dart';
import 'short_video_models.dart';
import 'profile/my_favorites_page.dart';
import 'profile/my_history_page.dart';
import 'profile/my_wallet_page.dart';
import 'profile/my_works_page.dart';
import 'profile/order_list_page.dart';
import 'profile/reels_player_page.dart';
import '../widgets/image_viewer.dart';
import '../widgets/state_widgets.dart';
import 'admin/admin_home_page.dart';
import 'community/post_detail_page.dart';

/// 个人主页：对齐《个人页面设计初稿》
/// 顶部导航 + 头像/数据区 + 横幅 + 操作按钮 + 推荐卡片 + 内容 Tab + 三列作品宫格
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _posts = <Post>[];
  bool _loading = true;
  String? _error;
  int _tab = 0; // 0 帖子 / 1 Reels

  /// 我的短视频作品（Reels Tab，懒加载）
  final List<ShortVideo> _reels = [];
  bool _reelsLoaded = false;
  bool _reelsLoading = false;
  String? _reelsError;

  /// 粉丝/关注数（来自关注接口）
  int _followerCount = 0;
  int _followingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadStats();
  }

  /// 拉取自己的粉丝/关注数
  Future<void> _loadStats() async {
    final me = AuthService.instance.user;
    if (me == null) return;
    try {
      final st = await FollowApi.status(me.id);
      if (mounted) {
        setState(() {
          _followerCount = st.followerCount;
          _followingCount = st.followingCount;
        });
      }
    } catch (_) {
      // 静默失败，保持占位 0
    }
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

  /// 拉取我的短视频作品
  Future<void> _loadReels() async {
    setState(() {
      _reelsLoading = true;
      _reelsError = null;
    });
    try {
      final result = await VideoApi.fetchMine();
      if (mounted) {
        setState(() {
          _reels
            ..clear()
            ..addAll(result.items);
          _reelsLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _reelsError = '加载失败，请重试');
    } finally {
      if (mounted) setState(() => _reelsLoading = false);
    }
  }

  void _openReels(ShortVideo video) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReelsPlayerPage(video: video)),
    );
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

  /// 仅对合法的 http(s)/服务端相对路径图片地址走网络加载，避免脏数据触发图片解析异常
  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('/uploads/');
  }

  /// 头像菜单：查看大图 / 拍照 / 从相册选择
  void _openAvatarMenu() {
    final user = AuthService.instance.user;
    final hasAvatar = _isValidImageUrl(user?.avatar);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasAvatar)
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('查看头像'),
                onTap: () {
                  Navigator.pop(ctx);
                  _viewAvatar(user!.avatar);
                },
              ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadAvatar(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('取消'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  /// 全屏查看当前头像
  void _viewAvatar(String avatar) {
    showImageViewer(
      context,
      image: networkViewerImage(ChatApi.resolveUrl(avatar)),
      heroTag: 'profile-avatar',
    );
  }

  /// 选图 → 上传 → 更新头像（失败仅提示，不影响当前头像）
  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
    } catch (_) {
      _toast('无法打开相机/相册');
      return;
    }
    if (picked == null) return;
    try {
      await AuthService.instance.updateAvatar(picked.path);
      if (mounted) _toast('头像已更新');
    } on DioException catch (e) {
      if (mounted) _toast(PostApi.messageOf(e));
    } catch (_) {
      if (mounted) _toast('头像上传失败，请稍后再试');
    }
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(PostApi.messageOf(e))));
        }
      }
    }
  }

  void _openFunctionPanel() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _openFeaturePage(Widget page) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      endDrawer: _buildFunctionDrawer(),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: AuthService.instance,
          builder: (context, _) {
            final user = AuthService.instance.user;
            return RefreshIndicator(
              onRefresh: () => Future.wait([
                _loadPosts(),
                _loadStats(),
                if (_reelsLoaded) _loadReels(),
              ]),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHeader(user),
                  _buildProfileInfo(user),
                  _buildActionButtons(),
                  _buildContentTabs(),
                  _tab == 0 ? _buildPostGrid() : _buildReelsGrid(),
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
    final colors = AppColors.of(context);
    final name = user?.nickname.isNotEmpty == true ? user!.nickname : '手作新人';
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 中间：用户名 + 下拉箭头（切换账号/账号设置）
          GestureDetector(
            onTap: _editProfile,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(Icons.arrow_drop_down, size: 20, color: colors.primary),
              ],
            ),
          ),
          // 右侧：菜单
          Positioned(
            right: 4,
            child: IconButton(
              icon: Icon(Icons.menu_rounded, color: colors.textPrimary),
              onPressed: _openFunctionPanel,
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
            onTap: _openAvatarMenu,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFDCE5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _isValidImageUrl(user?.avatar)
                      ? Image.network(
                          ChatApi.resolveUrl(user!.avatar),
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStat(_posts.length, '帖子'),
                    _buildStat(_followerCount, '粉丝'),
                    _buildStat(_followingCount, '关注'),
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
          color: colors.placeholder,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.divider),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildFunctionDrawer() {
    const entries = [
      (icon: Icons.workspace_premium_outlined, label: '会员套餐', page: MemberPlanPage()),
      (icon: Icons.wallet_giftcard_outlined, label: '卡包', page: MyWalletPage()),
      (icon: Icons.favorite_border, label: '点赞与收藏', page: MyFavoritesPage()),
      (icon: Icons.palette_outlined, label: '个人作品', page: MyWorksPage()),
      (icon: Icons.history, label: '观看历史', page: MyHistoryPage()),
      (icon: Icons.receipt_long_outlined, label: '我的订单', page: OrderListPage()),
    ];
    final colors = AppColors.of(context);
    final user = AuthService.instance.user;
    final name = user?.nickname.isNotEmpty == true ? user!.nickname : '手作新人';

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.78,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '功能中心',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          name,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.placeholder,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: entries.map((entry) {
                        return _FunctionTile(
                          icon: entry.icon,
                          label: entry.label,
                          onTap: () => _openFeaturePage(entry.page),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.placeholder,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        if (AuthService.instance.isAdmin)
                          _FunctionTile(
                            icon: Icons.admin_panel_settings_outlined,
                            label: '管理后台',
                            onTap: () => _openFeaturePage(const AdminHomePage()),
                          ),
                        _FunctionTile(
                          icon: Icons.settings_outlined,
                          label: '账号设置',
                          onTap: () {
                            Navigator.of(context).pop();
                            _toast('账号设置功能开发中');
                          },
                        ),
                        _FunctionTile(
                          icon: Icons.swap_horiz,
                          label: '切换账号',
                          onTap: () {
                            Navigator.of(context).pop();
                            _toast('切换账号功能开发中');
                          },
                        ),
                        _FunctionTile(
                          icon: Icons.logout,
                          label: '退出登录',
                          labelColor: colors.danger,
                          iconColor: colors.danger,
                          onTap: () {
                            Navigator.of(context).pop();
                            AuthService.instance.logout();
                          },
                        ),
                      ],
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

  // ─── 5. 内容导航 Tab（帖子 / Reels） ───
  Widget _buildContentTabs() {
    final colors = AppColors.of(context);
    const tabs = [
      (icon: Icons.grid_view_rounded, label: '帖子'),
      (icon: Icons.play_circle_outline, label: '视频'),
    ];
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.divider)),
      ),
      child: Row(
        children: List.generate(2, (i) {
          final active = _tab == i;
          final color = active ? colors.primary : colors.textSecondary;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() => _tab = i);
                // 首次进入 Reels 时懒加载
                if (i == 1 && !_reelsLoaded && !_reelsLoading) _loadReels();
              },
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
                    color: active ? colors.primary : Colors.transparent,
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
      itemBuilder: (_, i) =>
          _GridCell(post: _posts[i], onTap: () => _openDetail(_posts[i])),
    );
  }

  // ─── 7. 内容展示：Reels 三列宫格 ───
  Widget _buildReelsGrid() {
    if (_reelsLoading && !_reelsLoaded) {
      return const SizedBox(height: 280, child: LoadingWidget());
    }
    if (_reelsError != null && _reels.isEmpty) {
      return SizedBox(
        height: 280,
        child: AppErrorWidget(message: _reelsError!, onRetry: _loadReels),
      );
    }
    if (_reels.isEmpty) {
      return const SizedBox(
        height: 280,
        child: EmptyWidget(
          icon: Icons.movie_outlined,
          message: '还没有视频作品，去「视频」页发布吧',
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reels.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemBuilder: (_, i) => _ReelsCell(
        video: _reels[i],
        onTap: () => _openReels(_reels[i]),
      ),
    );
  }
}

class _FunctionTile extends StatelessWidget {
  const _FunctionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final resolvedIconColor = iconColor ?? colors.textPrimary;
    final resolvedLabelColor = labelColor ?? colors.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0x1AFF718D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: resolvedIconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: resolvedLabelColor,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
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
      child: Stack(
        fit: StackFit.expand,
        children: [
          _cover.isNotEmpty
              ? Image.network(
                  _cover,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _placeholder(context),
                )
              : _textCell(context),
          if (_hasVideo)
            const Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white70,
                  size: 22,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 封面图：优先 medias 首项，其次 images 首项，兼容 /uploads/ 相对路径
  String get _cover {
    var mediaList = post.medias
        .where((m) => m.url.trim().isNotEmpty)
        .toList();
    if (mediaList.isEmpty) {
      mediaList = post.images
          .where((url) => url.trim().isNotEmpty)
          .map(
            (url) => PostMedia(type: 'image', url: url, aspectRatio: 4 / 5),
          )
          .toList();
    }
    if (mediaList.isEmpty) return '';
    final raw = mediaList.first.url;
    return raw.startsWith('http://') || raw.startsWith('https://')
        ? raw
        : ChatApi.resolveUrl(raw);
  }

  bool get _hasVideo => post.medias.any((m) => m.type == 'video');

  /// 纯文字帖子：暖色渐变 + 正文预览，替代图片占位
  Widget _textCell(BuildContext context) {
    final colors = AppColors.of(context);
    final content = post.content.trim();
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF3EE), Color(0xFFFFE9EF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded, size: 16, color: colors.primary),
              const SizedBox(width: 5),
              Text(
                '纯文字',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              content.isEmpty ? '分享一条纯文字动态' : content,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: Color(0xFF3D3836),
              ),
            ),
          ),
        ],
      ),
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

/// Reels 宫格单元：视频封面
class _ReelsCell extends StatelessWidget {
  const _ReelsCell({required this.video, required this.onTap});

  final ShortVideo video;
  final VoidCallback onTap;

  String get _cover {
    if (video.cover.isNotEmpty) return video.cover;
    if (video.photos.isNotEmpty) return video.photos.first;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isPhoto = video.isPhoto || video.videoUrl.isEmpty;
    return InkWell(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _cover.isNotEmpty
              ? Image.network(
                  _cover,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: colors.placeholder,
                    child: Icon(
                      Icons.movie_outlined,
                      color: colors.textSecondary,
                    ),
                  ),
                )
              : Container(
                  color: colors.placeholder,
                  child: Icon(
                    Icons.movie_outlined,
                    color: colors.textSecondary,
                  ),
                ),
          if (isPhoto)
            const Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.photo_outlined,
                  color: Colors.white70,
                  size: 18,
                ),
              ),
            )
          else ...[
            const Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            if (video.duration.inSeconds > 0)
              Positioned(
                right: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatDuration(video.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

String _formatDuration(Duration d) {
  final total = d.inSeconds;
  final m = total ~/ 60;
  final s = (total % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
