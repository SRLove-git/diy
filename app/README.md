# Think Origin · Flutter UI 预览

由 Pixso 设计稿（82 屏）通过 Pixso MCP `design_to_code` 生成的 Flutter/Dart 工程。

## 运行

```bash
flutter pub get
flutter run            # 选择设备（iOS / Android / Chrome）
flutter build web      # 构建 Web 版（build/web）
flutter test           # 冒烟测试
```

## 目录结构

| 目录 | 说明 |
|---|---|
| `lib/pages/` | 82 个屏幕页面（Frame_<节点id>.dart，16-Reels 为 Reels.dart） |
| `lib/custom_widget/` | 页面引用的自定义组件 |
| `lib/utils/` | 适配工具（pix_adapted_screen、pix_extensions、pix_base64_string 等） |
| `lib/variables/` | Pixso 变量管理（当前页面未直接使用） |
| `assets/` | 从设计稿重新导出的栅格图片（Tab 栏、卡片、渐变占位等） |
| `lib/main.dart` | 预览壳：82 屏宫格入口 + 440×956 画幅预览（59 为横屏 956×440） |
| `lib/screens_registry.dart` | 屏幕名 → 页面组件映射（自动生成） |

## 说明

- 页面为设计稿 1:1 还原（**iPhone 17 Pro Max 基准 440×956**，横屏页 956×440），含状态栏、底部 Tab、弹窗、动效规范等全部状态。
- 生成代码由 Pixso MCP 产出，`flutter analyze` 提示多为生成代码的命名/风格 lint，不影响运行；如需要可加 `// ignore_for_file: camel_case_types, non_constant_identifier_names`。
- 图片资源分两类：`assets/`（重新导出的 PNG）与 `pix_base64_string.dart`（内嵌 base64，按节点 id 合并）。
