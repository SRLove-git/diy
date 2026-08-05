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
  duration: number;
  music: string;
  tags: string[];
}

/** 演示作者 */
const DEMO_AUTHORS: DemoAuthor[] = [
  {
    phone: '13900000001',
    nickname: '阿茶',
    avatar: 'https://i.pravatar.cc/150?img=44',
  },
  {
    phone: '13900000002',
    nickname: '手作小匠',
    avatar: 'https://i.pravatar.cc/150?img=12',
  },
  {
    phone: '13900000003',
    nickname: '织织',
    avatar: 'https://i.pravatar.cc/150?img=45',
  },
];

/** 演示短视频（封面走 picsum 占位服务） */
const DEMO_VIDEOS: DemoVideo[] = [
  {
    authorPhone: '13900000001',
    title: '奶油胶手机壳翻车现场…挤花手抖，结果意外解锁了"云朵渐变"？',
    cover: 'https://picsum.photos/seed/diyseed1/720/1280',
    duration: 15,
    music: '《Lofi 手作日常》- Chill Beats',
    tags: ['奶油胶', '手机壳', '翻车现场'],
  },
  {
    authorPhone: '13900000002',
    title: '蜡烛脱模的瞬间真的绝了！9:16 沉浸式卡点，全程高能。',
    cover: 'https://picsum.photos/seed/diyseed2/720/1280',
    duration: 19,
    music: '《烛光》- 卡点神曲',
    tags: ['香薰蜡烛', '脱模', '卡点'],
  },
  {
    authorPhone: '13900000003',
    title: '羊毛毡新手避坑：买材料前一定要先买工具！戳针三件套 + 泡沫垫。',
    cover: 'https://picsum.photos/seed/diyseed3/720/1280',
    duration: 42,
    music: '《羊毛毡小调》- 手工 BGM',
    tags: ['羊毛毡', '新手避坑', '手作'],
  },
  {
    authorPhone: '13900000001',
    title: '给闺蜜串的生日手链，12 颗菩提 + 绿松石混搭，独一无二！',
    cover: 'https://picsum.photos/seed/diyseed4/720/1280',
    duration: 24,
    music: '《珠光》- 轻快手作',
    tags: ['串珠', '手链', '闺蜜礼物'],
  },
  {
    authorPhone: '13900000002',
    title: '第一次尝试拍摄手作过程 Vlog，从拼装到打磨，记得看到最后～',
    cover: 'https://picsum.photos/seed/diyseed5/720/1280',
    duration: 58,
    music: '《手作时光》- 氛围音乐',
    tags: ['Vlog', '手作', '教程'],
  },
  {
    authorPhone: '13900000003',
    title: '用钩针钩一个星黛露玩偶，从零开始 15 分钟速成教程！',
    cover: 'https://picsum.photos/seed/diyseed6/720/1280',
    duration: 37,
    music: '《毛线球》- 手工编织',
    tags: ['钩针', '星黛露', '玩偶'],
  },
];

/** 开发环境预置的演示配乐 */
interface DemoMusic {
  title: string;
  artist: string;
  duration: number;
}

/** 演示配乐（音频走 SoundHelix 公共示例，客户端可试听） */
const DEMO_MUSIC: DemoMusic[] = [
  { title: 'Lofi 手作日常', artist: 'Chill Beats', duration: 180 },
  { title: '烛光', artist: '卡点神曲', duration: 120 },
  { title: '羊毛毡小调', artist: '手工 BGM', duration: 150 },
  { title: '珠光', artist: '轻快手作', duration: 90 },
  { title: '手作时光', artist: '氛围音乐', duration: 200 },
  { title: '毛线球', artist: '手工编织', duration: 130 },
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
    if (count > 0) return;

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
        videoUrl: v.cover,
        duration: v.duration,
        music: v.music,
        tags: v.tags,
      });
    }
    this.logger.log(`已预置 ${DEMO_VIDEOS.length} 条演示短视频`);
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
        musicUrl: `https://www.soundhelix.com/examples/mp3/SoundHelix-Song-${i + 1}.mp3`,
      });
    }
    this.logger.log('已确保预置演示配乐就绪');
  }

  /** 通知表为空时预置全员通知，便于首页角标/通知页演示 */
  private async seedDemoNotifications() {
    const count = await this.notifications.countAll();
    if (count > 0) return;
    await this.notifications.createAndSend({
      title: '欢迎来到拾染爱恋手作工坊',
      content: '新用户专享体验价 ¥39.9/次起，快去预约你第一次拼豆体验吧！',
      targetType: 'all',
      channels: 'push',
    });
    await this.notifications.createAndSend({
      title: '社区作品征集活动开启',
      content: '发布你的 DIY 作品参与评选，人气作品将获得门店专属体验券。',
      targetType: 'all',
      channels: 'push',
    });
    this.logger.log('已预置演示通知');
  }
}
