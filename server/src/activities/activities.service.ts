import {
  Injectable,
  Logger,
  NotFoundException,
  OnModuleInit,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SaveActivityDto } from './activity.dto';
import { Activity } from './activity.entity';

/** 活动数据：活动专区 / 会员套餐页共用的数据源 */
@Injectable()
export class ActivitiesService implements OnModuleInit {
  private readonly logger = new Logger(ActivitiesService.name);

  constructor(
    @InjectRepository(Activity)
    private readonly activities: Repository<Activity>,
  ) {}

  async onModuleInit() {
    // 按标题去重逐条补种，避免多个实例同时启动时重复插入
    const seeds = [
      {
        title: '周末会员沙龙「奶油胶手作日」',
        date: '08-16 14:00',
        desc: '会员免费参与，到场即送材料包一份，成品可带走。',
        tag: '限会员',
        membersOnly: true,
        sort: 1,
      },
      {
        title: '拼豆作品大赛',
        date: '08-22 起',
        desc: '上传拼豆作品参与评选，会员投稿双倍积分，前三名赢大奖。',
        tag: '双倍积分',
        sort: 2,
      },
      {
        title: '中秋月饼 DIY 特别场',
        date: '09-06 起',
        desc: '会员早鸟预约享 8 折，含月饼礼盒一份。',
        tag: '早鸟 8 折',
        sort: 3,
      },
    ];
    let inserted = 0;
    for (const seed of seeds) {
      const exists = await this.activities.findOneBy({ title: seed.title });
      if (exists) continue;
      await this.activities.save(this.activities.create(seed));
      inserted += 1;
    }
    if (inserted) this.logger.log(`已预置 ${inserted} 条演示活动数据`);
  }

  /** 上架中的活动（用户端） */
  list() {
    return this.activities.find({
      where: { enabled: true },
      order: { sort: 'ASC', id: 'ASC' },
    });
  }

  /** 全部活动（管理端） */
  listAll() {
    return this.activities.find({ order: { sort: 'ASC', id: 'ASC' } });
  }

  async create(dto: SaveActivityDto) {
    const item = this.activities.create({
      title: dto.title,
      date: dto.date,
      desc: dto.desc ?? '',
      tag: dto.tag ?? '',
      membersOnly: dto.membersOnly ?? false,
      enabled: dto.enabled ?? true,
      sort: dto.sort ?? 0,
    });
    return this.activities.save(item);
  }

  async update(id: number, dto: Partial<SaveActivityDto>) {
    const item = await this.activities.findOneBy({ id });
    if (!item) throw new NotFoundException('活动不存在');
    Object.assign(item, {
      title: dto.title ?? item.title,
      date: dto.date ?? item.date,
      desc: dto.desc ?? item.desc,
      tag: dto.tag ?? item.tag,
      membersOnly: dto.membersOnly ?? item.membersOnly,
      enabled: dto.enabled ?? item.enabled,
      sort: dto.sort ?? item.sort,
    });
    return this.activities.save(item);
  }

  async toggleEnabled(id: number, enabled: boolean) {
    const item = await this.activities.findOneBy({ id });
    if (!item) throw new NotFoundException('活动不存在');
    item.enabled = enabled;
    return this.activities.save(item);
  }
}
