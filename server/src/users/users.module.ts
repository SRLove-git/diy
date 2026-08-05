import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './user.entity';
import { History } from './history.entity';
import { Post } from '../community/post.entity';
import { Like } from '../community/like.entity';
import { Comment } from '../community/comment.entity';
import { Collection } from '../community/collection.entity';
import { Report } from '../community/report.entity';
import { Video } from '../videos/video.entity';
import { VideoLike } from '../videos/video-like.entity';
import { VideoComment } from '../videos/video-comment.entity';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { AdminUsersController } from './admin-users.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      User,
      History,
      Post,
      Like,
      Comment,
      Collection,
      Report,
      Video,
      VideoLike,
      VideoComment,
    ]),
    JwtModule.register({}),
  ],
  controllers: [UsersController, AdminUsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
