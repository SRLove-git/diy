import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { ILike, Repository } from 'typeorm';
import { Music } from './music.entity';

/** 曲库查询：支持按歌名/歌手模糊搜索，分页返回 */
@Injectable()
export class MusicService {
  constructor(
    @InjectRepository(Music)
    private readonly music: Repository<Music>,
  ) {}

  /** 按 ID 查找曲目（发布混音/管理端用） */
  findById(id: number) {
    return this.music.findOneBy({ id });
  }

  /** 按歌名+歌手精确查找（种子数据防重复） */
  findByTitleArtist(title: string, artist: string) {
    return this.music.findOne({ where: { title, artist } });
  }

  /** 新增曲目（开发种子数据用） */
  async create(data: {
    title: string;
    artist: string;
    cover?: string;
    musicUrl?: string;
    duration?: number;
  }) {
    const item = this.music.create({
      title: data.title,
      artist: data.artist,
      cover: data.cover ?? '',
      musicUrl: data.musicUrl ?? '',
      duration: data.duration ?? 0,
    });
    return this.music.save(item);
  }

  /** 曲库列表（歌名/歌手模糊匹配，按创建时间倒序） */
  async list(keyword?: string, page = 1, pageSize = 50) {
    const where = keyword
      ? [{ title: ILike(`%${keyword}%`) }, { artist: ILike(`%${keyword}%`) }]
      : undefined;
    const [items, total] = await this.music.findAndCount({
      where,
      order: { createdAt: 'DESC' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });
    return [items, total] as const;
  }
}
