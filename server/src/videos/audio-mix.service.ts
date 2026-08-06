import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { execFile } from 'child_process';
import { randomUUID } from 'crypto';
import { existsSync, mkdirSync, unlinkSync } from 'fs';
import { tmpdir } from 'os';
import { join } from 'path';
import { promisify } from 'util';
import { Repository } from 'typeorm';
import { Music } from '../music/music.entity';
import { uploadRoot } from '../uploads/uploads.provider';

const execFileAsync = promisify(execFile);

/** ffprobe 探测结果 */
interface ProbeResult {
  durationSec: number;
  hasAudio: boolean;
}

/**
 * 配乐混音：把曲库音乐与已上传视频合成新视频。
 *
 * 混音规则（短视频场景）：
 * - 保留原视频音轨（人声/环境音），配乐以 0.5 音量垫底；
 * - 配乐循环铺满整段视频（超出部分裁剪，不足部分循环）；
 * - 视频流直接 copy 不重编码，仅重编码音频，速度更快且不损失画质。
 */
@Injectable()
export class AudioMixService {
  private readonly logger = new Logger(AudioMixService.name);
  /** 配乐音量（0~1，作为原声背景音乐） */
  private readonly MUSIC_VOLUME = 0.5;

  constructor(
    @InjectRepository(Music)
    private readonly music: Repository<Music>,
  ) {}

  /**
   * 把 [musicId] 对应的曲目混入 [videoUrl]（/uploads/... 相对路径）指向的视频，
   * 返回混音后新视频的相对 URL；原视频文件在成功后删除。
   */
  async mix(musicId: number, videoUrl: string): Promise<string> {
    const musicRow = await this.music.findOneBy({ id: musicId });
    if (!musicRow || !musicRow.musicUrl) {
      throw new NotFoundException('配乐不存在或缺少音频文件');
    }

    const videoPath = this.resolveLocalPath(videoUrl, 'videoUrl');
    if (!videoPath || !existsSync(videoPath)) {
      throw new BadRequestException('视频文件不存在，无法合成配乐');
    }

    const musicPath = this.resolveMusicInput(musicRow.musicUrl);
    if (!musicPath) {
      throw new BadRequestException('配乐音频文件不存在，无法合成');
    }

    let tempMusic: string | undefined;
    let inputMusic = musicPath;
    if (/^https?:\/\//i.test(musicPath)) {
      // 远程曲库音频：先下载到临时文件再混音，避免流式循环失败
      tempMusic = join(tmpdir(), `diy-music-${randomUUID()}.mp3`);
      try {
        const resp = await fetch(musicPath);
        if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
        const { writeFile } = await import('fs/promises');
        await writeFile(tempMusic, Buffer.from(await resp.arrayBuffer()));
        inputMusic = tempMusic;
      } catch (err) {
        this.logger.warn(`配乐下载失败：${musicPath}（${String(err)}）`);
        throw new BadRequestException('配乐下载失败，请更换配乐后重试');
      }
    }

    try {
      const probe = await this.probe(videoPath);
      const output = this.buildOutputPath();
      await this.runFfmpeg(videoPath, inputMusic, output, probe);
      // 混音成功：原上传视频已无保留价值，删除避免占用存储
      try {
        unlinkSync(videoPath);
      } catch {
        /* 删除失败不影响发布 */
      }
      return this.toRelativeUrl(output);
    } finally {
      if (tempMusic) {
        try {
          unlinkSync(tempMusic);
        } catch {
          /* 临时文件清理失败忽略 */
        }
      }
    }
  }

  /** ffprobe 探测视频时长与是否含音轨 */
  private async probe(videoPath: string): Promise<ProbeResult> {
    const { stdout } = await execFileAsync('ffprobe', [
      '-v',
      'quiet',
      '-print_format',
      'json',
      '-show_streams',
      '-show_format',
      videoPath,
    ]);
    const data = JSON.parse(stdout) as {
      streams?: Array<{ codec_type?: string }>;
      format?: { duration?: string };
    };
    const durationSec = parseFloat(data.format?.duration ?? '0') || 0;
    const hasAudio = (data.streams ?? []).some((s) => s.codec_type === 'audio');
    if (!durationSec) {
      throw new BadRequestException('无法读取视频时长，请重新上传');
    }
    return { durationSec, hasAudio };
  }

  /** 混音输出路径：uploads/video/{yyyy}/{mm}/{uuid}-music.mp4 */
  private buildOutputPath(): string {
    const d = new Date();
    const mm = `${d.getMonth() + 1}`.padStart(2, '0');
    const dir = join(uploadRoot(), 'video', `${d.getFullYear()}`, mm);
    mkdirSync(dir, { recursive: true });
    return join(dir, `${randomUUID()}-music.mp4`);
  }

  private async runFfmpeg(
    videoPath: string,
    musicPath: string,
    outputPath: string,
    probe: ProbeResult,
  ) {
    const args = ['-y', '-i', videoPath, '-stream_loop', '-1', '-i', musicPath];
    if (probe.hasAudio) {
      // 原声 + 配乐混音；配乐循环播放至视频结束
      args.push(
        '-filter_complex',
        `[0:a]volume=1.0[a0];[1:a]volume=${this.MUSIC_VOLUME}[a1];` +
          '[a0][a1]amix=inputs=2:duration=first:dropout_transition=0:normalize=0,' +
          'alimiter=limit=0.95:level=false[aout]',
        '-map',
        '0:v',
        '-map',
        '[aout]',
      );
    } else {
      // 视频无音轨：直接以配乐作为唯一音轨
      args.push('-map', '0:v', '-map', '1:a');
    }
    args.push(
      '-c:v',
      'copy',
      '-c:a',
      'aac',
      '-b:a',
      '192k',
      '-ac',
      '2',
      '-t',
      String(probe.durationSec),
      '-movflags',
      '+faststart',
      outputPath,
    );
    try {
      await execFileAsync('ffmpeg', args, { timeout: 5 * 60 * 1000 });
    } catch (err) {
      const stderr =
        err && typeof err === 'object' && 'stderr' in err
          ? String((err as { stderr: unknown }).stderr).slice(0, 500)
          : String(err);
      this.logger.error(`配乐混音失败：${stderr}`);
      throw new BadRequestException('配乐合成失败，请重试或更换配乐');
    }
  }

  /** 服务端本地文件 → 绝对路径（/uploads/... 与 /assets/music/...） */
  private resolveLocalPath(url: string, kind: 'videoUrl' | 'musicUrl') {
    if (/^https?:\/\//i.test(url)) return url;
    if (url.startsWith('/uploads/')) {
      const rel = url.replace(/^\/uploads\//, '');
      return join(process.cwd(), uploadRoot(), ...rel.split('/'));
    }
    if (url.startsWith('/assets/music/')) {
      const rel = url.replace(/^\/assets\/music\//, '');
      return join(process.cwd(), 'assets', 'music', ...rel.split('/'));
    }
    this.logger.warn(
      `无法解析${kind === 'videoUrl' ? '视频' : '配乐'}路径：${url}`,
    );
    return null;
  }

  /** 曲库音频 → 本地绝对路径或远程 URL（远程由 mix() 下载） */
  private resolveMusicInput(musicUrl: string): string | null {
    if (/^https?:\/\//i.test(musicUrl)) return musicUrl;
    const resolved = this.resolveLocalPath(musicUrl, 'musicUrl');
    if (!resolved) return null;
    // 曲库音频可能不在 assets 下（如上传到 /uploads 的音频），存在即用
    if (musicUrl.startsWith('/assets/music/')) return resolved;
    return existsSync(resolved) ? resolved : null;
  }

  /** 绝对输出路径 → /uploads/... 相对 URL */
  private toRelativeUrl(absPath: string): string {
    const rel = absPath
      .replace(process.cwd(), '')
      .split(/\//)
      .map((s) => s.trim())
      .filter(Boolean)
      .join('/');
    return `/${rel}`;
  }
}
