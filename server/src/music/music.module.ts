import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Music } from './music.entity';
import { MusicController } from './music.controller';
import { MusicService } from './music.service';

/** 曲库模块：拍摄页选择配乐的数据源 */
@Module({
  imports: [TypeOrmModule.forFeature([Music])],
  controllers: [MusicController],
  providers: [MusicService],
  exports: [MusicService],
})
export class MusicModule {}
