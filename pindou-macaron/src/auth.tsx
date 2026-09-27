import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';
import { authApi } from './api';
import { clearTokens, getAccessToken, setTokens } from './api/http';
import type { SafeUser } from './api/types';

interface AuthContextValue {
  token: string | null;
  me: SafeUser | null;
  ready: boolean;
  login: (
    account: string,
    password: string,
    captchaId: string,
    captchaText: string,
  ) => Promise<void>;
  register: (
    username: string,
    email: string,
    password: string,
    captchaId: string,
    captchaText: string,
  ) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [token, setTokenState] = useState<string | null>(getAccessToken());
  const [me, setMe] = useState<SafeUser | null>(null);
  const [ready, setReady] = useState(false);

  const applyAuth = useCallback((accessToken: string, refreshToken: string) => {
    setTokens(accessToken, refreshToken);
    setTokenState(accessToken);
  }, []);

  const clear = useCallback(() => {
    clearTokens();
    setTokenState(null);
    setMe(null);
  }, []);

  const refreshMe = useCallback(async () => {
    try {
      const user = await authApi.me();
      setMe(user);
    } catch {
      // 登录态失效由 http 层统一触发 pd:unauthorized，这里不重复清 token
    }
  }, []);

  useEffect(() => {
    let active = true;
    if (getAccessToken()) {
      authApi
        .me()
        .then((user) => {
          if (active) setMe(user);
        })
        .catch(() => {
          if (active) clear();
        })
        .finally(() => {
          if (active) setReady(true);
        });
    } else {
      setReady(true);
    }
    return () => {
      active = false;
    };
  }, [clear]);

  useEffect(() => {
    const onUnauthorized = () => clear();
    window.addEventListener('pd:unauthorized', onUnauthorized);
    return () => window.removeEventListener('pd:unauthorized', onUnauthorized);
  }, [clear]);

  const login = useCallback(
    async (
      account: string,
      password: string,
      captchaId: string,
      captchaText: string,
    ) => {
      const res = await authApi.login({
        account,
        password,
        captchaId,
        captchaText,
      });
      applyAuth(res.accessToken, res.refreshToken);
      await refreshMe();
    },
    [applyAuth, refreshMe],
  );

  const register = useCallback(
    async (
      username: string,
      email: string,
      password: string,
      captchaId: string,
      captchaText: string,
    ) => {
      const res = await authApi.register({
        username,
        email,
        password,
        captchaId,
        captchaText,
      });
      applyAuth(res.accessToken, res.refreshToken);
      await refreshMe();
    },
    [applyAuth, refreshMe],
  );

  const logout = useCallback(() => clear(), [clear]);

  const value = useMemo(
    () => ({ token, me, ready, login, register, logout }),
    [token, me, ready, login, register, logout],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
