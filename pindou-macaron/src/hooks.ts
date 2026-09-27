import { useCallback, useEffect, useRef, useState } from 'react';

export interface AsyncState<T> {
  data: T | null;
  loading: boolean;
  error: string | null;
  reload: () => void;
}

/** 页面级异步数据加载：自动请求、暴露 loading/error/刷新，卸载后丢弃过期结果 */
export function useApi<T>(
  fetcher: () => Promise<T>,
  deps: readonly unknown[] = [],
): AsyncState<T> {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [tick, setTick] = useState(0);
  const aliveRef = useRef(true);

  useEffect(() => {
    aliveRef.current = true;
    return () => {
      aliveRef.current = false;
    };
  }, []);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    setError(null);
    fetcher()
      .then((res) => {
        if (!cancelled && aliveRef.current) setData(res);
      })
      .catch((e: unknown) => {
        if (!cancelled && aliveRef.current) {
          setError(e instanceof Error ? e.message : '加载失败');
        }
      })
      .finally(() => {
        if (!cancelled && aliveRef.current) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [...deps, tick]);

  const reload = useCallback(() => setTick((t) => t + 1), []);
  return { data, loading, error, reload };
}
