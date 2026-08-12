import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export type CaptchaProvider = '' | 'turnstile' | 'hcaptcha';

const VERIFY_TIMEOUT_MS = 5000;

/**
 * 人机验证服务（可插拔）：
 * - CAPTCHA_PROVIDER=turnstile → Cloudflare Turnstile siteverify
 * - CAPTCHA_PROVIDER=hcaptcha → hCaptcha siteverify
 * - 未配置（默认）→ 直接放行，不影响现有客户端
 *
 * 开启后注册/登录必须携带有效的 captchaToken，否则拒绝。
 */
@Injectable()
export class CaptchaService {
  constructor(private readonly config: ConfigService) {}

  get provider(): CaptchaProvider {
    const raw = (this.config.get<string>('CAPTCHA_PROVIDER', '') ?? '').trim();
    return (raw.toLowerCase() as CaptchaProvider) || '';
  }

  /** 校验人机 token；未配置 provider 时视为开启成功（功能开关） */
  async verify(token?: string, ip?: string): Promise<boolean> {
    const provider = this.provider;
    if (!provider) return true;
    if (!token) return false;
    try {
      return provider === 'turnstile'
        ? await this.verifyTurnstile(token, ip)
        : await this.verifyHcaptcha(token, ip);
    } catch {
      // 验证服务不可用时安全优先：不放行
      return false;
    }
  }

  private async verifyTurnstile(token: string, ip?: string): Promise<boolean> {
    const body = new URLSearchParams({
      secret: this.config.get<string>('TURNSTILE_SECRET', ''),
      response: token,
    });
    if (ip) body.set('remoteip', ip);
    const res = await fetch(
      'https://challenges.cloudflare.com/turnstile/v0/siteverify',
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body,
        signal: AbortSignal.timeout(VERIFY_TIMEOUT_MS),
      },
    );
    if (!res.ok) return false;
    const data = (await res.json()) as { success?: boolean };
    return data.success === true;
  }

  private async verifyHcaptcha(token: string, ip?: string): Promise<boolean> {
    const body = new URLSearchParams({
      secret: this.config.get<string>('HCAPTCHA_SECRET', ''),
      response: token,
    });
    if (ip) body.set('remoteip', ip);
    const res = await fetch('https://hcaptcha.com/siteverify', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body,
      signal: AbortSignal.timeout(VERIFY_TIMEOUT_MS),
    });
    if (!res.ok) return false;
    const data = (await res.json()) as { success?: boolean };
    return data.success === true;
  }
}
