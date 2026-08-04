import '../domain/community_models.dart';

/// 社区（频道信息流）Mock 数据源
///
/// 模拟后端返回的结构化数据。图片走 picsum / pravatar 占位服务，
/// 组件内带加载/失败兜底，断网时依然可完整展示 UI 骨架。
/// 接入真实 API 后由 `ApiCommunityRepository` 替代，数据源可整体删除。
///
/// authorId 映射到后端真实用户（id 16-25），使关注/私信可用。
abstract final class MockCommunityDataSource {
  MockCommunityDataSource._();

  /// 当前登录用户（Header 头像 / 评论输入者）
  static const CommunityUser me = CommunityUser(
    id: 10001,
    nickname: '手作小匠',
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
  );

  /// 距当前时刻 N 分钟的 ISO 时间（用于生成"刚刚/x分钟前"文案）
  static String _minutesAgo(int minutes) =>
      DateTime.now().subtract(Duration(minutes: minutes)).toIso8601String();

  /// 按 seed + 尺寸生成占位图 URL（尺寸用于对齐真实宽高比）
  static String _img(int seed, String size) =>
      'https://picsum.photos/seed/diy$seed/$size';

  /// 4:5 竖图（单图 / 双图 / 混合帖）
  static MediaItem _v(int seed, int index) => MediaItem(
        type: MediaType.image,
        url: _img(seed * 10 + index, '900/1125'),
        aspectRatio: 4 / 5,
      );

  /// 1:1 方图（网格帖）
  static MediaItem _sq(int seed, int index) => MediaItem(
        type: MediaType.image,
        url: _img(seed * 10 + index, '900/900'),
        aspectRatio: 1,
      );

  // ── 作者 ID 常量（对齐后端 users 表 16-25）──────────────────
  static const _aMatthew = 16;
  static const _aAcha = 17;
  static const _aZhizhi = 18;
  static const _aAqiang = 19;
  static const _aTaotao = 20;
  static const _aLabi = 21;
  static const _aBubu = 22;
  static const _aZhuzhu = 23;
  static const _aShouzuo = 24;
  static const _aAche = 25;

  static final List<FeedPost> posts = [
    // ── 1. 单图片帖子 ──────────────────────────────────────────
    FeedPost(
      id: 1,
      authorId: _aMatthew,
      avatar: 'https://i.pravatar.cc/150?img=32',
      username: 'matthew',
      channelTag: '#芙宁娜的后花园',
      content: '第一次做拼豆，从晚上八点拼到十一点半。手酸到不行，'
          '但看到成品的那一刻真的超级治愈！姐妹们冲鸭，拼豆真的会上瘾～',
      medias: [_v(1, 0)],
      likeCount: 43900,
      commentCount: 462,
      shareCount: 128,
      viewCount: 52310,
      reactions: ['❤️ 爱了 4.4万', '😂 笑死', '🔥 热门'],
      previewComments: [
        CommunityComment(
          user: CommunityUser(
              id: 1002, nickname: '阿茶', avatarUrl: 'https://i.pravatar.cc/150?img=44'),
          content: '配色也太好看了吧！！求教程',
          createdAt: _minutesAgo(5),
        ),
      ],
      liked: true,
    ),

    // ── 2. 两张图片帖子 ────────────────────────────────────────
    FeedPost(
      id: 2,
      authorId: _aAcha,
      avatar: 'https://i.pravatar.cc/150?img=44',
      username: '阿茶',
      channelTag: '#手作日常',
      content: '奶油胶手机壳翻车现场…挤花的时候手抖，'
          '结果意外解锁了"云朵渐变"新技能？你们觉得要留还是要重做？',
      medias: [_v(2, 0), _v(2, 1)],
      likeCount: 1024,
      commentCount: 153,
      shareCount: 88,
      viewCount: 12840,
      reactions: ['❤️ 爱了 1.0千', '😂 翻车现场'],
      previewComments: [
        CommunityComment(
          user: CommunityUser(
              id: 1003, nickname: '奶油酱', avatarUrl: 'https://i.pravatar.cc/150?img=59'),
          content: '这哪是翻车，这是凡尔赛吧',
          createdAt: _minutesAgo(20),
        ),
      ],
    ),

    // ── 3. 三张图片帖子（3 列正方形网格） ─────────────────────
    FeedPost(
      id: 3,
      authorId: _aZhizhi,
      avatar: 'https://i.pravatar.cc/150?img=45',
      username: '织织',
      channelTag: '#羊毛毡实验室',
      content: '羊毛毡新手避坑：买材料前一定要先买工具！'
          '戳针三件套 + 泡沫垫，血泪总结，评论区补充～',
      medias: [_sq(3, 0), _sq(3, 1), _sq(3, 2)],
      likeCount: 512,
      commentCount: 67,
      shareCount: 42,
      viewCount: 9876,
      reactions: ['🔥 新手避坑'],
    ),

    // ── 4. 四张图片帖子（2×2 网格） ────────────────────────────
    FeedPost(
      id: 4,
      authorId: _aAqiang,
      avatar: 'https://i.pravatar.cc/150?img=59',
      username: '木工阿强',
      channelTag: '#木工坊',
      content: '周六手作市集摆摊，卖掉了 23 个手作小物，收入 +2560。'
          '被人认可的感觉太好了，晚上回来做了个香薰蜡烛奖励自己。',
      medias: [_sq(4, 0), _sq(4, 1), _sq(4, 2), _sq(4, 3)],
      likeCount: 2314,
      commentCount: 268,
      shareCount: 156,
      viewCount: 30100,
      reactions: ['❤️ 爱了 2.3千', '🔥 摆摊日记'],
      previewComments: [
        CommunityComment(
          user: CommunityUser(
              id: 1005, nickname: '珠珠', avatarUrl: 'https://i.pravatar.cc/150?img=33'),
          content: '好厉害！求问摆摊需要办什么手续吗',
          createdAt: _minutesAgo(300),
        ),
      ],
    ),

    // ── 5. 六张图片帖子（5-9 张 → 3×3 网格） ──────────────────
    FeedPost(
      id: 5,
      authorId: _aTaotao,
      avatar: 'https://i.pravatar.cc/150?img=33',
      username: '陶陶',
      channelTag: '#陶艺研究所',
      content: '陶艺课第三节课：终于能拉出一个不歪的杯子了！'
          '老师说进步神速，开心到转圈圈，成品还在烧制中，期待开窑。',
      medias: [_sq(5, 0), _sq(5, 1), _sq(5, 2), _sq(5, 3), _sq(5, 4), _sq(5, 5)],
      likeCount: 890,
      commentCount: 96,
      shareCount: 30,
      viewCount: 6789,
      reactions: ['❤️ 爱了 8.9百'],
    ),

    // ── 6. 九张图片帖子（3×3 满格） ────────────────────────────
    FeedPost(
      id: 6,
      authorId: _aLabi,
      avatar: 'https://i.pravatar.cc/150?img=13',
      username: '蜡笔小新',
      channelTag: '#滴胶星球',
      content: '九宫格记录第一次开模具！每天解锁一个新技能，'
          '滴胶真的越玩越上头，下次挑战大摆件。',
      medias: [
        _sq(6, 0), _sq(6, 1), _sq(6, 2),
        _sq(6, 3), _sq(6, 4), _sq(6, 5),
        _sq(6, 6), _sq(6, 7), _sq(6, 8),
      ],
      likeCount: 3210,
      commentCount: 410,
      shareCount: 200,
      viewCount: 15230,
      reactions: ['❤️ 爱了 3.2千', '😂 太卷了'],
    ),

    // ── 7. 超过九张图片帖子（第 9 张叠加 "+剩余"） ─────────────
    FeedPost(
      id: 7,
      authorId: _aBubu,
      avatar: 'https://i.pravatar.cc/150?img=48',
      username: '布布',
      channelTag: '#串珠手作',
      content: '给闺蜜串的生日手链，12 颗菩提 + 绿松石混搭。'
          '她说戴出去被问了一路在哪买的，这种独一无二的礼物，真的比买什么都珍贵。',
      medias: [
        _sq(7, 0), _sq(7, 1), _sq(7, 2),
        _sq(7, 3), _sq(7, 4), _sq(7, 5),
        _sq(7, 6), _sq(7, 7), _sq(7, 8),
        _sq(7, 9), _sq(7, 10), _sq(7, 11),
      ],
      likeCount: 5210,
      commentCount: 622,
      shareCount: 350,
      viewCount: 24300,
      reactions: ['❤️ 爱了 5.2千', '🔥 手作大神'],
    ),

    // ── 8. 横屏视频帖子（16:9 全宽） ───────────────────────────
    FeedPost(
      id: 8,
      authorId: _aZhuzhu,
      avatar: 'https://i.pravatar.cc/150?img=52',
      username: '珠珠',
      channelTag: '#摄影手作',
      content: '第一次尝试拍摄手作过程 Vlog，横屏 16:9 录起来舒服多了。'
          '从拼装到打磨，全程治愈，记得看到最后～',
      medias: [
        MediaItem(
          type: MediaType.video,
          url: _img(8, '1280/720'),
          aspectRatio: 16 / 9,
          duration: const Duration(seconds: 32),
        ),
      ],
      likeCount: 6780,
      commentCount: 520,
      shareCount: 410,
      viewCount: 40100,
      reactions: ['❤️ 爱了 6.7千', '🔥 热门'],
      previewComments: [
        CommunityComment(
          user: CommunityUser(
              id: 1007, nickname: '布布', avatarUrl: 'https://i.pravatar.cc/150?img=48'),
          content: '收音怎么做的？求设备清单',
          createdAt: _minutesAgo(120),
        ),
      ],
    ),

    // ── 9. 竖屏视频帖子（9:16 限高 600 裁剪） ──────────────────
    FeedPost(
      id: 9,
      authorId: _aShouzuo,
      avatar: 'https://i.pravatar.cc/150?img=12',
      username: '手作小匠',
      channelTag: '#手作vlog',
      content: '竖屏 9:16 的沉浸式手作卡点视频来啦！'
          '蜡烛脱模的瞬间真的绝了，全程高能。',
      medias: [
        MediaItem(
          type: MediaType.video,
          url: _img(9, '720/1280'),
          aspectRatio: 9 / 16,
          duration: const Duration(seconds: 58),
        ),
      ],
      likeCount: 1210,
      commentCount: 88,
      shareCount: 26,
      viewCount: 8300,
      reactions: ['😂 卡点绝了'],
    ),

    // ── 10. 图片 + 视频混合帖子（按顺序统一进入媒体网格） ──────
    FeedPost(
      id: 10,
      authorId: _aAche,
      avatar: 'https://i.pravatar.cc/150?img=15',
      username: '阿澈',
      channelTag: '#芙宁娜的后花园',
      content: '拼豆 + 过程视频一起发！图二是成品特写，'
          '最后还有一段 15 秒的拼装过程，喜欢请一键三连～',
      medias: [
        _v(10, 0),
        _v(10, 1),
        MediaItem(
          type: MediaType.video,
          url: _img(10, '900/900'),
          aspectRatio: 1,
          duration: const Duration(seconds: 15),
        ),
      ],
      likeCount: 2750,
      commentCount: 318,
      shareCount: 190,
      viewCount: 18900,
      reactions: ['❤️ 爱了 2.7千', '😂 笑死'],
    ),
  ];
}
