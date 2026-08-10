import type { ConfigService } from '@nestjs/config';
import { PutObjectCommand, S3Client } from '@aws-sdk/client-s3';
import {
  copyFileSync,
  mkdirSync,
  readFileSync,
  renameSync,
  unlinkSync,
} from 'fs';
import { join } from 'path';

/** 上传结果 */
export interface UploadedFile {
  /** 可访问的相对或绝对 URL */
  url: string;
}

/** 存储提供者抽象：新增存储后端只需实现并注册此接口 */
export interface UploadProvider {
  readonly name: string;
  save(file: Express.Multer.File, dir: string): Promise<UploadedFile>;
}

/** 上传提供者 DI token */
export const UPLOAD_PROVIDER = 'UPLOAD_PROVIDER';

/** 上传根目录（UPLOAD_DIR 环境变量，默认 uploads，相对进程工作目录） */
export function uploadRoot(): string {
  return process.env.UPLOAD_DIR ?? 'uploads';
}

/**
 * 本地磁盘存储：multer 已把文件写入临时目录，此处移动到 {UPLOAD_DIR}/{dir}/ 并返回
 * 相对 URL（静态资源由 main.ts 以 /uploads 前缀托管）。
 */
export class LocalUploadProvider implements UploadProvider {
  readonly name = 'local';

  save(file: Express.Multer.File, dir: string): Promise<UploadedFile> {
    const targetDir = join(uploadRoot(), dir);
    mkdirSync(targetDir, { recursive: true });
    const dest = join(targetDir, file.filename);
    try {
      renameSync(file.path, dest);
    } catch {
      // 跨设备/文件系统时回退为复制后删除临时文件
      copyFileSync(file.path, dest);
      unlinkSync(file.path);
    }
    return Promise.resolve({ url: `/uploads/${dir}/${file.filename}` });
  }
}

/**
 * S3 兼容对象存储（AWS S3 / MinIO / 阿里云 OSS / 腾讯云 COS 等）。
 *
 * 配置（.env）：
 *   UPLOAD_PROVIDER=s3
 *   S3_ENDPOINT          可选：自定义终端（MinIO/OSS/COS 需要）
 *   S3_REGION            默认 us-east-1
 *   S3_BUCKET            必填
 *   S3_ACCESS_KEY / S3_SECRET_KEY
 *   S3_PUBLIC_URL_BASE   可选：对外访问域名/CDN（如 https://cdn.example.com），
 *                        未配置时回退到 bucket 默认域名
 *   S3_FORCE_PATH_STYLE  可选：MinIO 等需要 true
 */
export class S3UploadProvider implements UploadProvider {
  readonly name = 's3';
  private readonly client: S3Client;
  private readonly bucket: string;
  private readonly publicBase: string;
  private readonly fallbackHost: string;

  constructor(config: ConfigService) {
    this.bucket = config.get<string>('S3_BUCKET', '');
    if (!this.bucket) {
      throw new Error('UPLOAD_PROVIDER=s3 时需配置 S3_BUCKET');
    }
    const region = config.get<string>('S3_REGION', 'us-east-1');
    this.publicBase = (
      config.get<string>('S3_PUBLIC_URL_BASE', '') ?? ''
    ).replace(/\/+$/, '');
    this.fallbackHost = `https://${this.bucket}.s3.${region}.amazonaws.com`;
    this.client = new S3Client({
      region,
      endpoint: config.get<string>('S3_ENDPOINT') || undefined,
      forcePathStyle: config.get<string>('S3_FORCE_PATH_STYLE') === 'true',
      credentials: {
        accessKeyId: config.get<string>('S3_ACCESS_KEY', ''),
        secretAccessKey: config.get<string>('S3_SECRET_KEY', ''),
      },
    });
  }

  async save(file: Express.Multer.File, dir: string): Promise<UploadedFile> {
    const key = `${dir}/${file.filename}`;
    const body = readFileSync(file.path);
    try {
      await this.client.send(
        new PutObjectCommand({
          Bucket: this.bucket,
          Key: key,
          Body: body,
          ContentType: file.mimetype || 'application/octet-stream',
        }),
      );
    } finally {
      // 上传完成（无论成败）清理 multer 临时文件
      try {
        unlinkSync(file.path);
      } catch {
        /* 忽略清理失败 */
      }
    }
    const base = this.publicBase || this.fallbackHost;
    return { url: `${base}/${key}` };
  }
}

/** 依据环境变量创建存储提供者（默认本地磁盘；s3 走对象存储） */
export function createUploadProvider(config: ConfigService): UploadProvider {
  const kind = config.get<string>('UPLOAD_PROVIDER', 'local').toLowerCase();
  switch (kind) {
    case 'local':
      return new LocalUploadProvider();
    case 's3':
      return new S3UploadProvider(config);
    default:
      throw new Error(`未知 UPLOAD_PROVIDER: ${kind}`);
  }
}
