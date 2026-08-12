# Think Origin 手作工坊平台 · 一期工程

> 14 天双端交付（iOS / Android）｜排期见 [schedule.md](./schedule.md)

## 技术栈

| 层 | 选型 |
| --- | --- |
| 客户端 | Flutter（`app/`，一套代码产出 iOS / Android / Web） |
| 后端 | NestJS（`server/`，RESTful API） |
| 数据库 | MySQL 8（持久化） |
| 缓存/会话 | Redis 7 |
| 管理后台 | Vue 3 + TypeScript（`admin/`，Vite） |
| 部署 | Docker，开发 / 测试 / 生产三套 compose |

## 目录结构

```
diy/
├── schedule.md          # 14 天排期
├── app/                 # Flutter 客户端（go_router 声明式路由 + REST/WS 接入）
├── server/              # NestJS 后端（/api 前缀，端口 3000）
├── admin/               # Vue3 管理后台（Vite，dev 代理 /api）
├── ui-design/           # UI 设计规范与设计稿导出源
├── docker/
│   ├── compose.dev.yml   # 开发：仅 MySQL + Redis 容器化
│   ├── compose.test.yml  # 测试：独立实例（13306 / 16379）
│   └── compose.prod.yml  # 生产：全链路容器化
│   ├── backup/           # 每日备份服务（cron：MySQL dump + Redis 快照）
│   └── backups/          # 备份产物目录（不入库）
└── .github/workflows/ci.yml  # CI：server lint/build/test/e2e + admin build + flutter analyze/test
```

## 快速启动（开发）

```bash
# 1. 基础设施（MySQL + Redis）
docker compose -f docker/compose.dev.yml up -d

# 2. 后端（http://localhost:3000/api）
cd server
cp .env.example .env   # 首次
npm install             # 首次
npm run start:dev

# 3. 管理后台（http://localhost:5173，/api 自动代理到 3000）
cd admin
npm install             # 首次（jsqr 等依赖必须在此目录安装）
npm run dev

# 4. 客户端（需先同意 Xcode license，见下）
cd app && flutter run
```

健康检查：`curl http://localhost:3000/api/health` → `{ status: "ok", db: "up", redis: "up" }`

## 数据库 Schema 与迁移

生产环境的表结构由 TypeORM 迁移管理（`server/src/migrations/`），不再依赖
`synchronize` 自动建表：

```bash
cd server
npm run migration:generate -- src/migrations/MyChange   # 生成迁移（需连库）
npm run migration:run                                   # 执行迁移
npm run migration:revert                                # 回滚最近一次迁移
```

- 开发环境仍用 `synchronize` 自动建表，方便迭代；
- 生产环境在 compose 中默认 `DB_MIGRATIONS_RUN=true`，应用启动时自动执行未跑过的迁移（含首次建表）。
- 生产 compose 默认 3 个 server 副本（`deploy.replicas: 3`），多副本同时启动时迁移并发安全：
  bootstrap 通过 MySQL 命名锁（`diy_migrations`）串行化执行，
  先启动的副本跑完迁移，其余副本等待后自动跳过。

## 生产环境变量

除 `DB_PASSWORD / JWT_SECRET / JWT_REFRESH_SECRET` 外，生产部署还支持：

| 变量 | 说明 |
| --- | --- |
| `JWT_LEGACY_SECRETS` | JWT 无缝轮换：逗号分隔的历史密钥（仅验签）。轮换时先填旧密钥再换 `JWT_SECRET / JWT_REFRESH_SECRET`，已登录用户不掉线；旧令牌过期后清空 |
| `SMTP_HOST/PORT/USER/PASS/FROM` | 邮件发送（验证码）。**生产必须配置**，未配置时验证码只打印在服务端日志 |
| `CORS_ORIGINS` | 跨域白名单（逗号分隔）；生产未配置默认禁止跨域（原生 App 不受影响） |
| `CONTENT_KEYWORDS` | 内容机审默认关键词（逗号分隔），管理端 `/api/admin/moderation/keywords` 可运行时增删 |
| `UPLOAD_PROVIDER=s3` | 对象存储（阿里云 OSS 等 S3 兼容服务），需配 `S3_BUCKET/S3_ACCESS_KEY/S3_SECRET_KEY` 等；默认 `local` 本地磁盘 |
| `S3_PUBLIC_URL_BASE` | 对象存储对外访问域名/CDN（如 `https://cdn.example.com`），未配置时回退 bucket 默认域名 |
| `CDN_PROVIDER` | CDN 缓存刷新：`none`（默认，不刷新）/ `aliyun`；删除或替换媒体后自动 purge |
| `ALIYUN_CDN_ACCESS_KEY_ID/SECRET` | `CDN_PROVIDER=aliyun` 时的阿里云 CDN 密钥（RAM 子账号最小授权：`RefreshObjectCaches`） |
| `DB_MIGRATIONS_RUN` | 启动时自动执行数据库迁移（生产默认 true） |
| `DB_POOL_SIZE` | MySQL 连接池大小（默认 20，按服务器内存与并发调整，需 ≤ MySQL max_connections） |
| `TRUST_PROXY` | nginx 反代后置 true，让 `req.ip` 取真实客户端 IP（验证码/登录防刷按 IP 限流依赖它） |
| `THROTTLE_LIMIT/TTL_MS/BLOCK_MS` | API 全局限流：每 IP 每分钟请求数（默认 300）、窗口（默认 60s）、超限封锁时长（默认 300s） |
| `AUTH_THROTTLE_LIMIT` | 认证接口限流上限（默认 10 次/分钟，注册/登录路由再收紧到 5 次/分钟） |
| `BLOCK_BOT_UA` | 置 `true` 启用爬虫 UA 拦截（注册/登录/上传接口拒绝 python-requests、curl、Scrapy 等已知脚本 UA） |
| `CAPTCHA_PROVIDER` | 人机验证：`turnstile`（Cloudflare）或 `hcaptcha`；留空关闭。开启后注册/登录需携带 `captchaToken` |
| `TURNSTILE_SECRET / HCAPTCHA_SECRET` | 对应人机验证提供商的站点密钥 |
| `REGISTER_IP_MAX / REGISTER_IP_WINDOW_H` | 同一 IP 在窗口内（默认 24h）最大注册数（默认 5） |

### 基础设施配置调优

MySQL / Redis / Nginx 的优化参数集中维护在 `docker/` 下，生产与开发分开，避免命令行参数散落在 compose 里：

| 文件 | 用途 |
| --- | --- |
| `docker/mysql/my.cnf` | MySQL 生产配置：连接池 500、InnoDB 缓冲池、慢查询、utf8mb4 等 |
| `docker/mysql/my-dev.cnf` | MySQL 开发配置（轻量：连接池 200、缓冲池 256M） |
| `docker/redis/redis.conf` | Redis 生产/开发通用：AOF + RDB 持久化、volatile-lru 淘汰、惰性删除、碎片整理 |
| `docker/nginx/nginx.conf` | 生产负载均衡（nginx-lb）：gzip、反代头、WebSocket 升级、超时 |
| `admin/nginx.conf` | 管理后台静态托管：SPA 不缓存 + 哈希资源长缓存、gzip、/api 反代 |
| `docker/backup/` | 每日备份服务：cron 定时 MySQL dump + Redis RDB 快照，产物在 `/data/diy-backups/` |

按部署机内存调整的关键参数（改完需重建容器生效）：

```bash
# MySQL innodb_buffer_pool_size 建议物理内存 1/4 ~ 1/2；Redis maxmemory 同理
# 改完重建（配置只在容器启动时加载）：
docker compose -f docker/compose.prod.yml up -d --force-recreate mysql redis
```

扩容 server 副本时，保持 `副本数 × DB_POOL_SIZE ≤ max_connections`（my.cnf 默认 500）。

### 数据库备份与恢复

生产 compose 自带 `backup` 服务：容器内 cron（默认每日 03:00，时区 Asia/Shanghai）执行 MySQL
`mysqldump` + Redis `--rdb` 快照，gzip 压缩后写入宿主机 `/data/diy-backups/`（与数据卷分离，
卷损坏不影响备份），默认保留 7 天。容器启动时会先备份一次，健康检查要求最近 48h 内有成功备份：

```bash
# 手动立即备份
docker compose -f docker/compose.prod.yml exec backup /backup.sh
ls -lh /data/diy-backups/
```

**首次启用备份**：备份使用独立低权限账号（不用 root），需在 MySQL 里创建一次，并把密码写入
`docker/.env`（`BACKUP_DB_PASSWORD`，可用 `openssl rand -hex 16` 生成）：

```sql
CREATE USER 'backup'@'%' IDENTIFIED WITH mysql_native_password BY '换成随机密码';
GRANT SELECT, SHOW VIEW, TRIGGER, EVENT, LOCK TABLES, PROCESS ON *.* TO 'backup'@'%';
FLUSH PRIVILEGES;
```

调整保留天数与执行时间（`docker/.env`）：

```bash
BACKUP_RETENTION_DAYS=14      # 保留 14 天
BACKUP_CRON=0 2 * * *         # 每日凌晨 2 点
```

**恢复 MySQL**（备份文件取 `/data/diy-backups/` 下最新的 `mysql-*.sql.gz`）：

```bash
gunzip -c /data/diy-backups/mysql-<时间戳>.sql.gz | \
  docker compose -f docker/compose.prod.yml exec -T mysql sh -c \
  'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" diy'
```

**恢复 Redis**（先停 redis，替换 RDB 并移开 AOF 让启动时加载快照；
卷名以 `docker volume ls` 实际为准，本仓库默认 `docker_redis-prod-data`）：

```bash
docker compose -f docker/compose.prod.yml stop redis
docker run --rm \
  -v docker_redis-prod-data:/data \
  -v "/data/diy-backups:/backups:ro" \
  redis:7-alpine sh -c \
  'gunzip -c /backups/redis-<时间戳>.rdb.gz > /data/dump.rdb && \
   mv /data/appendonly.aof /data/appendonly.aof.old 2>/dev/null || true'
docker compose -f docker/compose.prod.yml start redis
```

### 多副本扩容

生产 compose 内置 `nginx-lb` 负载均衡入口（外部 3000 端口 → server 各副本，含 `/api`、`/ws` WebSocket、上传与静态资源），且 server 默认 3 个副本（`deploy.replicas: 3`），直接 `up -d` 即可。需要临时调整副本数时保持单个 `nginx-lb` 不变，只增减 server 副本：

```bash
docker compose -f docker/compose.prod.yml up -d --build --scale server=3
```

注意：副本数 × `DB_POOL_SIZE` 需 ≤ MySQL `max_connections`（compose 已默认放大到 500，生产 .env 已配 3×50=150）；聊天跨实例转发由 Redis pub/sub 承载，扩副本无需改代码。

### 本地构建部署（服务器不构建）

服务器性能弱或不想在服务器上装构建工具链时，可以在本地（Mac）构建镜像再传过去。脚本支持同架构与 Apple Silicon 交叉构建 `linux/amd64`：

```bash
# 服务器是 x86_64（最常见）
./docker/deploy-local.sh amd64
# 服务器是 arm64
./docker/deploy-local.sh arm64
```

脚本会在 `docker/` 下生成 `images-<tag>.tar.gz`，并打印 scp 传输与服务器 `docker load` + `up --no-build` 命令。服务器只需安装 Docker，不需要 Node/npm。

## CI

`.github/workflows/ci.yml` 在 push/PR 到 `main` 时自动运行：

- server：eslint + build + 单测 + e2e（GitHub Actions 内起 MySQL/Redis 服务容器）
- admin：Vite 构建
- app：Flutter analyze + test

## 生产部署

```bash
docker compose -f docker/compose.prod.yml up -d --build
# 管理后台 http://<host>:8080 ｜ 后端 http://<host>:3000/api
# 生产密码/密钥通过环境变量注入：DB_PASSWORD / JWT_SECRET / JWT_REFRESH_SECRET
# 首次部署需在 docker/.env 设 DB_SYNC=true 自动建表，建表完成后改回 false 并重启
```

### 密钥与数据库密码轮换

- **JWT 轮换（不影响已登录用户）**：先把旧 `JWT_SECRET` / `JWT_REFRESH_SECRET` 追加到
  `docker/.env` 的 `JWT_LEGACY_SECRETS`（逗号分隔），再更新 `JWT_SECRET` / `JWT_REFRESH_SECRET`
  并重启 server。旧 access token（默认 2h）与 refresh token（30 天）在有效期内继续可验证，
  全部过期后可清空 `JWT_LEGACY_SECRETS`。不要直接替换密钥，否则所有已登录用户立即掉线。

- **MySQL 密码轮换**：数据卷初始化后 `MYSQL_ROOT_PASSWORD` 不再生效，只改 `docker/.env` 的
  `DB_PASSWORD` 会导致应用连不上库、健康检查失败。必须用脚本在容器内改密并同步 .env：

```bash
./docker/rotate-db-password.sh            # 自动生成随机密码
./docker/rotate-db-password.sh NewPass123 # 指定新密码
```

  脚本流程：`ALTER USER`（root@% / root@localhost）→ 备份并更新 `docker/.env` → 重建
  mysql/server 容器。备份账号 `BACKUP_DB_PASSWORD` 是独立低权限账号，不受影响。

版本升级与数据安全 SOP（升级前备份、迁移、回滚、红线事项）见 [version-update.md](./version-update.md)。

## 环境要求

- Flutter SDK（macOS 首次需同意 Xcode license：`sudo xcodebuild -license accept`）
- Node.js ≥ 20（建议 22 LTS）
- Docker（含 docker compose v2）
- 本机 MySQL / Redis 可选（开发环境建议直接用 docker 实例）
