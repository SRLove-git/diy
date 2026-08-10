import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { join } from 'path';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AppointmentsModule } from './appointments/appointments.module';
import { ActivitiesModule } from './activities/activities.module';
import { AuthModule } from './auth/auth.module';
import { ChatModule } from './chat/chat.module';
import { CommunityModule } from './community/community.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { FollowsModule } from './follows/follows.module';
import { NotificationsModule } from './notifications/notifications.module';
import { BootstrapService } from './bootstrap/bootstrap.service';
import { GlobalJwtModule } from './common/global-jwt.module';
import { HealthController } from './health/health.controller';
import { MusicModule } from './music/music.module';
import { MembersModule } from './members/members.module';
import { ModerationModule } from './moderation/moderation.module';
import { RedisModule } from './redis/redis.module';
import { StoresModule } from './stores/stores.module';
import { UploadsModule } from './uploads/uploads.module';
import { UsersModule } from './users/users.module';
import { VideosModule } from './videos/videos.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    GlobalJwtModule,
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'mysql',
        host: config.get<string>('DB_HOST', '127.0.0.1'),
        port: config.get<number>('DB_PORT', 3306),
        username: config.get<string>('DB_USER', 'root'),
        password: config.get<string>('DB_PASSWORD', 'root'),
        database: config.get<string>('DB_NAME', 'diy'),
        autoLoadEntities: true,
        // 迁移文件：生产通过 migration:run（或 DB_MIGRATIONS_RUN=true 启动时执行）管理 schema
        migrations: [join(__dirname, 'migrations', '*{.ts,.js}')],
        migrationsRun:
          config.get<string>('DB_MIGRATIONS_RUN') === 'true',
        // 开发环境自动建表；生产默认关闭（首次部署可设 DB_SYNC=true 建表一次，建完改回 false 重启）
        synchronize:
          config.get<string>('NODE_ENV') !== 'production' ||
          config.get<string>('DB_SYNC') === 'true',
      }),
    }),
    RedisModule,
    UsersModule,
    AuthModule,
    StoresModule,
    AppointmentsModule,
    ActivitiesModule,
    CommunityModule,
    ChatModule,
    FollowsModule,
    UploadsModule,
    NotificationsModule,
    DashboardModule,
    VideosModule,
    MusicModule,
    MembersModule,
    ModerationModule,
  ],
  controllers: [AppController, HealthController],
  providers: [AppService, BootstrapService],
})
export class AppModule {}
