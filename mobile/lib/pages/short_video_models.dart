import '../features/community/domain/community_models.dart';

/// 短视频领域模型（信息流单条）
///
/// 与 UI / 数据源解耦：接入真实 API 后替换 [MockShortVideoDataSource] 即可，
/// 模型保持稳定。评论复用社区通用 [CommunityComment] / [CommunityUser]。
class ShortVideo {
  const ShortVideo({
    required this.id,
    required this.authorId,
    required this.user,
    required this.avatar,
    required this.title,
    required this.cover,
    required this.duration,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.followCount,
    required this.tags,
    required this.music,
    this.comments = const [],
    this.liked = false,
  });

  final int id;

  /// 作者的后端用户 ID（关注用）
  final int authorId;

  /// 作者昵称
  final String user;

  /// 作者头像 URL
  final String avatar;

  /// 视频标题 / 文案
  final String title;

  /// 视频封面 URL（Mock 播放：封面静态图 + AnimationController 模拟进度）
  final String cover;

  /// 视频时长
  final Duration duration;

  final int likeCount;
  final int commentCount;
  final int shareCount;

  /// 作者粉丝数
  final int followCount;

  /// 话题标签，如 `#拼豆`
  final List<String> tags;

  /// 配乐名称
  final String music;

  /// 评论列表（评论弹层内展示，本地追加）
  final List<CommunityComment> comments;

  final bool liked;

  ShortVideo copyWith({
    int? likeCount,
    int? commentCount,
    int? shareCount,
    List<CommunityComment>? comments,
    bool? liked,
  }) =>
      ShortVideo(
        id: id,
        authorId: authorId,
        user: user,
        avatar: avatar,
        title: title,
        cover: cover,
        duration: duration,
        likeCount: likeCount ?? this.likeCount,
        commentCount: commentCount ?? this.commentCount,
        shareCount: shareCount ?? this.shareCount,
        followCount: followCount,
        tags: tags,
        music: music,
        comments: comments ?? this.comments,
        liked: liked ?? this.liked,
      );
}

/// 短视频 Mock 数据源
///
/// 封面走 picsum 占位服务，组件内带加载/失败兜底；
/// authorId 映射到后端真实用户（16-25），使关注功能可用。
abstract final class MockShortVideoDataSource {
  MockShortVideoDataSource._();

  /// 当前登录用户（评论输入者）
  static const CommunityUser me = CommunityUser(
    id: 10001,
    nickname: '手作小匠',
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
  );

  /// 9:16 竖屏封面
  static String _cover(int seed) =>
      'https://picsum.photos/seed/diyv$seed/720/1280';

  static CommunityComment _comment(
    int userId,
    String name,
    String img,
    String content,
    int minutesAgo,
  ) =>
      CommunityComment(
        user: CommunityUser(
          id: userId,
          nickname: name,
          avatarUrl: 'https://i.pravatar.cc/150?img=$img',
        ),
        content: content,
        createdAt: DateTime.now()
            .subtract(Duration(minutes: minutesAgo))
            .toIso8601String(),
      );

  static final List<ShortVideo> videos = [
    ShortVideo(
      id: 1,
      authorId: 16,
      user: 'matthew',
      avatar: 'https://i.pravatar.cc/150?img=32',
      title: '第一次做拼豆，从晚上八点拼到十一点半。看到成品那一刻真的超级治愈！',
      cover: _cover(1),
      duration: const Duration(seconds: 28),
      likeCount: 43900,
      commentCount: 462,
      shareCount: 128,
      followCount: 12400,
      tags: ['拼豆', '手作', '治愈'],
      music: '《Handmade Moments》- 轻治愈纯音乐',
      comments: [
        _comment(1002, '阿茶', '44', '配色也太好看了吧！！求教程', 5),
        _comment(1003, '奶油酱', '59', '拼豆真的会上瘾，入坑第三天', 60),
      ],
      liked: true,
    ),
    ShortVideo(
      id: 2,
      authorId: 17,
      user: '阿茶',
      avatar: 'https://i.pravatar.cc/150?img=44',
      title: '奶油胶手机壳翻车现场…挤花手抖，结果意外解锁了"云朵渐变"？',
      cover: _cover(2),
      duration: const Duration(seconds: 15),
      likeCount: 1024,
      commentCount: 153,
      shareCount: 88,
      followCount: 5600,
      tags: ['奶油胶', '手机壳', '翻车现场'],
      music: '《Lofi 手作日常》- Chill Beats',
      comments: [
        _comment(1003, '奶油酱', '59', '这哪是翻车，这是凡尔赛吧', 20),
      ],
    ),
    ShortVideo(
      id: 3,
      authorId: 18,
      user: '织织',
      avatar: 'https://i.pravatar.cc/150?img=45',
      title: '羊毛毡新手避坑：买材料前一定要先买工具！戳针三件套 + 泡沫垫。',
      cover: _cover(3),
      duration: const Duration(seconds: 42),
      likeCount: 512,
      commentCount: 67,
      shareCount: 42,
      followCount: 3200,
      tags: ['羊毛毡', '新手避坑', '手作'],
      music: '《羊毛毡小调》- 手工 BGM',
      comments: [
        _comment(1006, '针线姑娘', '47', '血泪教训，我当初就是没买泡沫垫，戳坏一张桌子', 120),
        _comment(1005, '珠珠', '33', '收藏了！下次入坑用', 300),
      ],
    ),
    ShortVideo(
      id: 4,
      authorId: 19,
      user: '木工阿强',
      avatar: 'https://i.pravatar.cc/150?img=59',
      title: '木头雕刻一只小猫咪，从画稿到打磨，全程 40 倍速！',
      cover: _cover(4),
      duration: const Duration(seconds: 46),
      likeCount: 2314,
      commentCount: 268,
      shareCount: 156,
      followCount: 8700,
      tags: ['木雕', '木工', '猫咪'],
      music: '《木屑飞扬》- 木工坊实录',
      comments: [
        _comment(1007, '布布', '48', '这手活太稳了，大佬收徒吗', 50),
      ],
    ),
    ShortVideo(
      id: 5,
      authorId: 20,
      user: '陶陶',
      avatar: 'https://i.pravatar.cc/150?img=33',
      title: '陶艺课第三节课：终于能拉出一个不歪的杯子了！老师说我进步神速。',
      cover: _cover(5),
      duration: const Duration(seconds: 33),
      likeCount: 890,
      commentCount: 96,
      shareCount: 30,
      followCount: 4100,
      tags: ['陶艺', '拉坯', '日常'],
      music: '《陶土的味道》- 手工陶艺',
      comments: [
        _comment(1004, '木工阿强', '59', '期待开窑！烧出来一定很有成就感', 90),
      ],
    ),
    ShortVideo(
      id: 6,
      authorId: 21,
      user: '蜡笔小新',
      avatar: 'https://i.pravatar.cc/150?img=13',
      title: '滴胶真的越玩越上头，第一次开模具，全程高能！',
      cover: _cover(6),
      duration: const Duration(seconds: 51),
      likeCount: 3210,
      commentCount: 410,
      shareCount: 200,
      followCount: 9800,
      tags: ['滴胶', '开模', '上头'],
      music: '《水晶滴胶》- 治愈系',
      comments: [
        _comment(1002, '阿茶', '44', '气泡怎么排掉的？求教学', 8),
        _comment(1005, '珠珠', '33', '下次挑战大摆件！', 200),
      ],
    ),
    ShortVideo(
      id: 7,
      authorId: 22,
      user: '布布',
      avatar: 'https://i.pravatar.cc/150?img=48',
      title: '给闺蜜串的生日手链，12 颗菩提 + 绿松石混搭，独一无二！',
      cover: _cover(7),
      duration: const Duration(seconds: 24),
      likeCount: 5210,
      commentCount: 622,
      shareCount: 350,
      followCount: 15600,
      tags: ['串珠', '手链', '闺蜜礼物'],
      music: '《珠光》- 轻快手作',
      comments: [
        _comment(1003, '奶油酱', '59', '被问了一路在哪买的哈哈哈', 15),
        _comment(1006, '针线姑娘', '47', '菩提盘出来会更好看！', 45),
      ],
    ),
    ShortVideo(
      id: 8,
      authorId: 23,
      user: '珠珠',
      avatar: 'https://i.pravatar.cc/150?img=52',
      title: '第一次尝试拍摄手作过程 Vlog，从拼装到打磨，记得看到最后～',
      cover: _cover(8),
      duration: const Duration(seconds: 58),
      likeCount: 6780,
      commentCount: 520,
      shareCount: 410,
      followCount: 23000,
      tags: ['Vlog', '手作', '教程'],
      music: '《手作时光》- 氛围音乐',
      comments: [
        _comment(1007, '布布', '48', '收音怎么做的？求设备清单', 30),
      ],
    ),
    ShortVideo(
      id: 9,
      authorId: 24,
      user: '手作小匠',
      avatar: 'https://i.pravatar.cc/150?img=12',
      title: '蜡烛脱模的瞬间真的绝了！9:16 沉浸式卡点，全程高能。',
      cover: _cover(9),
      duration: const Duration(seconds: 19),
      likeCount: 1210,
      commentCount: 88,
      shareCount: 26,
      followCount: 300,
      tags: ['香薰蜡烛', '脱模', '卡点'],
      music: '《烛光》- 卡点神曲',
      comments: [
        _comment(1002, '阿茶', '44', '这个脱模音效也太治愈了', 3),
      ],
    ),
    ShortVideo(
      id: 10,
      authorId: 25,
      user: '阿澈',
      avatar: 'https://i.pravatar.cc/150?img=15',
      title: '用钩针钩一个星黛露玩偶，从零开始 15 分钟速成教程！',
      cover: _cover(10),
      duration: const Duration(seconds: 37),
      likeCount: 2750,
      commentCount: 318,
      shareCount: 190,
      followCount: 7200,
      tags: ['钩针', '星黛露', '玩偶'],
      music: '《毛线球》- 手工编织',
      comments: [
        _comment(1006, '针线姑娘', '47', '针法太清晰了，跟着勾完了！', 70),
        _comment(1003, '奶油酱', '59', '眼睛装反了吧哈哈哈可爱', 160),
      ],
    ),
  ];
}
