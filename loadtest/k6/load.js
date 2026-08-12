/**
 * Think Origin 平台 HTTP 压力测试主脚本（k6）
 * 聚焦上线核心链路：预约 / 注册 / 登录 / 核销（含上钟下钟）/ 会员
 *
 * 用法（见 loadtest/README.md）：
 *   k6 run loadtest/k6/load.js                       # 默认 load 场景
 *   PROFILE=smoke BASE_URL=http://<host>:3000 k6 run loadtest/k6/load.js
 *   PROFILE=spike SPIKE_VUS=300 BASE_URL=... k6 run loadtest/k6/load.js
 *
 * 可选环境变量：
 *   BASE_URL            目标服务地址（默认 http://localhost:3000）
 *   PROFILE             smoke | load | spike | soak（默认 load）
 *   ACCOUNTS_FILE       用户测试账号文件（JSON 数组 ["user:pass", ...]），
 *                       登录流程与预约/核销/会员的登录态都依赖它，建议准备 ≥ 并发数
 *   FLOW_WEIGHTS        五个流程权重，格式 "booking:30,register:10,login:15,checkin:20,member:25"
 *   REGISTER_ON_START   true 时每个 VU 首轮改为注册新账号（峰值注册并发 = VU 数）
 *   REGISTER_PASSWORD   注册账号统一密码（默认 Test123456）
 *   VUS / HOLD_MIN      load 场景目标并发与持续时间（默认 50 / 3 分钟）
 *   SPIKE_VUS           spike 场景峰值并发（默认 300）
 *   SOAK_VUS/SOAK_MIN   soak 场景并发与持续时间（默认 30 / 15 分钟）
 *   THINK_MS            模拟用户思考时间的基准值（默认 800ms，随机 ±50%）
 *   P95 / P99           延迟阈值（毫秒），soak 默认放宽
 *   ERR_RATE            允许的最大错误率（默认 0.01 = 1%）
 *   ABORT_ON_FAIL       true 时超过阈值立即中止（默认 false，跑完出完整报告）
 *
 * 注意：注册、预约创建、核销、会员下单都是真实写库操作，压测会在测试库留下数据；
 * 并发抢同一时段/桌位返回 4xx 冲突属于业务正常行为，错误率阈值只统计 5xx。
 */
import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE_URL = String(__ENV.BASE_URL || 'http://localhost:3000').replace(
  /\/+$/,
  '',
);
const PROFILE = String(__ENV.PROFILE || 'load').toLowerCase();
const ACCOUNTS_FILE = __ENV.ACCOUNTS_FILE;

const THINK_MS = Math.max(0, Number(__ENV.THINK_MS || 800));
const ERR_RATE = Number(__ENV.ERR_RATE || 0.01);
const ABORT = __ENV.ABORT_ON_FAIL === 'true';
const REGISTER_ON_START = __ENV.REGISTER_ON_START === 'true';
const REGISTER_PASSWORD = String(__ENV.REGISTER_PASSWORD || 'Test123456');

const PROFILES = ['smoke', 'load', 'spike', 'soak'];
if (!PROFILES.includes(PROFILE)) {
  throw new Error(`未知 PROFILE: ${PROFILE}（可选 ${PROFILES.join(' / ')}）`);
}

const VUS = Math.max(1, Number(__ENV.VUS || 50));
const HOLD_MIN = Math.max(1, Number(__ENV.HOLD_MIN || 3));
const SPIKE_VUS = Math.max(1, Number(__ENV.SPIKE_VUS || 300));
const SOAK_VUS = Math.max(1, Number(__ENV.SOAK_VUS || 30));
const SOAK_MIN = Math.max(1, Number(__ENV.SOAK_MIN || 15));

/** 各场景的 VU 曲线（并发随时间变化） */
const stages = {
  smoke: [
    { duration: '5s', target: 3 },
    { duration: '25s', target: 3 },
    { duration: '5s', target: 0 },
  ],
  load: [
    { duration: '1m', target: Math.round(VUS / 2) },
    { duration: '1m', target: VUS },
    { duration: `${HOLD_MIN}m`, target: VUS },
    { duration: '1m', target: 0 },
  ],
  spike: [
    { duration: '10s', target: 5 },
    { duration: '30s', target: SPIKE_VUS },
    { duration: '1m', target: SPIKE_VUS },
    { duration: '1m', target: 0 },
  ],
  soak: [
    { duration: '2m', target: SOAK_VUS },
    { duration: `${SOAK_MIN}m`, target: SOAK_VUS },
    { duration: '1m', target: 0 },
  ],
}[PROFILE];

const P95 = Number(__ENV.P95 || (PROFILE === 'soak' ? 800 : 500));
const P99 = Number(__ENV.P99 || (PROFILE === 'soak' ? 1500 : 1200));

const threshold = (expr) =>
  ABORT ? { threshold: expr, abortOnFail: true } : expr;

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
    // 4xx 多为预约冲突/参数校验等业务行为，错误率阈值只盯 5xx
    'http_req_failed{status:500}': [threshold(`rate<${ERR_RATE}`)],
    'http_req_failed{status:502}': [threshold(`rate<${ERR_RATE}`)],
    'http_req_failed{status:503}': [threshold(`rate<${ERR_RATE}`)],
    'http_req_failed{status:504}': [threshold(`rate<${ERR_RATE}`)],
    'http_req_duration{expected_response:true}': [
      threshold(`p(95)<${P95}`),
      threshold(`p(99)<${P99}`),
    ],
  },
  summaryTrendStats: ['avg', 'min', 'med', 'p(90)', 'p(95)', 'p(99)', 'max'],
};

/** 用户/会员测试账号 */
let accounts = [];
if (ACCOUNTS_FILE) {
  accounts = JSON.parse(open(ACCOUNTS_FILE));
  if (!Array.isArray(accounts) || accounts.length === 0) {
    throw new Error(
      `ACCOUNTS_FILE 需要是 JSON 数组，如 ["alice:pass123","bob:pass456"]：${ACCOUNTS_FILE}`,
    );
  }
}
const hasAuth = accounts.length > 0;

/** 模块级变量按 VU 隔离：登录态 + 当前待核销的预约 */
let accessToken = '';
let loggedIn = false;
let pendingAppointment = null; // { id, code, used, checkinable }
let tokenOwner = ''; // 当前 token 归属的用户名，身份变化时丢弃旧的待核销预约

function accountOf(list) {
  const raw = list[__VU % list.length];
  return typeof raw === 'string'
    ? { username: raw.slice(0, raw.indexOf(':')), password: raw.slice(raw.indexOf(':') + 1) }
    : { username: String(raw.username), password: String(raw.password) };
}

/** 登录：用户名/邮箱 + 密码 */
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
      accessToken = String(res.json().accessToken || '');
      loggedIn = !!accessToken;
      if (loggedIn && tokenOwner && tokenOwner !== acct.username) {
        pendingAppointment = null;
      }
      if (loggedIn) tokenOwner = acct.username;
    } catch (e) {
      loggedIn = false;
    }
  }
}

/** 注册：唯一用户名+邮箱，注册即登录（服务端直接返回 token） */
function registerFlow() {
  const seq = `${__VU}_${__ITER}_${Math.floor(Math.random() * 1e6)}`;
  const username = `lt_${seq}`.slice(0, 30);
  const email = `lt_${seq}@loadtest.local`;
  const res = http.post(
    `${BASE_URL}/api/auth/register`,
    JSON.stringify({ username, email, password: REGISTER_PASSWORD }),
    { headers: { 'Content-Type': 'application/json' } },
  );
  const ok = check(res, { '用户注册 2xx': (r) => r.status >= 200 && r.status < 300 });
  if (ok) {
    try {
      accessToken = String(res.json().accessToken || '');
      loggedIn = !!accessToken;
      if (loggedIn && tokenOwner && tokenOwner !== username) {
        pendingAppointment = null;
      }
      if (loggedIn) tokenOwner = username;
    } catch (e) {
      loggedIn = false;
    }
  }
}

/**
 * 身份管理：
 * - ensureAuth()：确保当前 VU 有可用会话（账号文件优先登录，无账号文件时注册兜底）；
 * - authedRequest()：带登录态的请求，token 失效（401）时重建会话并重试一次；
 * - invalidateSession()：清空会话与归属绑定，避免旧身份的数据被继续操作。
 */
function ensureAuth() {
  if (loggedIn && accessToken) return true;
  if (hasAuth) login();
  else registerFlow();
  return loggedIn;
}

function invalidateSession() {
  accessToken = '';
  loggedIn = false;
  tokenOwner = '';
  pendingAppointment = null; // 身份已失效，旧的待核销预约归属不可用
}

/** 带登录态的请求：401 时重建会话后重试一次，返回最后一次响应 */
function authedRequest(method, url, body) {
  const headers = { 'Content-Type': 'application/json' };
  let last = null;
  for (let attempt = 0; attempt < 2; attempt++) {
    if (!loggedIn || !accessToken) ensureAuth();
    last = http.request(method, url, body, {
      headers: { ...headers, Authorization: `Bearer ${accessToken}` },
    });
    if (last.status !== 401) return last;
    // token 失效/被踢：重建会话后重试
    invalidateSession();
    if (hasAuth) login();
    else registerFlow();
  }
  return last;
}

/** 服务器时区 Asia/Shanghai (UTC+8)：k6 容器默认 UTC，本地时间统一偏移计算 */
const TZ_OFFSET_MS = 8 * 60 * 60 * 1000;

function shanghaiNow() {
  return new Date(Date.now() + TZ_OFFSET_MS);
}

function todayStr() {
  const d = shanghaiNow();
  const mm = String(d.getUTCMonth() + 1).padStart(2, '0');
  const dd = String(d.getUTCDate()).padStart(2, '0');
  return `${d.getUTCFullYear()}-${mm}-${dd}`;
}

/** 预约时段：订 1~120 分钟之后开始的 1 小时时段（服务端拒绝已开始的时段） */
function bookableSlot() {
  const now = shanghaiNow();
  const start = new Date(now.getTime() + 60000 + Math.floor(Math.random() * 119) * 60000);
  // 营业时间按 10:00-21:00 保守处理：只订 10:00~19:59 的时段
  if (start.getUTCHours() < 10) start.setUTCHours(10, 0, 0, 0);
  if (start.getUTCHours() > 19) return null; // 今天已无可订时段
  const hh = String(start.getUTCHours()).padStart(2, '0');
  const mm = String(start.getUTCMinutes()).padStart(2, '0');
  return {
    startTime: `${hh}:${mm}`,
    durationHours: 1,
    startMinutes: start.getUTCHours() * 60 + start.getUTCMinutes(),
  };
}

function firstStoreId(res) {
  try {
    const stores = res.json();
    if (Array.isArray(stores) && stores.length > 0) return stores[0].id;
  } catch (e) {
    // 忽略解析失败
  }
  return null;
}

/** 门店详情里的桌位列表，随机选一张可用桌（分散并发抢座压力） */
function firstTable(detailRes) {
  try {
    const store = detailRes.json();
    const tables = Array.isArray(store.tables)
      ? store.tables.filter((t) => t.enabled !== false)
      : [];
    if (tables.length === 0) return null;
    return tables[Math.floor(Math.random() * tables.length)];
  } catch (e) {
    return null;
  }
}

/** 预约流程：选店/选活动 → 看可约时段 → 创建预约 → 我的预约/详情/取消 */
function bookingFlow(auth) {
  // 身份归属防御：会话切换后旧预约不属于当前用户，直接丢弃
  if (pendingAppointment && pendingAppointment.owner !== tokenOwner) {
    pendingAppointment = null;
  }

  const stores = http.get(`${BASE_URL}/api/stores`, { headers: auth });
  check(stores, { '门店列表 200': (r) => r.status === 200 });
  const storeId = firstStoreId(stores);

  const activities = http.get(`${BASE_URL}/api/activities`, { headers: auth });
  check(activities, { '活动列表 200': (r) => r.status === 200 });

  const today = todayStr();

  if (storeId != null) {
    const detail = http.get(`${BASE_URL}/api/stores/${storeId}`, { headers: auth });
    check(detail, { '门店详情 200': (r) => r.status === 200 });
    const table = firstTable(detail);

    const avail = http.get(
      `${BASE_URL}/api/appointments/availability?storeId=${storeId}&date=${today}`,
      { headers: auth },
    );
    check(avail, { '桌位可用性 200': (r) => r.status === 200 });

    // 50% 概率真实下单；每个 VU 同一时间只保留一个待核销预约，
    // 走完「创建→核销→下钟」再开新单（并发抢同一时段可能返回 4xx 冲突，属正常业务行为）
    if (loggedIn && table && !pendingAppointment && Math.random() < 0.5) {
      const slot = bookableSlot();
      if (slot) {
        const body = JSON.stringify({
          storeId,
          tableId: table.id,
          date: today,
          startTime: slot.startTime,
          durationHours: slot.durationHours,
          peopleCount: Math.max(1, Math.min(2, Number(table.capacity) || 1)),
          payMethod: Math.random() < 0.5 ? 'wechat' : 'alipay',
        });
        const create = authedRequest('POST', `${BASE_URL}/api/appointments`, body);
        check(create, { '创建预约 2xx': (r) => r.status >= 200 && r.status < 300 });
        if (create.status >= 200 && create.status < 300) {
          try {
            const appt = create.json();
            if (appt && appt.id && appt.code) {
              pendingAppointment = {
                id: appt.id,
                code: appt.code,
                used: false,
                startMinutes: slot.startMinutes,
                durationHours: slot.durationHours,
                owner: tokenOwner,
              };
            }
          } catch (e) {
            // 忽略解析失败
          }
        }
      }
    }
  }

  // 有可预约活动时读场次（预约前选场次）
  try {
    const acts = activities.json();
    const bookable = Array.isArray(acts) ? acts.find((a) => a.bookable !== false) : null;
    if (bookable) {
      const sessions = http.get(
        `${BASE_URL}/api/appointments/activity-sessions?activityId=${bookable.id}`,
        { headers: auth },
      );
      check(sessions, { '活动场次 200': (r) => r.status === 200 });
    }
  } catch (e) {
    // 忽略解析失败
  }

  if (loggedIn) {
    const mine = authedRequest('GET', `${BASE_URL}/api/appointments`);
    check(mine, { '我的预约列表 200': (r) => r.status === 200 });

    if (pendingAppointment && !pendingAppointment.used && Math.random() < 0.2) {
      const detail = authedRequest(
        'GET',
        `${BASE_URL}/api/appointments/${pendingAppointment.id}`,
      );
      check(detail, { '预约详情 200': (r) => r.status === 200 });
    }
  }
}

/** 核销流程：按预约码查询 → 输码核销（核销即上钟）→ 下钟 */
function checkinFlow(auth) {
  // 身份归属防御：会话切换后旧预约不属于当前用户，直接丢弃
  if (pendingAppointment && pendingAppointment.owner !== tokenOwner) {
    pendingAppointment = null;
  }

  if (!pendingAppointment) {
    // 没有待核销预约时做一次轻量公开读，保持请求节奏
    const stores = http.get(`${BASE_URL}/api/stores`, { headers: auth });
    check(stores, { '门店列表 200': (r) => r.status === 200 });
    return;
  }

  const { id, code, used } = pendingAppointment;

  const lookup = http.get(`${BASE_URL}/api/appointments/code/${code}`, { headers: auth });
  check(lookup, { '预约码查询 200': (r) => r.status === 200 });

  // 服务端允许提前到店核销（仅拒绝时段已结束的预约），核销即上钟
  if (!used && loggedIn) {
    const checkin = authedRequest(
      'POST',
      `${BASE_URL}/api/appointments/checkin`,
      JSON.stringify({ code }),
    );
    check(checkin, { '输码核销 2xx': (r) => r.status >= 200 && r.status < 300 });
    if (checkin.status >= 200 && checkin.status < 300) {
      pendingAppointment.used = true;
    }
  }

  // 核销成功后下钟（核销即上钟，无需单独上钟）
  if (pendingAppointment.used && loggedIn && Math.random() < 0.6) {
    const clockOut = authedRequest(
      'POST',
      `${BASE_URL}/api/appointments/${id}/clockout`,
    );
    check(clockOut, { '下钟 2xx': (r) => r.status >= 200 && r.status < 300 });
    if (clockOut.status >= 200 && clockOut.status < 300) pendingAppointment = null;
  }
}

/** 会员流程：套餐/我的会员/订单/卡券/钱包/经验，偶尔下单 */
function memberFlow(auth) {
  if (!loggedIn) return;

  const plans = authedRequest('GET', `${BASE_URL}/api/members/plans`);
  check(plans, { '会员套餐 200': (r) => r.status === 200 });

  let planId = null;
  try {
    const list = plans.json();
    if (Array.isArray(list) && list.length > 0) planId = list[0].id;
  } catch (e) {
    // 忽略
  }

  const me = authedRequest('GET', `${BASE_URL}/api/members/me`);
  check(me, { '我的会员 200': (r) => r.status === 200 });

  const orders = authedRequest('GET', `${BASE_URL}/api/members/orders`);
  check(orders, { '会员订单 200': (r) => r.status === 200 });

  const coupons = authedRequest('GET', `${BASE_URL}/api/members/coupons`);
  check(coupons, { '我的卡券 200': (r) => r.status === 200 });

  const wallet = authedRequest('GET', `${BASE_URL}/api/members/wallet`);
  check(wallet, { '钱包 200': (r) => r.status === 200 });

  const experiences = authedRequest('GET', `${BASE_URL}/api/members/experiences`);
  check(experiences, { '会员经验 200': (r) => r.status === 200 });

  // 5% 概率提交会员开通申请（真实写库）
  if (planId != null && Math.random() < 0.05) {
    const purchase = authedRequest(
      'POST',
      `${BASE_URL}/api/members/purchase`,
      JSON.stringify({ planId }),
    );
    check(purchase, { '会员下单 2xx': (r) => r.status >= 200 && r.status < 300 });
  }
}

/** 五个流程权重，可用 FLOW_WEIGHTS 覆盖 */
function parseFlowWeights(raw) {
  const map = { booking: 0, register: 0, login: 0, checkin: 0, member: 0 };
  for (const part of raw.split(',')) {
    const p = part.trim();
    if (!p) continue;
    const sep = p.indexOf(':');
    const name = sep > 0 ? p.slice(0, sep) : p;
    const w = sep > 0 ? Number(p.slice(sep + 1)) : 1;
    if (name in map) map[name] = Math.max(0, Number(w) || 0);
  }
  const total = Object.values(map).reduce((s, v) => s + v, 0);
  if (total <= 0) throw new Error('FLOW_WEIGHTS 权重总和必须大于 0');
  return map;
}

const flowWeights = parseFlowWeights(
  String(__ENV.FLOW_WEIGHTS || 'booking:30,register:10,login:15,checkin:20,member:25'),
);

const FLOWS = [
  { name: 'booking', weight: flowWeights.booking, run: bookingFlow },
  { name: 'register', weight: flowWeights.register, run: registerFlow },
  { name: 'login', weight: flowWeights.login, run: login },
  { name: 'checkin', weight: flowWeights.checkin, run: checkinFlow },
  { name: 'member', weight: flowWeights.member, run: memberFlow },
].filter((f) => f.weight > 0);

const totalWeight = FLOWS.reduce((s, f) => s + f.weight, 0);

export default function () {
  // 身份管理：会话缺失时（首轮 / 登录失败 / token 被踢后）自动补建；
  // REGISTER_ON_START=true 时首轮注册新账号，否则用账号文件登录，无账号文件则注册兜底
  if (!loggedIn) {
    if (REGISTER_ON_START) registerFlow();
    else ensureAuth();
  }

  const auth = loggedIn ? { Authorization: `Bearer ${accessToken}` } : {};

  const r = Math.random() * totalWeight;
  let acc = 0;
  for (const flow of FLOWS) {
    acc += flow.weight;
    if (r <= acc) {
      flow.run(auth);
      break;
    }
  }

  // 模拟真实用户思考时间：THINK_MS 的 0.5~1.5 倍
  sleep((0.5 + Math.random()) * (THINK_MS / 1000));
}
