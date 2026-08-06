import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_colors.dart';
import '../core/auth_service.dart';
import '../core/chat_api.dart';
import '../core/follow_api.dart';
import '../core/post_api.dart';
import '../core/video_api.dart';
import 'home_page.dart';
import '../features/tiktok_profile/page/video_profile_page.dart';
import '../features/tiktok_profile/model/tiktok_video_model.dart';
import '../features/tiktok_profile/page/fullscreen_video_page.dart';
import '../features/tiktok_profile/widget/video_grid_card.dart';
import '../features/member/presentation/member_plan_page.dart';
import 'short_video_models.dart';
import 'profile/my_favorites_page.dart';
import 'profile/my_history_page.dart';
import 'profile/my_wallet_page.dart';
import 'profile/order_list_page.dart';
import 'profile/edit_profile_page.dart';
import 'profile/account_settings_page.dart';
import '../widgets/image_viewer.dart';
import '../widgets/state_widgets.dart';
import 'admin/admin_home_page.dart';
import 'community/post_detail_page.dart';
import 'community/follow_list_page.dart';

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
  int _tab = 0; // 0 帖子 / 1 笔记 / 2 视频

  /// 我的短视频作品（视频 Tab，懒加载；仅含真实视频）
  final List<ShortVideo> _reels = [];

  /// 我的笔记（纯图片组合作品，从视频接口拆分，懒加载）
  final List<ShortVideo> _notes = [];
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
        // 拆分：无视频流的纯图片组合作品归入「笔记」，其余留在「视频」
        final videos = <ShortVideo>[];
        final notes = <ShortVideo>[];
        for (final v in result.items) {
          (v.isPhoto || v.videoUrl.isEmpty ? notes : videos).add(v);
        }
        setState(() {
          _reels
            ..clear()
            ..addAll(videos);
          _notes
            ..clear()
            ..addAll(notes);
          _reelsLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _reelsError = '加载失败，请重试');
    } finally {
      if (mounted) setState(() => _reelsLoading = false);
    }
  }

  /// 打开抖音风格全屏播放页：传入整个 Tab 的作品列表 + 点击下标，
  /// 支持上下滑动切换；返回后重新拉取列表同步点赞/评论数。
  Future<void> _openTikTokPlayer(List<ShortVideo> list, int index) async {
    final raw = AuthService.instance.user?.nickname ?? '';
    final nickname = raw.isNotEmpty ? raw : 'srlovice';
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenVideoPage(
          videos: [
            for (final v in list) TiktokVideoModel(video: v),
          ],
          initialIndex: index,
          nickname: nickname,
        ),
      ),
    );
    // 返回后刷新笔记/视频列表，保持点赞/评论数同步
    if (mounted && _reelsLoaded) _loadReels();
  }

  ShortVideo? _findVideo(int id) {
    for (final v in _reels) {
      if (v.id == id) return v;
    }
    for (final v in _notes) {
      if (v.id == id) return v;
    }
    return null;
  }

  /// 用最新对象替换两个列表中的同名视频（点赞/评论数在此更新）
  void _updateVideo(ShortVideo updated) {
    setState(() {
      final ri = _reels.indexWhere((v) => v.id == updated.id);
      if (ri >= 0) _reels[ri] = updated;
      final ni = _notes.indexWhere((v) => v.id == updated.id);
      if (ni >= 0) _notes[ni] = updated;
    });
  }

  /// 网格双击点赞：乐观更新 + 服务端同步 + 失败回滚
  void _toggleVideoLike(ShortVideo video) {
    final target = !video.liked;
    _updateVideo(
      video.copyWith(
        liked: target,
        likeCount: video.likeCount + (target ? 1 : -1),
      ),
    );
    VideoApi.toggleLike(video.id).then((serverLiked) {
      if (!mounted) return;
      final cur = _findVideo(video.id);
      if (cur == null || serverLiked == cur.liked) return;
      _updateVideo(
        cur.copyWith(
          liked: serverLiked,
          likeCount: cur.likeCount + (serverLiked ? 1 : -1),
        ),
      );
    }).catchError((_) {
      if (!mounted) return;
      _updateVideo(video);
    });
  }

  void _openDetail(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostDetailPage(postId: post.id)),
    );
  }

  /// 删除作品二次确认
  Future<bool> _confirmDelete(String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: const Text('删除后不可恢复，确定删除吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除', style: TextStyle(color: Palette.danger)),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// 删除帖子作品（长按宫格触发）
  Future<void> _deletePost(Post post) async {
    if (!await _confirmDelete('删除作品')) return;
    try {
      await PostApi.deletePost(post.id);
      if (!mounted) return;
      setState(() => _posts.removeWhere((p) => p.id == post.id));
      _toast('已删除');
    } catch (_) {
      if (mounted) _toast('删除失败，请稍后再试');
    }
  }

  /// 删除笔记/视频作品（长按宫格触发）
  Future<void> _deleteVideo(ShortVideo video) async {
    if (!await _confirmDelete('删除作品')) return;
    try {
      await VideoApi.deleteVideo(video.id);
      if (!mounted) return;
      setState(() {
        _reels.removeWhere((v) => v.id == video.id);
        _notes.removeWhere((v) => v.id == video.id);
      });
      _toast('已删除');
    } catch (_) {
      if (mounted) _toast('删除失败，请稍后再试');
    }
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

  /// 编辑主页 → 进入完整资料编辑页（头像 / 名字 / 用户名 / 简介 / 性别 / 生日 / 所在地）
  Future<void> _editProfile() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const EditProfilePage()),
    );
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
                  _tab == 0
                      ? _buildPostGrid()
                      : _tab == 1
                      ? _buildNotesGrid()
                      : _buildReelsGrid(),
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
    final name = user?.username?.isNotEmpty == true
        ? user!.username!
        : user?.nickname.isNotEmpty == true
        ? user!.nickname
        : '手作新人';
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 中间：用户名 + 下拉箭头（切换账号/账号设置）
          GestureDetector(
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (_) => const SwitchAccountSheet(),
              );
            },
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
    final bio = (user?.bio ?? '').trim();
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
                    color: Palette.accentLight,
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
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.of(context).textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStat(_posts.length, '帖子'),
                    _buildStat(
                      _followerCount,
                      '粉丝',
                      onTap: () => _openFollowList(FollowListMode.followers),
                    ),
                    _buildStat(
                      _followingCount,
                      '关注',
                      onTap: () => _openFollowList(FollowListMode.following),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(int value, String label, {VoidCallback? onTap}) {
    final colors = AppColors.of(context);
    final content = Column(
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
    );
    return Expanded(
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: content,
            ),
    );
  }

  /// 打开粉丝/关注列表，返回后刷新数字
  Future<void> _openFollowList(FollowListMode mode) async {
    final me = AuthService.instance.user;
    if (me == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FollowListPage(userId: me.id, mode: mode),
      ),
    );
    if (mounted) _loadStats();
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
            child: _buildActionButton('分享主页', _shareProfile),
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

  /// 分享主页：生成主页链接写入剪贴板
  Future<void> _shareProfile() async {
    final user = AuthService.instance.user;
    final userId = user?.id;
    final link = userId == null
        ? 'https://diy.example.com'
        : 'https://diy.example.com/users/$userId';
    await Clipboard.setData(ClipboardData(text: link));
    _toast('主页链接已复制，快去分享吧');
  }

  Widget _buildFunctionDrawer() {
    const entries = [
      (
        icon: Icons.storefront_outlined,
        label: '门店服务',
        page: HomePage(),
      ),
      (icon: Icons.workspace_premium_outlined, label: '会员套餐', page: MemberPlanPage()),
      (icon: Icons.wallet_giftcard_outlined, label: '卡包', page: MyWalletPage()),
      (icon: Icons.favorite_border, label: '点赞与收藏', page: MyFavoritesPage()),
      // 个人作品：抖音风格作品墙（2 列封面流 → 全屏上下滑动播放页）
      (
        icon: Icons.palette_outlined,
        label: '个人作品',
        page: VideoProfilePage(),
      ),
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
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AccountSettingsPage(),
                              ),
                            );
                          },
                        ),
                        _FunctionTile(
                          icon: Icons.swap_horiz,
                          label: '切换账号',
                          onTap: () {
                            Navigator.of(context).pop();
                            showModalBottomSheet<void>(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const SwitchAccountSheet(),
                            );
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
      (icon: Icons.article_outlined, label: '笔记'),
      (icon: Icons.play_circle_outline, label: '视频'),
    ];
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.divider)),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = _tab == i;
          final color = active ? colors.primary : colors.textSecondary;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() => _tab = i);
                // 首次进入「笔记 / 视频」时懒加载（同一接口拆分）
                if ((i == 1 || i == 2) &&
                    !_reelsLoaded &&
                    !_reelsLoading) {
                  _loadReels();
                }
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
      itemBuilder: (_, i) => _GridCell(
        post: _posts[i],
        onTap: () => _openDetail(_posts[i]),
        onLongPress: () => _deletePost(_posts[i]),
      ),
    );
  }

  // ─── 7. 内容展示：笔记两列抖音风宫格（纯图片组合作品） ───
  Widget _buildNotesGrid() {
    if (_reelsLoading && !_reelsLoaded) {
      return const SizedBox(height: 280, child: LoadingWidget());
    }
    if (_reelsError != null && _notes.isEmpty) {
      return SizedBox(
        height: 280,
        child: AppErrorWidget(message: _reelsError!, onRetry: _loadReels),
      );
    }
    if (_notes.isEmpty) {
      return const SizedBox(
        height: 280,
        child: EmptyWidget(
          icon: Icons.article_outlined,
          message: '还没有笔记，去「视频」页发布照片作品吧',
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _notes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (_, i) => VideoGridCard(
        item: TiktokVideoModel(video: _notes[i]),
        photoCount: _notes[i].photos.length,
        onTap: () => _openTikTokPlayer(_notes, i),
        onDoubleTap: () => _toggleVideoLike(_notes[i]),
        onLongPress: () => _deleteVideo(_notes[i]),
      ),
    );
  }

  // ─── 8. 内容展示：视频两列抖音风宫格（仅真实视频） ───
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
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (_, i) => VideoGridCard(
        item: TiktokVideoModel(video: _reels[i]),
        onTap: () => _openTikTokPlayer(_reels, i),
        onDoubleTap: () => _toggleVideoLike(_reels[i]),
        onLongPress: () => _deleteVideo(_reels[i]),
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
                  color: Palette.accentSoft,
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
  const _GridCell({
    required this.post,
    required this.onTap,
    this.onLongPress,
  });

  final Post post;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
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
          colors: [Palette.iconBgOrange, Palette.primaryLight],
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
                color: Palette.textPrimary,
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
