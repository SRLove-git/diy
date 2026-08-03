import {
  BadRequestException,
  Controller,
  Post,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { randomUUID } from 'crypto';
import { mkdirSync, unlinkSync } from 'fs';
import { diskStorage } from 'multer';
import { extname, join } from 'path';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

/** 允许上传的图片类型 */
const ALLOWED_MIMES = new Set([
  'image/jpeg',
  'image/png',
  'image/gif',
  'image/webp',
]);

/** 上传根目录（UPLOAD_DIR 环境变量，默认 uploads，相对进程工作目录） */
function uploadRoot(): string {
  return process.env.UPLOAD_DIR ?? 'uploads';
}

/** 当前月份子目录：yyyy/mm */
function monthDir(): string {
  const d = new Date();
  const mm = `${d.getMonth() + 1}`.padStart(2, '0');
  return `${d.getFullYear()}/${mm}`;
}

/**
 * 聊天图片上传。
 *
 * POST /api/uploads/images（multipart 字段 file，需登录），
 * 文件落盘到 {UPLOAD_DIR}/chat/{yyyy}/{mm}/，返回可访问的相对路径
 * （静态资源由 main.ts 以 /uploads 前缀托管，与消息内容存储解耦）。
 *
 * 注意：磁盘路径基于进程内环境变量在请求时求值（.env 在 bootstrap 阶段加载），
 * 不依赖实例状态，避免装饰器求值期 this 不可用的问题。
 */
@Controller('uploads')
@UseGuards(JwtAuthGuard)
export class UploadsController {
  @Post('images')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: (_req, _file, cb) => {
          const dir = join(uploadRoot(), 'chat', monthDir());
          mkdirSync(dir, { recursive: true });
          cb(null, dir);
        },
        filename: (_req, file, cb) => {
          const ext = extname(file.originalname).toLowerCase() || '.jpg';
          cb(null, `${randomUUID()}${ext}`);
        },
      }),
      limits: { fileSize: 10 * 1024 * 1024 },
    }),
  )
  upload(@UploadedFile() file?: Express.Multer.File) {
    if (!file) throw new BadRequestException('缺少文件');
    if (!ALLOWED_MIMES.has(file.mimetype)) {
      // 类型不合规：删掉已落盘文件再报错
      try {
        unlinkSync(file.path);
      } catch {
        /* 忽略删除失败 */
      }
      throw new BadRequestException('仅支持 jpg/png/gif/webp 图片');
    }
    return { url: `/uploads/chat/${monthDir()}/${file.filename}` };
  }
}
