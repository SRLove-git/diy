# Think Origin · Flutter 客户端

Think Origin 手作工坊平台的移动端（iOS / Android / Web），使用 go_router
声明式路由，通过 REST API + WebSocket 与 `server/` 交互。

## 运行

```bash
flutter pub get
flutter run            # 选择设备（iOS / Android / Chrome）
flutter test           # 冒烟测试
flutter analyze        # 静态分析（应保持 0 issues）
```

后端地址默认按平台取本地地址（Android 模拟器 `10.0.2.2:3000`，其余
`localhost:3000`），可通过编译期参数覆盖：

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com
flutter build ios --release --dart-define=API_BASE_URL=https://api.example.com
```

## 目录结构

| 目录 | 说明 |
|---|---|
| `lib/main.dart` | 入口：恢复登录态并启动实时推送 |
| `lib/interactive/` | App 壳（`PrototypeApp`：MaterialApp.router + 主题） |
| `lib/live/` | go_router 路由、主题与全部业务页面 |
| `lib/live/screens/` | 页面（聊天/短视频/社区/门店/预约/会员/个人中心等） |
| `lib/api/` | HTTP 客户端（401 自动刷新重试）、各业务 service、模型、登录态、WS 实时消息 |
| `assets/` | App 图标等静态资源 |
| `test/` | 冒烟测试与模型解析测试 |

聊天页面单文件曾达 4700+ 行，已按功能拆分为 `chat_screens.dart`（library）+ 4 个
`part` 文件：会话列表、单聊、群聊管理、添加好友/聊天信息/拉黑。

## 已实现的已知取舍

- 界面禁用系统字体缩放（`MediaQuery.withClampedTextScaling`），保证设计稿布局不溢出，
  代价是无障碍字体放大不生效，后续如需支持可改为约束上限而非固定 1.0。
- 登录态存本地（shared_preferences），聊天 WS 以 URL query 携带 token，
  便于 Web/移动端统一实现；访问日志中可能记录 token，如需更严格可改为握手头。
