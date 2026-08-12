/**
 * Think Origin 平台 HTTP 压力测试主脚本（k6）
 * 聚焦上线核心链路：预约 / 核销（含上钟下钟）/ 会员
 *
 * 用法（见 loadtest/README.md）：
 *   k6 run loadtest/k6/load.js                       # 默认 load 场景
 *   PROFILE=smoke BASE_URL=http://<host>:3000 k6 run loadtest/k6/load.js
 *   PROFILE=spike SPIKE_VUS=300 BASE_URL=... k6 run loadtest/k6/load.js
 *
 * 可选环境变量：
 *   BASE_URL            目标服务地址（默认 http://localhost:3000）
 *   PROFILE             smoke | load | spike | soak（默认 load）
 *   ACCOUNTS_FILE       会员/用户测试账号文件（JSON 数组 ["user:pass", ...]），
 *                       预约、核销、会员接口都需要登录态，建议准备 ≥ 并发数
 *   ADMIN_ACCOUNTS_FILE 可选：管理员账号文件，用于压管理端预约列表（核销相关只读）
 *   VUS / HOLD_MIN      load 场景目标并发与持续时间（默认 50 / 3 分钟）
 *   SPIKE_VUS           spike 场景峰值并发（默认 300）
 *   SOAK_VUS/SOAK_MIN   soak 场景并发与持续时间（默认 30 / 15 分钟）
 *   THINK_MS            模拟用户思考时间的基准值（默认 800ms，随机 ±50%）
 *   P95 / P99           延迟阈值（毫秒），soak 默认放宽
 *   ERR_RATE            允许的最大错误率（默认 0.01 = 1%）
 *   ABORT_ON_FAIL       true 时超过阈值立即中止（默认 false，跑完出完整报告）
 *
 * 注意：预约创建是真实写库操作，压测会产生预约/核销/会员订单数据；
 * 并发抢同一时段时返回 4xx 冲突属于业务正常行为，判断错误率时请区分 4xx 与 5xx。
 */
import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE_URL = String(__ENV.BASE_URL || 'http://localhost:3000').replace(
  /\/+$/,
  '',
);
const PROFILE = String(__ENV.PROFILE || 'load').toLowerCase();
const ACCOUNTS_FILE = __ENV.ACCOUNTS_FILE;
const ADMIN_ACCOUNTS_FILE = __ENV.ADMIN_ACCOUNTS_FILE;

const THINK_MS = Math.max(0, Number(__ENV.THINK_MS || 800));
const ERR_RATE = Number(__ENV.ERR_RATE || 0.01);
const ABORT = __ENV.ABORT_ON_FAIL === 'true';

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

/** 可选管理员账号 */
let adminAccounts = [];
if (ADMIN_ACCOUNTS_FILE) {
  adminAccounts = JSON.parse(open(ADMIN_ACCOUNTS_FILE));
  if (!Array.isArray(adminAccounts) || adminAccounts.length === 0) {
    throw new Error(`ADMIN_ACCOUNTS_FILE 需要是 JSON 数组：${ADMIN_ACCOUNTS_FILE}`);
  }
}
const hasAdmin = adminAccounts.length > 0;

/** 模块级变量按 VU 隔离：登录态 + 当前待核销的预约 */
let accessToken = '';
let loggedIn = false;
let adminToken = '';
let adminLoggedIn = false;
let pendingAppointment = null; // { id, code, used, checkinable }

function accountOf(list) {
  const raw = list[__VU % list.length];
  return typeof raw === 'string'
    ? { username: raw.slice(0, raw.indexOf(':')), password: raw.slice(raw.indexOf(':') + 1) }
    : { username: String(raw.username), password: String(raw.password) };
}

function login() {
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
    } catch (e) {
      loggedIn = false;
    }
  }
}

function loginAdmin() {
  const acct = accountOf(adminAccounts);
  const res = http.post(
    `${BASE_URL}/api/auth/login`,
    JSON.stringify({ account: acct.username, password: acct.password }),
    { headers: { 'Content-Type': 'application/json' } },
  );
  const ok = check(res, { '管理员登录 2xx': (r) => r.status >= 200 && r.status < 300 });
  if (ok) {
    try {
      adminToken = String(res.json().accessToken || '');
      adminLoggedIn = !!adminToken;
    } catch (e) {
      adminLoggedIn = false;
    }
  }
}

function todayStr() {
  const d = new Date();
  const mm = String(d.getMonth() + 1).padStart(2, '0');
  const dd = String(d.getDate()).padStart(2, '0');
  return `${d.getFullYear()}-${mm}-${dd}`;
}

/** 预约时段：订 1~3 分钟后开始的 1 小时时段（服务端拒绝已开始的时段） */
function bookableSlot() {
  const now = new Date();
  const start = new Date(now.getTime() + 60000 + Math.floor(Math.random() * 3) * 60000);
  // 营业时间按 10:00-21:00 保守处理：只订 10:00~19:59 的时段
  if (start.getHours() < 10) start.setHours(10, 0, 0, 0);
  if (start.getHours() > 19) return null; // 今天已无可订时段
  const hh = String(start.getHours()).padStart(2, '0');
  const mm = String(start.getMinutes()).padStart(2, '0');
  return {
    startTime: `${hh}:${mm}`,
    durationHours: 1,
    startMinutes: start.getHours() * 60 + start.getMinutes(),
  };
}

function minutesNow() {
  const d = new Date();
  return d.getHours() * 60 + d.getMinutes();
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

    // 40% 概率真实下单；每个 VU 同一时间只保留一个待核销预约，
    // 走完「创建→核销→下钟」再开新单（并发抢同一时段可能返回 4xx 冲突，属正常业务行为）
    if (loggedIn && table && !pendingAppointment && Math.random() < 0.4) {
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
        const create = http.post(`${BASE_URL}/api/appointments`, body, {
          headers: { 'Content-Type': 'application/json', ...auth },
        });
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
    const mine = http.get(`${BASE_URL}/api/appointments`, { headers: auth });
    check(mine, { '我的预约列表 200': (r) => r.status === 200 });

    if (pendingAppointment && !pendingAppointment.used && Math.random() < 0.2) {
      const detail = http.get(
        `${BASE_URL}/api/appointments/${pendingAppointment.id}`,
        { headers: auth },
      );
      check(detail, { '预约详情 200': (r) => r.status === 200 });
    }
  }
}

/** 核销流程：按预约码查询 → 输码核销（核销即上钟）→ 下钟 */
function checkinFlow(auth) {
  if (!pendingAppointment) {
    // 没有待核销预约时做一次轻量公开读，保持请求节奏
    const stores = http.get(`${BASE_URL}/api/stores`, { headers: auth });
    check(stores, { '门店列表 200': (r) => r.status === 200 });
    return;
  }

  const { id, code, used } = pendingAppointment;
  const nowMin = minutesNow();
  const checkinable =
    nowMin >= pendingAppointment.startMinutes &&
    nowMin < pendingAppointment.startMinutes + pendingAppointment.durationHours * 60;

  const lookup = http.get(`${BASE_URL}/api/appointments/code/${code}`, { headers: auth });
  check(lookup, { '预约码查询 200': (r) => r.status === 200 });

  if (!used && checkinable && loggedIn) {
    const checkin = http.post(
      `${BASE_URL}/api/appointments/checkin`,
      JSON.stringify({ code }),
      { headers: { 'Content-Type': 'application/json', ...auth } },
    );
    check(checkin, { '输码核销 2xx': (r) => r.status >= 200 && r.status < 300 });
    if (checkin.status >= 200 && checkin.status < 300) {
      pendingAppointment.used = true;
    }
  }

  // 核销成功后下钟（核销即上钟，无需单独上钟）
  if (pendingAppointment.used && loggedIn && Math.random() < 0.6) {
    const clockOut = http.post(
      `${BASE_URL}/api/appointments/${id}/clockout`,
      null,
      { headers: auth },
    );
    check(clockOut, { '下钟 2xx': (r) => r.status >= 200 && r.status < 300 });
    if (clockOut.status >= 200 && clockOut.status < 300) pendingAppointment = null;
  }
}

/** 会员流程：套餐/我的会员/订单/卡券/钱包/经验，偶尔下单 */
function memberFlow(auth) {
  if (!loggedIn) return;

  const plans = http.get(`${BASE_URL}/api/members/plans`, { headers: auth });
  check(plans, { '会员套餐 200': (r) => r.status === 200 });

  let planId = null;
  try {
    const list = plans.json();
    if (Array.isArray(list) && list.length > 0) planId = list[0].id;
  } catch (e) {
    // 忽略
  }

  const me = http.get(`${BASE_URL}/api/members/me`, { headers: auth });
  check(me, { '我的会员 200': (r) => r.status === 200 });

  const orders = http.get(`${BASE_URL}/api/members/orders`, { headers: auth });
  check(orders, { '会员订单 200': (r) => r.status === 200 });

  const coupons = http.get(`${BASE_URL}/api/members/coupons`, { headers: auth });
  check(coupons, { '我的卡券 200': (r) => r.status === 200 });

  const wallet = http.get(`${BASE_URL}/api/members/wallet`, { headers: auth });
  check(wallet, { '钱包 200': (r) => r.status === 200 });

  const experiences = http.get(`${BASE_URL}/api/members/experiences`, {
    headers: auth,
  });
  check(experiences, { '会员经验 200': (r) => r.status === 200 });

  // 5% 概率提交会员开通申请（真实写库）
  if (planId != null && Math.random() < 0.05) {
    const purchase = http.post(
      `${BASE_URL}/api/members/purchase`,
      JSON.stringify({ planId }),
      { headers: { 'Content-Type': 'application/json', ...auth } },
    );
    check(purchase, { '会员下单 2xx': (r) => r.status >= 200 && r.status < 300 });
  }
}

/** 其他：健康检查 + 管理端预约列表（只读，可选） */
function miscFlow() {
  const health = http.get(`${BASE_URL}/api/health`);
  check(health, { '健康检查 200': (r) => r.status === 200 });

  if (adminLoggedIn) {
    const list = http.get(`${BASE_URL}/api/admin/appointments`, {
      headers: { Authorization: `Bearer ${adminToken}` },
    });
    check(list, { '管理端预约列表 200': (r) => r.status === 200 });
  }
}

/** 用户行为权重：40% 预约、25% 核销、30% 会员、5% 其他 */
const FLOWS = [
  { weight: 40, run: bookingFlow },
  { weight: 25, run: checkinFlow },
  { weight: 30, run: memberFlow },
  { weight: 5, run: miscFlow },
];

export default function () {
  if (__ITER === 0 && hasAuth) login();
  if (__ITER === 0 && hasAdmin) loginAdmin();

  const auth = loggedIn ? { Authorization: `Bearer ${accessToken}` } : {};

  const r = Math.random() * 100;
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
