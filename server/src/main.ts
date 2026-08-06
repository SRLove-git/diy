import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { WsAdapter } from '@nestjs/platform-ws';
import express from 'express';
import { join } from 'path';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // 聊天 WebSocket（原生 ws，与 HTTP 共用 3000 端口，路径 /ws）
  app.useWebSocketAdapter(new WsAdapter(app));

  // 聊天图片等上传文件静态托管（UPLOAD_DIR 默认 uploads，相对进程工作目录）
  const uploadDir = join(process.cwd(), process.env.UPLOAD_DIR ?? 'uploads');
  app.use('/uploads', express.static(uploadDir));

  // 开发环境演示短视频（bootstrap 种子引用的真实视频资产）
  app.use('/assets/demo', express.static(join(process.cwd(), 'assets', 'demo')));

  // 管理后台（admin）与客户端共用同一套 /api 前缀 API
  app.setGlobalPrefix('api');
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
  app.enableCors({
    origin: true,
    credentials: true,
  });

  await app.listen(process.env.PORT ?? 3000, '0.0.0.0');
}
bootstrap();
