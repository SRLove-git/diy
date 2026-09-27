import { useCallback, useEffect, useState } from 'react';
import { ToastProvider } from './components';
import { AuthProvider, useAuth } from './auth';
import { LoginView } from './LoginView';
import { H5App } from './h5';
import { PCApp } from './pc';
import { DeviceIcon } from './icons';

type Mode = 'auto' | 'mobile' | 'desktop';

const MOBILE_QUERY = '(max-width: 820px)';

function getInitial(): { mode: Mode; page: string } {
  const params = new URLSearchParams(window.location.search);
  const page = params.get('page') || 'home';
  const rawMode = params.get('mode');
  const mode: Mode =
    rawMode === 'mobile' || rawMode === 'desktop' || rawMode === 'auto'
      ? rawMode
      : 'auto';
  return { mode, page };
}

function AppShell() {
  const [initial] = useState(getInitial);
  const [mode, setMode] = useState<Mode>(initial.mode);
  const [isMobile, setIsMobile] = useState(() => window.matchMedia(MOBILE_QUERY).matches);
  const [page, setPage] = useState(initial.page);
  const { ready, token } = useAuth();

  useEffect(() => {
    const mq = window.matchMedia(MOBILE_QUERY);
    const onChange = (e: MediaQueryListEvent) => setIsMobile(e.matches);
    mq.addEventListener('change', onChange);
    return () => mq.removeEventListener('change', onChange);
  }, []);

  const navigate = useCallback((next: string) => {
    setPage(next);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }, []);

  const effectiveMobile = mode === 'mobile' || (mode === 'auto' && isMobile);

  return (
    <div className="app-root">
      {!ready ? (
        <div className="boot-splash">加载中…</div>
      ) : !token ? (
        <LoginView />
      ) : effectiveMobile ? (
        <H5App page={page} navigate={navigate} />
      ) : (
        <PCApp page={page} navigate={navigate} />
      )}
      {ready && token && <DeviceSwitch mode={mode} onChange={setMode} />}
    </div>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <ToastProvider>
        <AppShell />
      </ToastProvider>
    </AuthProvider>
  );
}

function DeviceSwitch({
  mode,
  onChange,
}: {
  mode: Mode;
  onChange: (m: Mode) => void;
}) {
  const options: { key: Mode; label: string }[] = [
    { key: 'auto', label: '自动' },
    { key: 'mobile', label: '手机' },
    { key: 'desktop', label: '电脑' },
  ];
  return (
    <div className="device-switch" title="预览设备">
      <DeviceIcon size={16} />
      {options.map((o) => (
        <button
          key={o.key}
          className={mode === o.key ? 'is-active' : ''}
          onClick={() => onChange(o.key)}
        >
          {o.label}
        </button>
      ))}
    </div>
  );
}
