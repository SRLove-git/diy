const TOKEN_KEY = 'pd_access_token';
const REFRESH_KEY = 'pd_refresh_token';

export class ApiError extends Error {
  status: number;

  constructor(message: string, status: number) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
  }
}

export function getAccessToken(): string | null {
  return localStorage.getItem(TOKEN_KEY);
}

export function getRefreshToken(): string | null {
  return localStorage.getItem(REFRESH_KEY);
}

export function setTokens(accessToken: string, refreshToken?: string): void {
  localStorage.setItem(TOKEN_KEY, accessToken);
  if (refreshToken) localStorage.setItem(REFRESH_KEY, refreshToken);
}

export function clearTokens(): void {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(REFRESH_KEY);
}

/** 后端统一异常出口返回 { statusCode, message(string|string[]), error }，这里归一化为单条文案 */
function normalizeMessage(data: unknown, status: number): string {
  if (data && typeof data === 'object') {
    const obj = data as Record<string, unknown>;
    const raw = obj.message ?? obj.error;
    if (Array.isArray(raw)) return raw.filter((x) => typeof x === 'string').join('；');
    if (typeof raw === 'string' && raw) return raw;
  }
  if (typeof data === 'string' && data) return data;
  return `请求失败（HTTP ${status}）`;
}

async function rawRequest(path: string, init: RequestInit): Promise<Response> {
  const headers = new Headers(init.headers);
  if (!headers.has('Content-Type') && init.body != null) {
    headers.set('Content-Type', 'application/json');
  }
  const token = getAccessToken();
  if (token) headers.set('Authorization', `Bearer ${token}`);
  return fetch(`/api${path}`, { ...init, headers });
}

async function parseResponse<T>(res: Response): Promise<T> {
  const text = await res.text();
  let data: unknown = null;
  if (text) {
    try {
      data = JSON.parse(text);
    } catch {
      data = text;
    }
  }
  if (!res.ok) throw new ApiError(normalizeMessage(data, res.status), res.status);
  return data as T;
}

let refreshInflight: Promise<boolean> | null = null;

async function tryRefresh(): Promise<boolean> {
  const refreshToken = getRefreshToken();
  if (!refreshToken) return false;
  if (!refreshInflight) {
    refreshInflight = (async () => {
      try {
        const res = await fetch('/api/auth/refresh', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ refreshToken }),
        });
        if (!res.ok) return false;
        const data = (await res.json()) as {
          accessToken: string;
          refreshToken: string;
        };
        setTokens(data.accessToken, data.refreshToken);
        return true;
      } catch {
        return false;
      } finally {
        refreshInflight = null;
      }
    })();
  }
  return refreshInflight;
}

async function request<T>(path: string, init: RequestInit = {}): Promise<T> {
  let res = await rawRequest(path, init);
  if (res.status === 401 && getRefreshToken() && !path.startsWith('/auth/')) {
    const ok = await tryRefresh();
    if (ok) {
      res = await rawRequest(path, init);
      if (res.status === 401) {
        clearTokens();
        window.dispatchEvent(new Event('pd:unauthorized'));
      }
    } else {
      clearTokens();
      window.dispatchEvent(new Event('pd:unauthorized'));
    }
  }
  return parseResponse<T>(res);
}

export const http = {
  get: <T>(path: string) => request<T>(path),
  post: <T>(path: string, body?: unknown) =>
    request<T>(path, { method: 'POST', body: body == null ? undefined : JSON.stringify(body) }),
  patch: <T>(path: string, body?: unknown) =>
    request<T>(path, { method: 'PATCH', body: body == null ? undefined : JSON.stringify(body) }),
  delete: <T>(path: string) => request<T>(path, { method: 'DELETE' }),
};
