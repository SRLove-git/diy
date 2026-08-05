import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CommunityService } from './community.service';
import { PostsController } from './posts.controller';
import { AdminPostsController } from './admin-posts.controller';
import { AdminReportsController } from './admin-reports.controller';
import { Post } from './post.entity';
import { Like } from './like.entity';
import { Comment } from './comment.entity';
import { Collection } from './collection.entity';
import { Report } from './report.entity';
import { Follow } from '../follows/follow.entity';
import { History } from '../users/history.entity';
import { User } from '../users/user.entity';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Post,
      Like,
      Comment,
      Collection,
      Report,
      Follow,
      History,
      User,
    ]),
    UsersModule,
  ],
  controllers: [PostsController, AdminPostsController, AdminReportsController],
  providers: [CommunityService],
  exports: [CommunityService],
})
export class CommunityModule {}
