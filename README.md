# DIY 手作工坊平台 · 一期工程

> 14 天双端交付（iOS / Android）｜排期见 [schedule.md](./schedule.md)

## 技术栈

| 层 | 选型 |
| --- | --- |
| 客户端 | Flutter（`mobile/`，一套代码产出 iOS / Android） |
| 后端 | NestJS（`server/`，RESTful API） |
| 数据库 | MySQL 8（持久化） |
| 缓存/会话 | Redis 7 |
| 管理后台 | Vue 3 + TypeScript（`admin/`，Vite） |
| 部署 | Docker，开发 / 测试 / 生产三套 compose |

## 目录结构

```
diy/
├── schedule.md          # 14 天排期
├── 客户要求.md            # 一期需求
├── 第一阶段UI设计指导.md    # UI 规范
├── mobile/              # Flutter 客户端（待初始化）
├── server/              # NestJS 后端（/api 前缀，端口 3000）
├── admin/               # Vue3 管理后台（Vite，dev 代理 /api）
└── docker/
    ├── compose.dev.yml   # 开发：仅 MySQL + Redis 容器化
    ├── compose.test.yml  # 测试：独立实例（13306 / 16379）
    └── compose.prod.yml  # 生产：全链路容器化
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
cd mobile && flutter run
```

健康检查：`curl http://localhost:3000/api/health` → `{ status: "ok", db: "up", redis: "up" }`

## 生产部署

```bash
docker compose -f docker/compose.prod.yml up -d --build
# 管理后台 http://<host>:8080 ｜ 后端 http://<host>:3000/api
# 生产密码/密钥通过环境变量注入：DB_PASSWORD / JWT_SECRET
```

## 环境要求

- Flutter SDK（macOS 首次需同意 Xcode license：`sudo xcodebuild -license accept`）
- Node.js ≥ 20（建议 22 LTS）
- Docker（含 docker compose v2）
- 本机 MySQL / Redis 可选（开发环境建议直接用 docker 实例）
