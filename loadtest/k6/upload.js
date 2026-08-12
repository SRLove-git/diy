/**
 * Think Origin 图片上传压力测试脚本（k6）
 *
 * 聚焦 POST /api/uploads/images（multipart 字段 file，需登录态），
 * 覆盖上传链路的并发写盘（multer 临时文件 → 本地 UploadProvider rename）。
 *
 * 用法：
 *   PROFILE=smoke BASE_URL=http://host:3000 ACCOUNTS_FILE=/loadtest/accounts.json \
 *     k6 run loadtest/k6/upload.js
 *   PROFILE=spike SPIKE_VUS=500 ACCOUNTS_FILE=/loadtest/accounts.json \
 *     k6 run loadtest/k6/upload.js
 *
 * 环境变量：
 *   BASE_URL        目标地址（默认 http://localhost:3000）
 *   PROFILE         smoke | spike（默认 spike）
 *   SPIKE_VUS       spike 峰值并发（默认 500）
 *   THINK_MS        迭代间思考时间（默认 500ms）
 *   IMAGE_KB        每张测试图片大小 KB（默认 64）
 *   UPLOADS_PER_ITER 每次迭代上传张数（默认 1）
 *   ACCOUNTS_FILE   登录账号文件；未配置时每个 VU 注册兜底
 *   P95 / P99       延迟阈值（ms，默认 2000 / 5000）
 *   ERR_RATE        5xx 错误率阈值（默认 0.01）
 *
 * 注意：每次成功上传都会真实写盘到 UPLOAD_DIR（默认 /app/uploads），
 * 压测会在上传卷留下大量测试图片，测试后需要清理。
 */
import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE_URL = String(__ENV.BASE_URL || 'http://localhost:3000').replace(/\/+$/, '');
const PROFILE = String(__ENV.PROFILE || 'spike').toLowerCase();
const SPIKE_VUS = Math.max(1, Number(__ENV.SPIKE_VUS || 500));
const THINK_MS = Math.max(0, Number(__ENV.THINK_MS || 500));
const IMAGE_KB = Math.max(1, Number(__ENV.IMAGE_KB || 64));
const UPLOADS_PER_ITER = Math.max(1, Number(__ENV.UPLOADS_PER_ITER || 1));
const ACCOUNTS_FILE = __ENV.ACCOUNTS_FILE;
const P95 = Number(__ENV.P95 || 2000);
const P99 = Number(__ENV.P99 || 5000);
const ERR_RATE = Number(__ENV.ERR_RATE || 0.01);

if (!['smoke', 'spike'].includes(PROFILE)) {
  throw new Error(`未知 PROFILE: ${PROFILE}（可选 smoke / spike）`);
}

const stages =
  PROFILE === 'smoke'
    ? [
        { duration: '5s', target: 3 },
        { duration: '25s', target: 3 },
        { duration: '5s', target: 0 },
      ]
    : [
        { duration: '10s', target: 5 },
        { duration: '30s', target: SPIKE_VUS },
        { duration: '1m', target: SPIKE_VUS },
        { duration: '1m', target: 0 },
      ];

export const options = {
  scenarios: {
    main: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages,
      gracefulRampDown: '30s',
      gracefulStop: '30s',
    },
  },
  thresholds: {
    'http_req_failed{status:500}': [`rate<${ERR_RATE}`],
    'http_req_failed{status:502}': [`rate<${ERR_RATE}`],
    'http_req_failed{status:503}': [`rate<${ERR_RATE}`],
    'http_req_failed{status:504}': [`rate<${ERR_RATE}`],
    'http_req_duration{expected_response:true}': [
      `p(95)<${P95}`,
      `p(99)<${P99}`,
    ],
  },
  summaryTrendStats: ['avg', 'min', 'med', 'p(90)', 'p(95)', 'p(99)', 'max'],
};

let accounts = [];
if (ACCOUNTS_FILE) {
  accounts = JSON.parse(open(ACCOUNTS_FILE));
  if (!Array.isArray(accounts) || accounts.length === 0) {
    throw new Error(`ACCOUNTS_FILE 需要是 JSON 数组：${ACCOUNTS_FILE}`);
  }
}
const hasAuth = accounts.length > 0;

let accessToken = '';
let loggedIn = false;
let tokenOwner = '';

function accountOf(list) {
  const raw = list[__VU % list.length];
  return typeof raw === 'string'
    ? { username: raw.slice(0, raw.indexOf(':')), password: raw.slice(raw.indexOf(':') + 1) }
    : { username: String(raw.username), password: String(raw.password) };
}

function setSession(token, owner) {
  accessToken = String(token || '');
  loggedIn = !!accessToken;
  tokenOwner = owner;
}

function login() {
  if (!hasAuth) return;
  const acct = accountOf(accounts);
  const res = http.post(
    `${BASE_URL}/api/auth/login`,
    JSON.stringify({ account: acct.username, password: acct.password }),
    { headers: { 'Content-Type': 'application/json' } },
  );
  const ok = check(res, { '用户登录 2xx': (r) => r.status >= 200 && r.status < 300 });
  if (ok) {
    try {
      setSession(res.json().accessToken, acct.username);
    } catch {
      loggedIn = false;
    }
  }
}

function register() {
  const seq = `${__VU}_${__ITER}_${Math.floor(Math.random() * 1e6)}`;
  const username = `up_${seq}`.slice(0, 30);
  const email = `up_${seq}@loadtest.local`;
  const res = http.post(
    `${BASE_URL}/api/auth/register`,
    JSON.stringify({ username, email, password: 'Test123456' }),
    { headers: { 'Content-Type': 'application/json' } },
  );
  const ok = check(res, { '用户注册 2xx': (r) => r.status >= 200 && r.status < 300 });
  if (ok) {
    try {
      setSession(res.json().accessToken, username);
    } catch {
      loggedIn = false;
    }
  }
}

function ensureAuth() {
  if (loggedIn && accessToken) return true;
  if (hasAuth) login();
  else register();
  return loggedIn;
}

/** 生成一张测试图片：JPEG 文件头 + 伪随机数据（服务端只校验 MIME/扩展名，不校验魔数） */
function makeImage(kb) {
  const bytes = new Uint8Array(kb * 1024);
  // JPEG 魔数，保证按真实图片解读
  bytes[0] = 0xff; bytes[1] = 0xd8; bytes[2] = 0xff; bytes[3] = 0xe0;
  let seed = __VU * 2654435761 + __ITER * 40503;
  for (let i = 4; i < bytes.length; i++) {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    bytes[i] = seed & 0xff;
  }
  return http.file(bytes.buffer, 'loadtest.jpg', 'image/jpeg');
}

const FOLDERS = ['chat', 'avatar', 'post'];

export default function () {
  if (!loggedIn) ensureAuth();

  for (let i = 0; i < UPLOADS_PER_ITER; i++) {
    const folder = FOLDERS[Math.floor(Math.random() * FOLDERS.length)];
    const body = { file: makeImage(IMAGE_KB) };
    const res = http.post(`${BASE_URL}/api/uploads/images?folder=${folder}`, body, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    const ok = check(res, { '图片上传 2xx': (r) => r.status >= 200 && r.status < 300 });
    if (!ok && res.status === 401) {
      // token 失效：重建会话后重试一次
      loggedIn = false;
      ensureAuth();
      const retry = http.post(`${BASE_URL}/api/uploads/images?folder=${folder}`, body, {
        headers: { Authorization: `Bearer ${accessToken}` },
      });
      check(retry, { '图片上传重试 2xx': (r) => r.status >= 200 && r.status < 300 });
    }
  }

  sleep((0.5 + Math.random()) * (THINK_MS / 1000));
}
