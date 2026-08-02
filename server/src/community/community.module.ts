import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CommunityService } from './community.service';
import { PostsController } from './posts.controller';
import { AdminPostsController } from './admin-posts.controller';
import { Post } from './post.entity';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [TypeOrmModule.forFeature([Post]), UsersModule],
  controllers: [PostsController, AdminPostsController],
  providers: [CommunityService],
  exports: [CommunityService],
})
export class CommunityModule {}
