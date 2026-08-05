import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/chat_api.dart';
import '../../core/chat_service.dart';
import '../../core/follow_api.dart';
import '../../core/post_api.dart';
import '../../features/community/domain/community_models.dart';
import '../chat/chat_page.dart';
import 'post_detail_page.dart';

/// 用户主页展示页面
///
/// 复刻社交软件用户个人展示页（详见《用户展示页面设计指导.md》）：
/// 顶部返回栏 → 用户信息（头像 / 昵称 / LV5 / 资料）→ 个性签名 →
/// 操作按钮（私信 / 关注）→ 帖子列表。
///
/// 传入 [post] 时，头部与帖子使用该帖作者的头像 / 昵称；否则使用示例数据。
/// 「私信」创建会话进入聊天页，「关注」走关注接口并切换状态，失败时 Toast 提示。
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({
    super.key,
    this.post,
    this.userId,
    this.nickname,
    this.avatar,
  });

  /// 来源帖（用于展示作者头像 / 昵称）
  final FeedPost? post;

  /// 直接指定用户 ID（优先级高于 post.authorId）
  final int? userId;

  /// 直接指定昵称（优先级高于 post.username）
  final String? nickname;

  /// 直接指定头像（优先级高于 post.avatar）
  final String? avatar;

  // ---- 页面配色：与首页品牌风格统一 ----
  static const Color _primary = Color(0xFFFF718D);
  static const Color _textPrimary = Color(0xFF333033);
  static const Color _textSecondary = Color(0xFF8F898C);
  static const Color _tagBg = Color(0xFFFFF0F3);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  /// 用户 id（直接参数 > post.authorId > 0）
  int get _userId => widget.userId ?? widget.post?.authorId ?? 0;
  String get _nickname => widget.nickname ?? widget.post?.username ?? '泪.';
  String get _avatar {
    final raw = widget.avatar ?? widget.post?.avatar ?? '';
    if (raw.isNotEmpty) return ChatApi.resolveUrl(raw);
    return 'https://i.pravatar.cc/150?img=32';
  }

  /// 关注关系（null 表示尚未加载）
  FollowStatus? _follow;
  bool _followBusy = false;

  /// 该用户发布的真实作品列表
  final List<Post> _posts = [];
  bool _postsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollow();
    _loadPosts();
  }

  /// 拉取该用户的已通过作品
  Future<void> _loadPosts() async {
    try {
      final result = await PostApi.fetchByUser(_userId);
      if (mounted) {
        setState(() {
          _posts
            ..clear()
            ..addAll(result.items);
          _postsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _postsLoading = false);
    }
  }

  /// 查询与作者的关注关系（后端不可用时保持默认未关注态）
  Future<void> _loadFollow() async {
    try {
      final st = await FollowApi.status(_userId);
      if (mounted) setState(() => _follow = st);
    } catch (_) {
      // 忽略：保持默认未关注
    }
  }

  /// 关注 / 取消关注
  Future<void> _toggleFollow() async {
    setState(() => _followBusy = true);
    try {
      final st = await FollowApi.setFollow(
        _userId,
        following: !(_follow?.following ?? false),
      );
      if (mounted) setState(() => _follow = st);
    } catch (_) {
      if (mounted) _toast(context, '操作失败，请稍后再试');
    } finally {
      if (mounted) setState(() => _followBusy = false);
    }
  }

  /// 发起会话并进入聊天页
  Future<void> _openChat() async {
    ChatService.instance.ensureConnected();
    try {
      final conv = await ChatApi.createConversation(_userId);
      if (!mounted) return;
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => ChatPage(conversation: conv)));
    } catch (_) {
      if (mounted) _toast(context, '发起会话失败，请稍后再试');
    }
  }

  /// 更多：分享主页（复制链接）
  Future<void> _showMore() async {
    final messenger = ScaffoldMessenger.of(context);
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.link_rounded),
              title: const Text('分享主页'),
              onTap: () {
                Navigator.pop(sheetContext);
                Clipboard.setData(
                  ClipboardData(
                    text: 'https://diy.example.com/user/$_userId',
                  ),
                );
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('主页链接已复制'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1),
                  ),
                );
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
      backgroundColor: const Color(0xFFFFFBFC),
      // 顶部：仅返回箭头 + 更多图标，无标题
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: UserProfilePage._textPrimary,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_horiz,
              color: UserProfilePage._textPrimary,
            ),
            onPressed: _showMore,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _buildUserInfo(),
          _buildSignature(),
          _buildActions(context),
          const Divider(height: 16, thickness: 0.5, color: Color(0xFFF0E5E8)),
          // ---- 帖子列表 ----
          if (_postsLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (_posts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'TA 还没有发布作品',
                  style: TextStyle(
                    fontSize: 13,
                    color: UserProfilePage._textSecondary,
                  ),
                ),
              ),
            )
          else
            for (final p in _posts) ...[
              _PostItem(
                avatar: _avatar,
                nickname: _nickname,
                tag: p.channelTag.isNotEmpty ? p.channelTag : '#作品',
                title: p.content,
                imageUrl: _postCover(p),
                likeText: '爱了 ${formatCount(p.likeCount)}',
                viewText: '浏览 ${formatCount(p.viewCount)}',
                commentCount: '${p.commentCount}',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PostDetailPage(postId: p.id),
                  ),
                ),
              ),
              const Divider(
                height: 16,
                thickness: 0.5,
                color: Color(0xFFF0E5E8),
              ),
            ],
        ],
      ),
    );
  }

  /// 帖子封面：优先媒体首项，回退 images 首图
  String _postCover(Post p) {
    final media = p.medias.isNotEmpty ? p.medias.first.url : '';
    final url = media.isNotEmpty ? media : (p.images.isNotEmpty ? p.images.first : '');
    return url.isEmpty ? '' : ChatApi.resolveUrl(url);
  }

  /// 用户信息区域：左侧圆形头像，右侧昵称 + LV5 + 资料行
  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: Image.network(
              _avatar,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              cacheWidth: 192,
              errorBuilder: (_, _, _) => _avatarFallback(64),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 昵称 + 灰色 LV5 标签
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: UserProfilePage._textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const _Tag(label: 'LV5'),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '女 | 安徽 | 已加入11天',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: UserProfilePage._textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'IP:重庆',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: UserProfilePage._textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 头像加载失败兜底
  Widget _avatarFallback(double size) => Container(
    width: size,
    height: size,
    color: UserProfilePage._tagBg,
    child: Icon(
      Icons.person_rounded,
      size: size * 0.5,
      color: UserProfilePage._textSecondary,
    ),
  );

  /// 个性签名：字体 16，黑色
  Widget _buildSignature() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        '生而自由，爱而无畏。', // 个性签名（示例文案）
        style: const TextStyle(
          fontSize: 16,
          color: UserProfilePage._textPrimary,
          height: 1.4,
        ),
      ),
    );
  }

  /// 操作按钮行：私信（白底描边）+ 关注（蓝底白字 / 已关注灰字），均分整行宽度
  Widget _buildActions(BuildContext context) {
    final following = _follow?.following ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(label: '私信', filled: false, onTap: _openChat),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              label: following ? '已关注' : '关注',
              filled: true,
              following: following,
              busy: _followBusy,
              onTap: _toggleFollow,
            ),
          ),
        ],
      ),
    );
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

/// 灰色小标签（LV5 / #视频素材 等）
class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: UserProfilePage._tagBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10.5,
          color: UserProfilePage._textSecondary,
        ),
      ),
    );
  }
}

/// 操作按钮：私信（白色描边）、关注（蓝色填充）、已关注（白底灰字灰描边）
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
    this.following = false,
    this.busy = false,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  /// 已关注态（仅关注按钮使用）：白底 + 灰色描边 / 文字
  final bool following;

  /// 关注请求进行中：禁用并显示加载圈
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    );

    // 已关注：白底灰描边灰字，点击可取消关注
    if (filled && following) {
      return SizedBox(
        height: 40,
        child: OutlinedButton(
          onPressed: busy ? null : onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: UserProfilePage._textSecondary,
            side: BorderSide(
              color: UserProfilePage._textSecondary.withAlpha(128),
            ),
            shape: shape,
          ),
          child: Text(label, style: const TextStyle(fontSize: 15)),
        ),
      );
    }

    return SizedBox(
      height: 40,
      child: filled
          ? FilledButton(
              onPressed: busy ? null : onTap,
              style: FilledButton.styleFrom(
                backgroundColor: UserProfilePage._primary,
                foregroundColor: Colors.white,
                shape: shape,
              ),
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(label, style: const TextStyle(fontSize: 15)),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: UserProfilePage._primary,
                side: const BorderSide(color: UserProfilePage._primary),
                shape: shape,
              ),
              child: Text(label, style: const TextStyle(fontSize: 15)),
            ),
    );
  }
}

/// 帖子 Item：小头像 + 昵称 + 标签 → 标题 → 大图（左下角爱心）→ 底部数据栏
class _PostItem extends StatelessWidget {
  const _PostItem({
    required this.avatar,
    required this.nickname,
    required this.tag,
    required this.title,
    required this.imageUrl,
    required this.likeText,
    required this.viewText,
    required this.commentCount,
    this.onTap,
  });

  final String avatar;
  final String nickname;
  final String tag;
  final String title;
  final String imageUrl;

  /// 如「爱了 3」
  final String likeText;

  /// 如「浏览 220」
  final String viewText;
  final String commentCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // 作者行：小圆形头像 + 昵称 + 灰色标签
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 10),
          child: Row(
            children: [
              ClipOval(
                child: Image.network(
                  avatar,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  cacheWidth: 96,
                  errorBuilder: (_, _, _) => Container(
                    width: 32,
                    height: 32,
                    color: UserProfilePage._tagBg,
                    child: const Icon(
                      Icons.person_rounded,
                      size: 18,
                      color: UserProfilePage._textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: UserProfilePage._textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _Tag(label: tag),
            ],
          ),
        ),
        // 标题
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: UserProfilePage._textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        // 大图 + 图片底部左下角爱心按钮
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 4 / 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: UserProfilePage._tagBg,
                    child: Icon(
                      Icons.image_outlined,
                      size: 40,
                      color: UserProfilePage._textSecondary,
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  bottom: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        likeText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Colors.black45, blurRadius: 3),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // 底部状态栏：浏览 / 表情评论（数字）/ 评论气泡 / 分享箭头
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 14),
          child: Row(
            children: [
              Text(
                viewText,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: UserProfilePage._textSecondary,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.emoji_emotions_outlined,
                size: 20,
                color: UserProfilePage._textSecondary,
              ),
              const SizedBox(width: 3),
              Text(
                commentCount,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: UserProfilePage._textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 20,
                color: UserProfilePage._textSecondary,
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.send_rounded,
                size: 20,
                color: UserProfilePage._textSecondary,
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }
}
