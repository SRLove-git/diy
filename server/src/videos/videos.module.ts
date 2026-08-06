import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Follow } from '../follows/follow.entity';
import { User } from '../users/user.entity';
import { Video } from './video.entity';
import { VideoComment } from './video-comment.entity';
import { VideoCommentLike } from './video-comment-like.entity';
import { VideoHistory } from './video-history.entity';
import { VideoLike } from './video-like.entity';
import { VideosController } from './videos.controller';
import { AdminVideosController } from './admin-videos.controller';
import { VideosService } from './videos.service';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Video,
      VideoLike,
      VideoComment,
      VideoCommentLike,
      VideoHistory,
      Follow,
      User,
    ]),
    UsersModule,
  ],
  controllers: [VideosController, AdminVideosController],
  providers: [VideosService],
  exports: [VideosService],
})
export class VideosModule {}
