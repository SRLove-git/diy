import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AppointmentsModule } from './appointments/appointments.module';
import { AuthModule } from './auth/auth.module';
import { CommunityModule } from './community/community.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { NotificationsModule } from './notifications/notifications.module';
import { BootstrapService } from './bootstrap/bootstrap.service';
import { GlobalJwtModule } from './common/global-jwt.module';
import { HealthController } from './health/health.controller';
import { RedisModule } from './redis/redis.module';
import { StoresModule } from './stores/stores.module';
import { UsersModule } from './users/users.module';

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
        // 开发环境自动建表；生产由迁移脚本管理
        synchronize: config.get<string>('NODE_ENV') !== 'production',
      }),
    }),
    RedisModule,
    UsersModule,
    AuthModule,
    StoresModule,
    AppointmentsModule,
    CommunityModule,
    NotificationsModule,
    DashboardModule,
  ],
  controllers: [AppController, HealthController],
  providers: [AppService, BootstrapService],
})
export class AppModule {}
