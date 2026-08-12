# 压力测试（loadtest）

上线前压测 Think Origin 服务端，聚焦**预约 / 注册 / 登录 / 核销（含上钟下钟）/ 会员**五大核心链路。套件包含：

| 文件 | 说明 |
| --- | --- |
| `k6/load.js` | 主压测脚本（k6，推荐） |
| `stress.js` | 零依赖 Node 备用脚本（只压公开接口） |

测试的是 API 服务（`/api`），默认目标 `http://localhost:3000`。建议对**预发或生产服务器**压测，不要在开发机压本机 dev 服务（结果不具代表性）。

---

## 一、k6 方式（推荐）

### 1. 无需安装：用 Docker 跑

```bash
docker run --rm -v "$PWD/loadtest:/loadtest" -e BASE_URL=http://<服务器IP>:3000 \
  -e PROFILE=smoke -e ACCOUNTS_FILE=/loadtest/accounts.json \
  grafana/k6 run /loadtest/k6/load.js
```

### 2. 本地安装 k6

```bash
brew install k6            # macOS
# 或下载二进制：https://github.com/grafana/k6/releases
```

### 3. 四种场景

| 场景 | 用途 | 默认曲线 |
| --- | --- | --- |
| `PROFILE=smoke` | 冒烟：确认脚本与接口正常 | 3 并发跑 30s |
| `PROFILE=load` | 常规负载：看持续压力下的稳定性 | 爬坡到 50 并发，保持 3 分钟 |
| `PROFILE=spike` | 突刺：看瞬时高并发下是否崩/恢复 | 30s 内冲到 300 并发，保持 1 分钟 |
| `PROFILE=soak` | 浸泡：长时间运行找内存/连接泄漏 | 30 并发跑 15 分钟 |

### 4. 必须准备：测试账号

预约、核销、会员接口**全部需要登录态**，所以账号是硬性要求（不配账号只能冒烟几个公开读接口）。准备若干测试账号（**正式数据里的账号不要用**，压测会真实写入预约单、核销记录和会员订单）：

```bash
cat > loadtest/accounts.json <<'EOF'
[
  "loadtest01:Test123456",
  "loadtest02:Test123456",
  "loadtest03:Test123456"
]
EOF
```

账号文件支持对象格式：`[{"username":"u","password":"p"}]`。账号数建议 ≥ 目标并发数（并发 50 建议准备 50 个账号），避免同一账号被大量并发登录打爆防刷限制。

注册流程会真实创建用户（用户名 `lt_*`），登录、预约、核销、会员接口都依赖登录态；
`FLOW_WEIGHTS` 里的 `register` 权重控制注册压力量，`REGISTER_ON_START=true` 可让每个 VU 首轮都注册新账号。

### 5. 运行

```bash
# 冒烟
BASE_URL=http://<服务器IP>:3000 PROFILE=smoke \
  ACCOUNTS_FILE=/path/to/loadtest/accounts.json \
  k6 run loadtest/k6/load.js

# 常规负载（默认 50 并发，爬坡 2 分钟 + 保持 3 分钟）
BASE_URL=http://<服务器IP>:3000 PROFILE=load VUS=50 HOLD_MIN=5 \
  ACCOUNTS_FILE=/path/to/loadtest/accounts.json \
  k6 run loadtest/k6/load.js

# 突刺 / 浸泡
PROFILE=spike SPIKE_VUS=300 ...
PROFILE=soak SOAK_VUS=30 SOAK_MIN=15 ...
```

### 6. 覆盖的接口（按用户行为权重）

| 流程 | 权重 | 覆盖接口 |
| --- | --- | --- |
| 预约 | 30% | 门店列表、门店详情（选桌位）、活动列表、桌位可用性、活动场次、创建预约（50% 概率）、我的预约、预约详情 |
| 注册 | 10% | 注册（唯一用户名+邮箱，注册即登录，真实写库） |
| 登录 | 15% | 登录（账号文件中的账号，走密码校验 + 签发 token） |
| 核销 | 20% | 按预约码查询（公开）、输码核销（核销即上钟）、下钟（60% 概率） |
| 会员 | 25% | 套餐列表、我的会员、会员订单、我的卡券、钱包、会员经验、提交开通申请（5% 概率） |

五个流程的权重可通过 `FLOW_WEIGHTS` 调整。

**数据说明**：注册、创建预约、核销、下钟、会员下单都会真实写库，压测会在测试库留下对应用户/预约/订单数据；预约的核销/下钟操作有状态流转，同一预约码只能核销一次，脚本按虚拟用户各自维护「创建 → 核销 → 下钟」的完整生命周期（每个 VU 同时只保留一个待核销预约，串行走完再开新单）。并发抢同一时段/桌位返回 4xx 冲突属于**业务正常行为**，脚本的错误率阈值只统计 5xx，4xx 请通过 checks 和状态码分布观察。

**身份管理**：脚本按 VU 维护完整会话生命周期——首轮自动建立登录态（`REGISTER_ON_START=true` 时注册新账号，否则用 `ACCOUNTS_FILE` 登录，未配置账号文件时注册兜底）；每个待核销预约与创建它的身份绑定，注册/登录导致身份切换后自动丢弃旧预约，避免跨身份操作返回 403；带登录态的请求若返回 401（token 失效/被踢），会自动重建会话并重试一次。

### 7. 常用调参

| 环境变量 | 作用 | 默认 |
| --- | --- | --- |
| `BASE_URL` | 目标地址 | `http://localhost:3000` |
| `PROFILE` | 场景 | `load` |
| `ACCOUNTS_FILE` | 用户测试账号（登录流程 + 登录态接口） | 无 |
| `FLOW_WEIGHTS` | 五流程权重 `"booking:30,register:10,login:15,checkin:20,member:25"` | 见左 |
| `REGISTER_ON_START` | 每个 VU 首轮注册新账号而非登录 | `false` |
| `REGISTER_PASSWORD` | 注册账号统一密码 | `Test123456` |
| `VUS` / `HOLD_MIN` | load 并发/保持分钟 | `50` / `3` |
| `SPIKE_VUS` | spike 峰值并发 | `300` |
| `SOAK_VUS` / `SOAK_MIN` | soak 并发/分钟 | `30` / `15` |
| `THINK_MS` | 模拟思考时间 | `800` |
| `P95` / `P99` | 延迟阈值(ms) | `500` / `1200`（soak 放宽） |
| `ERR_RATE` | 错误率阈值 | `0.01`（1%） |
| `ABORT_ON_FAIL` | 超阈值立即中止 | `false` |

### 8. 结果怎么看

重点看结束报告里的：

- `http_req_duration` 的 `p(90) / p(95) / p(99)`：延迟是否随并发升高而劣化；
- `http_req_failed`：错误率是否抬升，**失败集中在哪些接口**（注意区分 4xx 业务冲突与 5xx 服务异常）；
- 每个 URL 的独立耗时表：预约创建（写库+Redis 锁）通常比列表读慢，属正常；
- 爬坡曲线末端 RPS：就是当前配置下的吞吐上限。

想输出 JSON 便于归档：`k6 run --summary-export results.json loadtest/k6/load.js`。

---

## 二、Node 零依赖备用脚本

没有 k6 也没有 Docker 时，用项目自带的 Node 跑（**只覆盖公开接口**：健康检查、门店、活动、桌位可用性）：

```bash
node loadtest/stress.js --url http://<服务器IP>:3000 --concurrency 100 --duration 60
```

| 参数 | 作用 | 默认 |
| --- | --- | --- |
| `--url` | 目标地址 | `http://localhost:3000` |
| `-c, --concurrency` | 并发数 | `20` |
| `-d, --duration` | 时长（秒） | `60` |
| `--ramp` | 爬坡时间（秒） | `0` |
| `--think` | 请求间思考时间（ms） | `100` |
| `--token` | 附加 `Bearer` token | 无 |
| `--endpoints` | 自定义接口 `"路径:权重,..."` | 公开接口默认集 |
| `--timeout` | 单请求超时（ms） | `10000` |

只压特定接口：

```bash
node loadtest/stress.js --url http://<服务器IP>:3000 \
  --concurrency 200 --duration 120 \
  --endpoints "/api/appointments/availability?storeId=1&date=2026-08-12:60,/api/stores:40"
```

注意：Node 脚本是单进程异步模型，适合 100~300 并发量级的快速摸底；预约/核销/会员的登录态流程请用 k6。

---

## 三、压测时的服务器观测清单（找瓶颈）

压测过程中**同时**盯这些，比只看压测报告更能定位问题：

### 1. 机器层

```bash
docker stats --no-stream                 # 容器 CPU / 内存
uptime && vmstat 1 && free -h            # 负载 / CPU 队列 / 内存
top -b -n1 | head -30                    # 哪个进程吃满
```

### 2. MySQL

```bash
docker exec -it diy-mysql-prod mysql -uroot -p$DB_PASSWORD -e "SHOW PROCESSLIST;"
docker exec -it diy-mysql-prod mysql -uroot -p$DB_PASSWORD -e "SHOW GLOBAL STATUS LIKE 'Threads_running';"
docker logs diy-mysql-prod --since 1m | grep -i "slow\|deadlock"
```

重点看：并发连接数是否打满（`max_connections`）、大量 `Sleep`/`Locked` 线程、慢查询。预约表按 `(storeId, date)`、`(userId)`、`code` 的查询是否走了索引，核销状态更新是否出现行锁等待。

### 3. Redis

```bash
docker exec -it diy-redis-prod redis-cli info memory  # 内存是否告急
docker exec -it diy-redis-prod redis-cli slowlog get 20
docker exec -it diy-redis-prod redis-cli keys 'booking:*' | wc -l  # 活动预约的防超卖锁
```

活动预约下单有 Redis 防并发锁（`booking:activity:*`），并发抢同一场次时关注锁争用。

### 4. Node / 应用层

```bash
docker logs diy-server-prod --since 1m | tail -200      # 错误堆栈 / 慢请求日志
docker exec -it diy-server-prod sh -c "ps -o pid,rss,vsz,pcpu -p 1"
```

没有 APM 时可以临时抓一个 Node CPU 快照（`node --prof`）看热点，或对比请求各阶段耗时（网络 → Nest 处理 → DB → 响应）。

### 5. 网络 / 入口

如果前面有 nginx/网关，同时看连接数与带宽：`sar -n DEV 1`、`netstat -s`。

---

## 四、结合本项目代码，常见的优化点

压出瓶颈后对照排查（按经验排序）：

1. **预约创建**：走 `(storeId, date)` 查重 + 桌位冲突校验，压测时看 MySQL 是否出现锁等待或慢查询；高并发抢时段时确认 `appointments` 表有 `(storeId, date, status)` 联合索引。
2. **核销/下钟**：`checkin`、`clockout` 是高频写（状态流转 + `checkedInBy` 记录），压测时观察这两个接口延迟，若偏高检查单条 UPDATE 开销与行锁。
3. **活动防超卖**：`booking:activity:*` Redis 锁（10 秒 TTL）在 spike 场景下可能出现争用，观察 `slowlog` 与业务返回的冲突占比。
4. **会员下单**：`purchase` 只做 insert 生成待确认订单，压力不大；管理端确认/开通是低频写，但注意会员权益查询（`myMembership`/`wallet`）是否有不必要的关联查询。
5. **数据库连接池**：TypeORM 默认连接池不大，并发上来后可能成为瓶颈；MySQL `max_connections` 与连接池要匹配，多副本注意总量。
6. **Node 单进程**：`docker compose up --scale server=2` 已支持横向扩容。压测结果里如果 CPU 先打满而 DB/Redis 不忙，就是 Node 单实例上限，直接扩容。
7. **限流防刷**：登录失败锁定、验证码 IP 限流都在 Redis 里实现，Redis 单点故障会影响登录/鉴权；生产建议给 Redis 做持久化与监控（AOF 已在 compose 开启）。
