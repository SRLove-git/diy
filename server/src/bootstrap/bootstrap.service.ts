import { Injectable, Logger, OnApplicationBootstrap } from '@nestjs/common';
import { MusicService } from '../music/music.service';
import { NotificationsService } from '../notifications/notifications.service';
import { UsersService } from '../users/users.service';
import { VideosService } from '../videos/videos.service';

/** 开发环境预置的演示作者（避免与真实注册手机号冲突） */
interface DemoAuthor {
  phone: string;
  nickname: string;
  avatar: string;
}

/** 开发环境预置的演示短视频 */
interface DemoVideo {
  authorPhone: string;
  title: string;
  cover: string;
  videoUrl: string;
  duration: number;
  music: string;
  tags: string[];
}

/** 演示作者 */
const DEMO_AUTHORS: DemoAuthor[] = [
  {
    phone: '13900000001',
    nickname: '珠珠',
    avatar: 'https://i.pravatar.cc/150?img=33',
  },
  {
    phone: '13900000002',
    nickname: '拼豆小匠',
    avatar: 'https://i.pravatar.cc/150?img=12',
  },
  {
    phone: '13900000003',
    nickname: '串串',
    avatar: 'https://i.pravatar.cc/150?img=45',
  },
];

/** 演示短视频（封面走 picsum 占位服务；视频流为 assets/demo 下的真实 mp4） */
const DEMO_VIDEOS: DemoVideo[] = [
  {
    authorPhone: '13900000001',
    title:
      '拼豆新手第一课：镊子怎么夹才稳？摆豆不歪的 3 个小技巧，小白 10 分钟上手。',
    cover: 'https://picsum.photos/seed/diyseed1/720/1280',
    videoUrl: '/assets/demo/demo-01.mp4',
    duration: 15,
    music: '《豆豆乐园》- 拼豆 BGM',
    tags: ['拼豆', '新手教程', '摆豆技巧'],
  },
  {
    authorPhone: '13900000002',
    title: '串珠手链 12 颗菩提 + 绿松石，闺蜜戴出去被问了一路在哪买的！',
    cover: 'https://picsum.photos/seed/diyseed2/720/1280',
    videoUrl: '/assets/demo/demo-02.mp4',
    duration: 12,
    music: '《珠光》- 轻快手作',
    tags: ['串珠', '手链', '闺蜜礼物'],
  },
  {
    authorPhone: '13900000003',
    title: '拼豆定型翻车现场：温度太高豆子直接化成一滩…下次记得先垫烫纸！',
    cover: 'https://picsum.photos/seed/diyseed3/720/1280',
    videoUrl: '/assets/demo/demo-03.mp4',
    duration: 15,
    music: '《拼豆节拍》- 卡点神曲',
    tags: ['拼豆', '定型', '翻车现场'],
  },
  {
    authorPhone: '13900000001',
    title: '第一次做立体拼豆，从图纸到成品全程 9:16 卡点，看得停不下来。',
    cover: 'https://picsum.photos/seed/diyseed4/720/1280',
    videoUrl: '/assets/demo/demo-04.mp4',
    duration: 14,
    music: '《手作时光》- 氛围音乐',
    tags: ['立体拼豆', '卡点', '手作'],
  },
  {
    authorPhone: '13900000002',
    title: '拼豆像素图怎么设计？用手机画图软件 3 分钟搞定图纸，附配色思路。',
    cover: 'https://picsum.photos/seed/diyseed5/720/1280',
    videoUrl: '/assets/demo/demo-05.mp4',
    duration: 13,
    music: '《串珠小调》- 手工串珠',
    tags: ['拼豆', '图纸设计', '教程'],
  },
  {
    authorPhone: '13900000003',
    title: '串珠耳饰新手避坑：选珠、穿线、收尾三件套，别再买错材料啦！',
    cover: 'https://picsum.photos/seed/diyseed6/720/1280',
    videoUrl: '/assets/demo/demo-06.mp4',
    duration: 15,
    music: '《彩珠圆舞曲》- 轻音乐',
    tags: ['串珠', '耳饰', '新手避坑'],
  },
];

/** 开发环境预置的演示配乐 */
interface DemoMusic {
  title: string;
  artist: string;
  duration: number;
  /** 音频 URL；缺省时回退到 SoundHelix 公共示例 */
  musicUrl?: string;
}

/** 演示配乐（音频走 SoundHelix 公共示例，客户端可试听） */
const DEMO_MUSIC: DemoMusic[] = [
  { title: '豆豆乐园', artist: '拼豆 BGM', duration: 180 },
  { title: '珠光', artist: '轻快手作', duration: 120 },
  { title: '拼豆节拍', artist: '卡点神曲', duration: 150 },
  { title: '串珠小调', artist: '手工串珠', duration: 90 },
  { title: '彩珠圆舞曲', artist: '轻音乐', duration: 200 },
  { title: '手作时光', artist: '氛围音乐', duration: 130 },
  {
    title: '1000 Funk Songs (In A Day)',
    artist: 'Thomas Park',
    duration: 192,
    musicUrl: '/assets/music/thomas-park-1000-funk-songs.mp3',
  },
];

/** 启动初始化：开发环境预置管理员账号 + 演示短视频 */
@Injectable()
export class BootstrapService implements OnApplicationBootstrap {
  private readonly logger = new Logger(BootstrapService.name);
  private readonly ADMIN_PHONE = '13800000000';

  constructor(
    private readonly users: UsersService,
    private readonly videos: VideosService,
    private readonly music: MusicService,
    private readonly notifications: NotificationsService,
  ) {}

  async onApplicationBootstrap() {
    if (process.env.NODE_ENV === 'production') return;
    await this.ensureAdmin();
    await this.seedDemoVideos();
    await this.seedDemoMusic();
    await this.seedDemoNotifications();
  }

  private async ensureAdmin() {
    const admin = await this.users.findByPhone(this.ADMIN_PHONE);
    if (!admin) {
      await this.users.create({
        phone: this.ADMIN_PHONE,
        role: 'admin',
        nickname: '管理员',
      });
      this.logger.log(`已创建开发管理员账号：${this.ADMIN_PHONE}（admin）`);
    } else if (admin.role !== 'admin') {
      await this.users.setRole(admin.id, 'admin');
      this.logger.log(`已将 ${this.ADMIN_PHONE} 角色更新为 admin`);
    }
  }

  /** 短视频表为空时预置演示数据，保证信息流可演示 */
  private async seedDemoVideos() {
    const count = await this.videos.countVideos();
    if (count === 0) {
      // 创建/复用演示作者并补齐昵称头像
      const authorByPhone = new Map<string, number>();
      for (const a of DEMO_AUTHORS) {
        const user = await this.users.findByPhoneOrCreate(a.phone);
        await this.users.updateProfile(user.id, {
          nickname: a.nickname,
          avatar: a.avatar,
        });
        authorByPhone.set(a.phone, user.id);
      }

      for (const v of DEMO_VIDEOS) {
        const userId = authorByPhone.get(v.authorPhone);
        if (!userId) continue;
        await this.videos.create(userId, {
          title: v.title,
          content: v.title,
          cover: v.cover,
          videoUrl: v.videoUrl,
          duration: v.duration,
          music: v.music,
          tags: v.tags,
        });
      }
      this.logger.log(`已预置 ${DEMO_VIDEOS.length} 条演示短视频`);
    }

    // 兼容旧演示数据：把「封面图当视频流」的历史种子行修复为真实视频
    const repaired = await this.videos.repairImageVideos(
      DEMO_VIDEOS.map((v) => ({
        videoUrl: v.videoUrl,
        duration: v.duration,
      })),
    );
    if (repaired > 0) {
      this.logger.log(`已将 ${repaired} 条旧演示视频修复为真实视频`);
    }
  }

  /** 曲库为空时按曲目预置演示配乐（按歌名+歌手去重，保证拍摄页可选） */
  private async seedDemoMusic() {
    for (let i = 0; i < DEMO_MUSIC.length; i++) {
      const m = DEMO_MUSIC[i];
      const exists = await this.music.findByTitleArtist(m.title, m.artist);
      if (exists) continue;
      await this.music.create({
        title: m.title,
        artist: m.artist,
        duration: m.duration,
        musicUrl:
          m.musicUrl ??
          `https://www.soundhelix.com/examples/mp3/SoundHelix-Song-${i + 1}.mp3`,
      });
    }
    this.logger.log('已确保预置演示配乐就绪');
  }

  /** 通知表为空时预置全员通知，便于首页角标/通知页演示 */
  private async seedDemoNotifications() {
    const count = await this.notifications.countAll();
    if (count > 0) return;
    await this.notifications.createAndSend({
      title: '欢迎来到 IDOL BEADS 拼豆乐园',
      content: '新用户专享体验价 ¥39.9/次起，快去预约你的第一次拼豆体验吧！',
      targetType: 'all',
      channels: 'push',
    });
    await this.notifications.createAndSend({
      title: '拼豆作品征集活动开启',
      content: '发布你的拼豆作品参与评选，人气作品将获得门店专属体验券。',
      targetType: 'all',
      channels: 'push',
    });
    this.logger.log('已预置演示通知');
  }
}
