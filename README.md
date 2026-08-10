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
└── .github/workflows/ci.yml  # CI：server lint/build/test/e2e + admin build + flutter analyze/test
```

## 快速启动（开发）

```bash
# 1. 基础设施（MySQL + Redis）
docker compose -f docker/compose.dev.yml up -d

# 2. 后端（http://localhost:3000/api）
cd server
cp .env.example .env   # 首次
npm run start:dev

# 3. 管理后台（http://localhost:5173，/api 自动代理到 3000）
cd admin
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

## 生产环境变量

除 `DB_PASSWORD / JWT_SECRET / JWT_REFRESH_SECRET` 外，生产部署还支持：

| 变量 | 说明 |
| --- | --- |
| `SMTP_HOST/PORT/USER/PASS/FROM` | 邮件发送（验证码）。**生产必须配置**，未配置时验证码只打印在服务端日志 |
| `CORS_ORIGINS` | 跨域白名单（逗号分隔）；生产未配置默认禁止跨域（原生 App 不受影响） |
| `CONTENT_KEYWORDS` | 内容机审默认关键词（逗号分隔），管理端 `/api/admin/moderation/keywords` 可运行时增删 |
| `UPLOAD_PROVIDER=s3` | 对象存储（AWS S3 / MinIO / OSS / COS），需配 `S3_BUCKET/S3_ACCESS_KEY/S3_SECRET_KEY` 等；默认 `local` 本地磁盘 |
| `DB_MIGRATIONS_RUN` | 启动时自动执行数据库迁移（生产默认 true） |

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

## 环境要求

- Flutter SDK（macOS 首次需同意 Xcode license：`sudo xcodebuild -license accept`）
- Node.js ≥ 20（建议 22 LTS）
- Docker（含 docker compose v2）
- 本机 MySQL / Redis 可选（开发环境建议直接用 docker 实例）
