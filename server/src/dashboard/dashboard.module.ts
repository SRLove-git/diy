import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Appointment } from '../appointments/appointment.entity';
import { Comment } from '../community/comment.entity';
import { Like } from '../community/like.entity';
import { Post } from '../community/post.entity';
import { User } from '../users/user.entity';
import { UsersModule } from '../users/users.module';
import { AdminDashboardController } from './admin-dashboard.controller';
import { DashboardService } from './dashboard.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([User, Appointment, Post, Like, Comment]),
    UsersModule,
  ],
  controllers: [AdminDashboardController],
  providers: [DashboardService],
})
export class DashboardModule {}
