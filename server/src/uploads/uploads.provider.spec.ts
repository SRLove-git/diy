import { ConfigService } from '@nestjs/config';
import { mkdtempSync, rmSync, writeFileSync } from 'fs';
import { tmpdir } from 'os';
import { join } from 'path';
import { S3UploadProvider } from './uploads.provider';

const send = jest.fn();

jest.mock('@aws-sdk/client-s3', () => ({
  S3Client: jest.fn().mockImplementation(() => ({ send })),
  PutObjectCommand: jest.fn().mockImplementation((input) => ({ input })),
}));

describe('S3UploadProvider', () => {
  let dir: string;

  beforeEach(() => {
    send.mockReset();
    dir = mkdtempSync(join(tmpdir(), 'diy-upload-test-'));
  });

  afterEach(() => {
    rmSync(dir, { recursive: true, force: true });
  });

  it('缺少 S3_BUCKET 时抛错', () => {
    const config = new ConfigService({ UPLOAD_PROVIDER: 's3' });
    expect(() => new S3UploadProvider(config)).toThrow('S3_BUCKET');
  });

  it('上传到 bucket 并返回 publicBase 下的 URL，临时文件被清理', async () => {
    send.mockResolvedValue({});
    const config = new ConfigService({
      S3_BUCKET: 'diy-media',
      S3_REGION: 'ap-shanghai',
      S3_PUBLIC_URL_BASE: 'https://cdn.example.com',
      S3_ACCESS_KEY: 'ak',
      S3_SECRET_KEY: 'sk',
    });
    const provider = new S3UploadProvider(config);
    const filePath = join(dir, 'abc.jpg');
    writeFileSync(filePath, Buffer.from([0xff, 0xd8]));

    const result = await provider.save(
      {
        path: filePath,
        filename: 'abc.jpg',
        mimetype: 'image/jpeg',
      } as Express.Multer.File,
      'post/2026/08',
    );

    expect(send).toHaveBeenCalledWith({
      input: {
        Bucket: 'diy-media',
        Key: 'post/2026/08/abc.jpg',
        Body: Buffer.from([0xff, 0xd8]),
        ContentType: 'image/jpeg',
      },
    });
    expect(result.url).toBe('https://cdn.example.com/post/2026/08/abc.jpg');
    // 临时文件已清理
    expect(require('fs').existsSync(filePath)).toBe(false);
  });

  it('未配置 publicBase 时回退到 bucket 默认域名', async () => {
    send.mockResolvedValue({});
    const config = new ConfigService({
      S3_BUCKET: 'diy-media',
      S3_REGION: 'ap-shanghai',
    });
    const provider = new S3UploadProvider(config);
    const filePath = join(dir, 'a.png');
    writeFileSync(filePath, 'x');

    const result = await provider.save(
      {
        path: filePath,
        filename: 'a.png',
        mimetype: 'image/png',
      } as Express.Multer.File,
      'avatar/2026/08',
    );

    expect(result.url).toBe(
      'https://diy-media.s3.ap-shanghai.amazonaws.com/avatar/2026/08/a.png',
    );
  });
});
