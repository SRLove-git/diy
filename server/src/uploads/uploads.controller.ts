import {
  BadRequestException,
  Controller,
  Inject,
  Post,
  Query,
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
import { UPLOAD_PROVIDER, type UploadProvider } from './uploads.provider';

/** 允许上传的图片类型 */
const ALLOWED_MIMES = new Set([
  'image/jpeg',
  'image/png',
  'image/gif',
  'image/webp',
]);

/** 允许上传的音频类型（聊天语音消息） */
const ALLOWED_AUDIO_MIMES = new Set([
  'audio/mpeg',
  'audio/mp4',
  'audio/m4a',
  'audio/x-m4a',
  'audio/aac',
  'audio/wav',
  'audio/x-wav',
  'audio/ogg',
  'audio/webm',
  'audio/3gpp',
  'audio/x-ms-wma',
]);

/** 允许上传的视频类型（短视频文件） */
const ALLOWED_VIDEO_MIMES = new Set([
  'video/mp4',
  'video/quicktime',
  'video/x-msvideo',
  'video/x-ms-wmv',
  'video/webm',
  'video/ogg',
  'video/3gpp',
  'video/mpeg',
  'video/x-matroska',
]);

/** 当前月份子目录：yyyy/mm */
function monthDir(): string {
  const d = new Date();
  const mm = `${d.getMonth() + 1}`.padStart(2, '0');
  return `${d.getFullYear()}/${mm}`;
}

/** multer 磁盘存储：先写系统临时目录，由 UploadProvider 移动到最终位置 */
function multerStorage() {
  return diskStorage({
    destination: (_req, _file, cb) => {
      const dir = join(tmpdir(), 'diy-uploads');
      mkdirSync(dir, { recursive: true });
      cb(null, dir);
    },
    filename: (_req, file, cb) => {
      const ext = extname(file.originalname).toLowerCase() || '.bin';
      cb(null, `${randomUUID()}${ext}`);
    },
  });
}

/** 允许的图片业务目录（query 参数 folder，防止路径穿越） */
const ALLOWED_FOLDERS = new Set(['chat', 'avatar', 'post']);

/**
 * 聊天图片上传。
 *
 * POST /api/uploads/images（multipart 字段 file，需登录）。
 * multer 先写入系统临时目录，随后交给 UploadProvider 持久化：
 * - local（默认）：移动到 {UPLOAD_DIR}/{folder}/{yyyy}/{mm}/，返回相对路径
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
      storage: multerStorage(),
      limits: { fileSize: 10 * 1024 * 1024 },
    }),
  )
  async upload(
    @UploadedFile() file?: Express.Multer.File,
    @Query('folder') folder?: string,
  ) {
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
    const dir = folder && ALLOWED_FOLDERS.has(folder) ? folder : 'chat';
    const { url } = await this.uploader.save(file, `${dir}/${monthDir()}`);
    return { url };
  }

  /** 聊天语音上传：POST /api/uploads/audio（multipart 字段 file，需登录），返回相对路径 */
  @Post('audio')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: multerStorage(),
      limits: { fileSize: 10 * 1024 * 1024 },
    }),
  )
  async uploadAudio(@UploadedFile() file?: Express.Multer.File) {
    if (!file) throw new BadRequestException('缺少文件');
    if (!ALLOWED_AUDIO_MIMES.has(file.mimetype)) {
      // 类型不合规：删掉临时文件再报错
      try {
        unlinkSync(file.path);
      } catch {
        /* 忽略删除失败 */
      }
      throw new BadRequestException('仅支持常见音频格式');
    }
    const { url } = await this.uploader.save(file, `chat/${monthDir()}`);
    return { url };
  }

  /** 短视频上传：POST /api/uploads/videos（multipart 字段 file，需登录），返回相对路径 */
  @Post('videos')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: multerStorage(),
      limits: { fileSize: 200 * 1024 * 1024 },
    }),
  )
  async uploadVideo(@UploadedFile() file?: Express.Multer.File) {
    if (!file) throw new BadRequestException('缺少文件');
    if (!ALLOWED_VIDEO_MIMES.has(file.mimetype)) {
      // 类型不合规：删掉临时文件再报错
      try {
        unlinkSync(file.path);
      } catch {
        /* 忽略删除失败 */
      }
      throw new BadRequestException(
        '仅支持 mp4/mov/avi/webm/3gp 等常见视频格式',
      );
    }
    const { url } = await this.uploader.save(file, `video/${monthDir()}`);
    return { url };
  }
}
