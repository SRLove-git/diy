# 手作星球 · 新版客户端（Flutter）

由 Pixso 82 屏设计稿生成的新版 UI App，已接入后端 `server/`（NestJS，`/api` 前缀）。
旧版 `mobile/` 中的客户端 API 层已整体移植到本工程的 `lib/core/`，入口已从「设计稿预览壳」
改为真实客户端：登录 → 底部五 Tab（首页 / Reels / 社区 / 消息 / 我的）。

## 运行

```bash
flutter pub get
cp .env.example .env   # 首次，配置 API_BASE_URL
flutter run            # iOS / Android
flutter test           # 冒烟测试
```

## API 地址配置（`.env`）

```env
API_BASE_URL=http://localhost:3000/api
```

读取顺序：`.env` → `--dart-define=API_BASE_URL=...` → 默认 `http://localhost:3000/api`。
编辑 `.env` 后热重启生效。真机调试时把地址改成电脑局域网 IP。

## 目录结构

| 目录 | 说明 |
|---|---|
| `lib/core/` | 从旧版 `mobile/` 移植的完整 API 层：`api_client`（dio）、`auth_service`（登录/token 刷新）、`post_api` / `video_api` / `chat_api` / `chat_service`（WebSocket 实时聊天）/ `appointment_api` / `follow_api` / `notification_api` / `music_api` 等 |
| `lib/features/` | 社区 / 会员领域模型与数据仓库（API 实现） |
| `lib/screens/` | 真实功能页：登录、主框架（五 Tab）、首页、Reels、社区、消息、个人主页、作品详情 |
| `lib/pages/` + `lib/custom_widget/` | Pixso 生成的 82 屏静态设计稿（开发预览用，见「我的 → 设计稿预览」） |
| `lib/screens/dev/gallery_page.dart` | 82 屏设计稿预览入口 |
| `lib/utils/`、`lib/variables/` | Pixso 适配工具与变量 |

## 已对接后端的功能

- 验证码 / 密码登录、token 自动刷新、登出
- 首页：活动专区、附近门店、最新作品信息流
- 社区：发现 / 关注、频道筛选（推荐/最新/热门/教程/日常/活动）、作品卡片、点赞、作品详情与评论
- Reels：短视频推荐流（video_player 播放、点赞、浏览记录上报）
- 消息：会话列表（WebSocket 实时更新、未读角标、在线状态）、按手机号发起会话、单聊收发文本
- 我的：个人资料、作品/收藏/喜欢统计、我的作品网格

## 待接入（后续迭代）

- 发布作品 / 发布视频（图片与视频选择、上传、配乐）
- 预约流程（门店详情 → 选桌位 → 确认 → 核销）、会员开通、卡包优惠券
- 群聊、黑名单、通知列表、设置与编辑资料
- 将更多 82 屏设计稿逐步替换为功能页
