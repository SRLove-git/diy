#!/usr/bin/env node
/**
 * Think Origin 零依赖 Node 压测脚本（没有 k6 / Docker 时的备用方案）
 *
 * 用法：
 *   node loadtest/stress.js --url http://localhost:3000 --concurrency 100 --duration 60
 *
 * 参数：
 *   --url            目标服务地址（默认 $BASE_URL 或 http://localhost:3000）
 *   --concurrency/-c 并发数（默认 20）
 *   --duration/-d    持续时间，秒（默认 60）
 *   --ramp           爬坡时间，秒：并发数从 1 线性增加到目标值（默认 0）
 *   --think          每次请求后的思考时间，毫秒（默认 100）
 *   --token          附加 Authorization: Bearer <token>（默认无）
 *   --endpoints      覆盖默认接口，格式 "path:权重[,path:权重...]"，
 *                    如 "/api/health:5,/api/appointments/availability?storeId=1&date=2026-08-12:30"
 *   --timeout        单请求超时，毫秒（默认 10000）
 *
 * 输出：总览 + 每个接口的请求数/RPS/错误率/延迟分位/状态码分布。
 *
 * 注意：本脚本只压公开/免登录接口（预约与会员的核心写操作需要登录态，
 * 请用 k6 脚本配 ACCOUNTS_FILE）。默认接口集为预约相关公开读接口。
 */
'use strict';

const http = require('http');
const https = require('https');

const args = process.argv.slice(2);

function opt(name, def) {
  const i = args.indexOf(name);
  if (i >= 0 && args[i + 1]) return args[i + 1];
  return def;
}

const config = {
  url: String(opt('--url', process.env.BASE_URL || 'http://localhost:3000')).replace(/\/+$/, ''),
  concurrency: Math.max(1, Number(opt('--concurrency', opt('-c', '20')))),
  duration: Math.max(1, Number(opt('--duration', opt('-d', '60')))),
  ramp: Math.max(0, Number(opt('--ramp', '0'))),
  thinkMs: Math.max(0, Number(opt('--think', '100'))),
  token: String(opt('--token', '')),
  timeout: Math.max(100, Number(opt('--timeout', '10000'))),
  endpointsRaw: String(opt('--endpoints', '')),
};

function todayLocal() {
  const d = new Date();
  const mm = String(d.getMonth() + 1).padStart(2, '0');
  const dd = String(d.getDate()).padStart(2, '0');
  return `${d.getFullYear()}-${mm}-${dd}`;
}

const DEFAULT_ENDPOINTS = [
  { path: '/api/health', weight: 5 },
  { path: '/api/stores', weight: 30 },
  { path: '/api/activities', weight: 25 },
  { path: `/api/appointments/availability?storeId=1&date=${todayLocal()}`, weight: 25 },
];

function parseEndpoints(raw) {
  if (!raw) return DEFAULT_ENDPOINTS;
  const eps = [];
  for (const part of raw.split(',')) {
    const p = part.trim();
    if (!p) continue;
    const sep = p.lastIndexOf(':');
    if (sep <= 0) {
      eps.push({ path: p, weight: 1 });
    } else {
      const path = p.slice(0, sep);
      const weight = Math.max(0, Number(p.slice(sep + 1)) || 1);
      eps.push({ path, weight });
    }
  }
  return eps;
}

const endpoints = parseEndpoints(config.endpointsRaw);
const totalWeight = endpoints.reduce((s, e) => s + e.weight, 0) || 1;

const parsed = new URL(config.url);
const transport = parsed.protocol === 'https:' ? https : http;
const agent = new transport.Agent({
  keepAlive: true,
  maxSockets: config.concurrency * 2,
});

/** 每个接口的统计：次数、状态码分布、毫秒级延迟直方图 */
const stats = new Map();
for (const ep of endpoints) {
  stats.set(ep.path, { ok: 0, err: 0, status: new Map(), hist: new Map(), max: 0 });
}

function pickEndpoint() {
  let r = Math.random() * totalWeight;
  for (const ep of endpoints) {
    r -= ep.weight;
    if (r <= 0) return ep;
  }
  return endpoints[0];
}

function request(ep) {
  const url = config.url + ep.path;
  return new Promise((resolve, reject) => {
    const req = transport.get(
      url,
      {
        agent,
        headers: config.token ? { Authorization: `Bearer ${config.token}` } : {},
      },
      (res) => {
        res.resume();
        res.on('end', () => resolve({ status: res.statusCode }));
      },
    );
    req.on('error', reject);
    req.setTimeout(config.timeout, () => req.destroy(new Error('timeout')));
  });
}

function record(ep, ms, ok, status) {
  const s = stats.get(ep.path);
  if (ok) s.ok++;
  else s.err++;
  if (status != null) s.status.set(status, (s.status.get(status) || 0) + 1);
  const m = Math.round(ms);
  s.hist.set(m, (s.hist.get(m) || 0) + 1);
  if (m > s.max) s.max = m;
}

function percentile(hist, total, p) {
  if (!total) return 0;
  let acc = 0;
  const keys = [...hist.keys()].sort((a, b) => a - b);
  const target = total * p;
  for (const k of keys) {
    acc += hist.get(k);
    if (acc >= target) return k;
  }
  return keys[keys.length - 1];
}

function summarize() {
  console.log('\n========== 压测结果 ==========');
  console.log(`目标: ${config.url}  并发: ${config.concurrency}  时长: ${config.duration}s\n`);

  let totalOk = 0;
  let totalErr = 0;
  const rows = [];
  for (const [path, s] of stats) {
    const total = s.ok + s.err;
    totalOk += s.ok;
    totalErr += s.err;
    const avg = total
      ? [...s.hist.entries()].reduce((a, [k, c]) => a + k * c, 0) / total
      : 0;
    rows.push({
      path,
      total,
      rps: total / config.duration,
      errRate: total ? (s.err / total) * 100 : 0,
      avg: avg.toFixed(1),
      p50: percentile(s.hist, total, 0.5),
      p95: percentile(s.hist, total, 0.95),
      p99: percentile(s.hist, total, 0.99),
      max: s.max,
      status: [...s.status.entries()].map(([k, c]) => `${k}:${c}`).join(' '),
    });
  }

  const grand = totalOk + totalErr;
  console.log(
    `总请求: ${grand}  成功: ${totalOk}  失败: ${totalErr}  RPS: ${(grand / config.duration).toFixed(1)}  错误率: ${grand ? ((totalErr / grand) * 100).toFixed(2) : 0}%\n`,
  );
  console.log('接口明细（延迟单位 ms）:');
  console.log(
    '接口'.padEnd(52) +
      '请求数'.padStart(8) +
      'RPS'.padStart(7) +
      '错误%'.padStart(7) +
      'avg'.padStart(7) +
      'p50'.padStart(7) +
      'p95'.padStart(7) +
      'p99'.padStart(7) +
      'max'.padStart(7),
  );
  for (const r of rows) {
    console.log(
      ('  ' + (r.path.length > 50 ? r.path.slice(0, 47) + '...' : r.path)).padEnd(52) +
        String(r.total).padStart(8) +
        r.rps.toFixed(1).padStart(7) +
        r.errRate.toFixed(2).padStart(7) +
        String(r.avg).padStart(7) +
        String(r.p50).padStart(7) +
        String(r.p95).padStart(7) +
        String(r.p99).padStart(7) +
        String(r.max).padStart(7),
    );
    if (r.status) console.log(`      status: ${r.status}`);
  }
  console.log('\n==============================');
}

async function main() {
  const start = Date.now();
  const stopAt = start + config.duration * 1000;
  const activeWorkers = [];

  const worker = async () => {
    while (Date.now() < stopAt) {
      const ep = pickEndpoint();
      const t0 = Date.now();
      try {
        const res = await request(ep);
        const ok = res.status >= 200 && res.status < 300;
        record(ep, Date.now() - t0, ok, res.status);
      } catch (e) {
        record(ep, Date.now() - t0, false, null);
      }
      if (config.thinkMs > 0) {
        await new Promise((r) => setTimeout(r, Math.random() * config.thinkMs));
      }
    }
  };

  const spawn = () => {
    let target = config.concurrency;
    if (config.ramp > 0) {
      const elapsed = Math.min(1, (Date.now() - start) / (config.ramp * 1000));
      target = Math.max(1, Math.round(config.concurrency * elapsed));
    }
    while (target > activeWorkers.length) {
      activeWorkers.push(worker());
    }
  };

  spawn();
  const timer = setInterval(spawn, 100);

  while (Date.now() < stopAt) {
    await new Promise((r) => setTimeout(r, 200));
  }
  clearInterval(timer);
  await Promise.allSettled(activeWorkers);

  summarize();
  process.exit(0);
}

main().catch((e) => {
  console.error('压测失败:', e);
  process.exit(1);
});
