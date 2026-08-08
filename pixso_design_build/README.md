# IDOL BEADS 四页面 UI 重构（Pixso MCP 设计稿）

基于《四页面UI重构设计Prompt.md》与 Flutter 项目代码，在 Pixso（通过 Pixso MCP）中从零完成
**社区 / Reels / 聊天 / 个人主页** 四个页面的高保真 UI 设计，每个页面含亮色与暗色两套方案，
并附设计 Token 页、关键状态页与动效说明页。

## 画布布局（Pixso 页面 1）

| 行 | 画布坐标 | 内容 |
|---|---|---|
| Row 1 (y=0) | x=0 / 430 / 860 / 1290 | 社区·亮 / 社区·暗 / Reels·亮 / Reels·暗 |
| Row 2 (y=900) | x=0 / 430 / 860 / 1290 | 会话列表·亮 / 会话列表·暗 / 单聊·亮 / 单聊·暗 |
| Row 3 (y=1800) | x=0 / 430 / 860 / 1290 | 群聊·亮 / 我的主页·亮 / 我的主页·暗 / 他人主页·亮 |
| Row 4 (y=2700) | x=0 / 430 / 1290 / 1600 | 他人主页·暗 / 设计 Token 页 / 关键状态·亮 / 交互与动效说明 |

## 设计要点（对应 Prompt.md）

- **品牌视觉**：Instagram 五色渐变（#FEDA75→#FA7E1E→#D62976→#962FBF→#4F5BD5）仅用于
  点赞、发布、Story 环、Reels 选中态等品牌高光节点；界面以黑白灰中性色为主。
- **squircle 圆角**：卡片 16 / 按钮 12 / 胶囊 10 / 弹窗 20，头像统一圆角方形 + Story 渐变环。
- **字体**：中文 Noto Sans SC（Pixso 中 Instagram Sans 的回退），英文 Inter；
  字号层级 24 / 20 / 17 / 15 / 13 / 11。
- **底部 5 栏**：主页 / Reels / 社区 / 消息 / 我的，悬浮玻璃拟态胶囊，选中态品牌渐变或近黑实心。
- **关键状态**：社区页覆盖骨架屏、空态（引导发布）、错误态（重试）。
- **单聊**：覆盖引用、语音、图片消息与「发送失败，点击重试」状态；未读徽章用品牌渐变粉。
- **他人主页**：私信（白底描边）+ 关注（品牌渐变实心）双主操作；LV5 金色标签、地区/IP、签名。

## Pixso 内已建立的 Token 资源

- 本地样式（write_styles）：`Color/Text Secondary`、`Color/Accent IG Red`、`Color/Success`、
  `Color/Warning`、`Color/Dark Surface`、`Color/Search BG` 及 H1/Body/Caption 文本样式。
- 变量集（write_variables）：`IDOL BEADS Light`（bg、textPrimary、accent、success）。

## 验证方式

- 每个屏幕节点均通过 `query_nodes` / `get_node_dsl` 校验：图层坐标、填充、渐变 stops、
  字体与文本内容正确写入。
- 每个屏幕截图（`previews/*.png`）经像素级抽查：背景、品牌渐变、文字、图标、底部导航均渲染。
- 生成总览图 `previews/overview.png`。

## 重建

```bash
python3 main.py            # 生成 batches/
python3 run.py             # 写入 Pixso 画布（需 Pixso 桌面端 MCP 运行）
python3 screenshot.py      # 导出各屏幕截图到 previews/
```
