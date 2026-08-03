import { NotImplementedException } from '@nestjs/common';
import type { ConfigService } from '@nestjs/config';
import { copyFileSync, mkdirSync, renameSync, unlinkSync } from 'fs';
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

  async save(file: Express.Multer.File, dir: string): Promise<UploadedFile> {
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
    return { url: `/uploads/${dir}/${file.filename}` };
  }
}

/**
 * 对象存储提供者（预留）：接入 OSS/COS 时在此实现上传逻辑，
 * 并在 .env 设置 UPLOAD_PROVIDER=oss 启用。
 */
export class ObjectStorageProvider implements UploadProvider {
  readonly name = 'oss';

  async save(): Promise<UploadedFile> {
    throw new NotImplementedException(
      '对象存储尚未接入：请配置 UPLOAD_PROVIDER=local，或实现 ObjectStorageProvider',
    );
  }
}

/** 依据环境变量创建存储提供者（默认本地磁盘） */
export function createUploadProvider(config: ConfigService): UploadProvider {
  const kind = config.get<string>('UPLOAD_PROVIDER', 'local').toLowerCase();
  switch (kind) {
    case 'local':
      return new LocalUploadProvider();
    case 'oss':
      return new ObjectStorageProvider();
    default:
      throw new Error(`未知 UPLOAD_PROVIDER: ${kind}`);
  }
}
