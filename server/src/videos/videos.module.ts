import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Follow } from '../follows/follow.entity';
import { User } from '../users/user.entity';
import { Video } from './video.entity';
import { VideoComment } from './video-comment.entity';
import { VideoLike } from './video-like.entity';
import { VideosController } from './videos.controller';
import { AdminVideosController } from './admin-videos.controller';
import { VideosService } from './videos.service';
import { UsersModule } from '../users/users.module';
import { CommunityModule } from '../community/community.module';
import { Report } from '../community/report.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Video,
      VideoLike,
      VideoComment,
      Follow,
      User,
      Report,
    ]),
    UsersModule,
    CommunityModule,
  ],
  controllers: [VideosController, AdminVideosController],
  providers: [VideosService],
  exports: [VideosService],
})
export class VideosModule {}
