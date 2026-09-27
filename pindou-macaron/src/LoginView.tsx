import { useCallback, useEffect, useState, type FormEvent } from 'react';
import { authApi } from './api';
import { ApiError } from './api/http';
import { useAuth } from './auth';
import { brand } from './data';

type Tab = 'login' | 'register';

export function LoginView() {
  const { login, register } = useAuth();
  const [tab, setTab] = useState<Tab>('login');
  const [account, setAccount] = useState('');
  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [captchaText, setCaptchaText] = useState('');
  const [captcha, setCaptcha] = useState<{ id: string; image: string } | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadCaptcha = useCallback(async () => {
    setCaptcha(null);
    setCaptchaText('');
    try {
      const c = await authApi.captcha();
      setCaptcha({ id: c.id, image: c.image });
    } catch {
      setError('验证码加载失败，请重试');
    }
  }, []);

  useEffect(() => {
    void loadCaptcha();
  }, [loadCaptcha]);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    if (!captcha) {
      setError('请先加载验证码');
      return;
    }
    setBusy(true);
    setError(null);
    try {
      if (tab === 'login') {
        await login(account.trim(), password, captcha.id, captchaText.trim());
      } else {
        await register(
          username.trim(),
          email.trim(),
          password,
          captcha.id,
          captchaText.trim(),
        );
      }
    } catch (err) {
      setError(err instanceof ApiError ? err.message : '操作失败，请稍后重试');
      void loadCaptcha();
    } finally {
      setBusy(false);
    }
  };

  const switchTab = (next: Tab) => {
    setTab(next);
    setError(null);
    void loadCaptcha();
  };

  return (
    <div className="login-runtime">
      <div className="login-card">
        <div className="login-head">
          <span className="mark">拼</span>
          <div>
            <h1>{brand.name}</h1>
            <p>{brand.city} · {brand.store}</p>
          </div>
        </div>

        <div className="h5-tabs">
          <button
            className={tab === 'login' ? 'is-active' : ''}
            onClick={() => switchTab('login')}
          >
            登录
          </button>
          <button
            className={tab === 'register' ? 'is-active' : ''}
            onClick={() => switchTab('register')}
          >
            注册
          </button>
        </div>

        <form className="login-form" onSubmit={submit}>
          {tab === 'login' ? (
            <label>
              <span>用户名 / 邮箱</span>
              <input
                value={account}
                onChange={(e) => setAccount(e.target.value)}
                placeholder="请输入用户名或邮箱"
                autoComplete="username"
                required
              />
            </label>
          ) : (
            <>
              <label>
                <span>用户名</span>
                <input
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  placeholder="2-30 位字母 / 数字 / 下划线"
                  autoComplete="username"
                  required
                />
              </label>
              <label>
                <span>邮箱</span>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="用于账号绑定"
                  autoComplete="email"
                  required
                />
              </label>
            </>
          )}

          <label>
            <span>密码</span>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="至少 6 位"
              autoComplete="current-password"
              required
            />
          </label>

          <label>
            <span>验证码</span>
            <div className="captcha-row">
              <input
                value={captchaText}
                onChange={(e) => setCaptchaText(e.target.value)}
                placeholder="输入图中字符"
                autoComplete="off"
                required
              />
              {captcha ? (
                <img
                  src={captcha.image}
                  alt="验证码"
                  onClick={() => void loadCaptcha()}
                  title="点击刷新"
                />
              ) : (
                <span className="captcha-loading">加载中…</span>
              )}
            </div>
          </label>

          {error && <p className="login-error">{error}</p>}

          <button className="btn btn-primary login-submit" disabled={busy}>
            {busy ? '请稍候…' : tab === 'login' ? '登录' : '注册并登录'}
          </button>
        </form>
      </div>
    </div>
  );
}
