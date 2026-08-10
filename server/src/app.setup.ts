import { INestApplication, ValidationPipe } from '@nestjs/common';
import { WsAdapter } from '@nestjs/platform-ws';
import helmet from 'helmet';
import express from 'express';
import { join } from 'path';

/** 解析 CORS_ORIGINS（逗号分隔的白名单）；未配置返回 null */
function corsOrigins(): string[] | null {
  const list = (process.env.CORS_ORIGINS ?? '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
  return list.length ? list : null;
}

/**
 * 应用级中间件/全局配置集中在此，bootstrap 与 e2e 测试共用：
 * WebSocket 适配器、静态资源、helmet 安全头、CORS 白名单、全局前缀与校验管道。
 */
export function configureApp(app: INestApplication): void {
  // 聊天 WebSocket（原生 ws，与 HTTP 共用端口，路径 /ws）
  app.useWebSocketAdapter(new WsAdapter(app));

  // 聊天图片等上传文件静态托管（UPLOAD_DIR 默认 uploads，相对进程工作目录）
  app.use(
    '/uploads',
    express.static(join(process.cwd(), process.env.UPLOAD_DIR ?? 'uploads')),
  );
  // 开发环境演示短视频与曲库音频（bootstrap 种子引用的真实资产）
  app.use(
    '/assets/demo',
    express.static(join(process.cwd(), 'assets', 'demo')),
  );
  app.use(
    '/assets/music',
    express.static(join(process.cwd(), 'assets', 'music')),
  );

  // 安全响应头：X-Content-Type-Options、X-Frame-Options、CSP 等
  app.use(helmet());

  // 管理后台（admin）与客户端共用同一套 /api 前缀 API
  app.setGlobalPrefix('api');
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));

  const origins = corsOrigins();
  app.enableCors({
    // 配置 CORS_ORIGINS 时严格按白名单；生产未配置默认禁止跨域（原生 App 不受 CORS 限制）；
    // 开发未配置放行所有来源，便于本地联调
    origin: origins ?? (process.env.NODE_ENV === 'production' ? false : true),
    credentials: true,
  });
}
