import {
  BadRequestException,
  Controller,
  Inject,
  Post,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { randomUUID } from 'crypto';
import { mkdirSync, unlinkSync } from 'fs';
import { diskStorage } from 'multer';
import { tmpdir } from 'os';
import { extname, join } from 'path';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import {
  UPLOAD_PROVIDER,
  type UploadProvider,
} from './uploads.provider';

/** 允许上传的图片类型 */
const ALLOWED_MIMES = new Set([
  'image/jpeg',
  'image/png',
  'image/gif',
  'image/webp',
]);

/** 当前月份子目录：yyyy/mm */
function monthDir(): string {
  const d = new Date();
  const mm = `${d.getMonth() + 1}`.padStart(2, '0');
  return `${d.getFullYear()}/${mm}`;
}

/**
 * 聊天图片上传。
 *
 * POST /api/uploads/images（multipart 字段 file，需登录）。
 * multer 先写入系统临时目录，随后交给 UploadProvider 持久化：
 * - local（默认）：移动到 {UPLOAD_DIR}/chat/{yyyy}/{mm}/，返回相对路径
 * - oss（预留）：配置 UPLOAD_PROVIDER=oss 并实现对象存储后启用
 *
 * 返回的 url 作为图片消息 content 存储；本地模式由 main.ts 以 /uploads 前缀托管静态资源。
 */
@Controller('uploads')
@UseGuards(JwtAuthGuard)
export class UploadsController {
  constructor(
    @Inject(UPLOAD_PROVIDER)
    private readonly uploader: UploadProvider,
  ) {}

  @Post('images')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        // 先写入临时目录，由存储提供者移动到最终位置
        destination: (_req, _file, cb) => {
          const dir = join(tmpdir(), 'diy-uploads');
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
  async upload(@UploadedFile() file?: Express.Multer.File) {
    if (!file) throw new BadRequestException('缺少文件');
    if (!ALLOWED_MIMES.has(file.mimetype)) {
      // 类型不合规：删掉临时文件再报错
      try {
        unlinkSync(file.path);
      } catch {
        /* 忽略删除失败 */
      }
      throw new BadRequestException('仅支持 jpg/png/gif/webp 图片');
    }
    const { url } = await this.uploader.save(file, `chat/${monthDir()}`);
    return { url };
  }
}
