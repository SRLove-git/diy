"""Spec pages: design tokens, key states, motion notes."""
from design_tokens import (
    LIGHT, DARK, ACCENT, SUCCESS, WARNING, GRADIENT,
    FONT_ZH, FONT_EN,
    solid, linear_gradient, shadow, text_width,
)
from builder import Op, ICONS


def _swatch(o, parent, x, y, w, h, fill, name):
    o.rect(parent, x, y, w, h, fill, corner=8, name=name)


def _label(o, parent, x, y, s, size=12, color="#737373", weight=500, name="lbl"):
    o.text(parent, x, y, s, size, solid(color), name=name, weight=weight)


def tokens_page(x, y):
    o = Op()
    root = o.frame("document", x, y, 820, 1080, fill="#FAFAFA",
                   name="设计 Token 页")
    o.text(root, 40, 36, "IDOL BEADS 设计 Token", 28, solid("#111111"),
           name="title", weight=700, family=FONT_EN, letter_spacing=0.5)
    o.text(root, 40, 76, "Design Tokens · 可直接落地为 Flutter Theme", 14,
           solid("#737373"), name="subtitle", weight=500)
    o.line(root, 40, 104, 780, 104, solid("#E5E5E5"), weight=1, name="hr0")

    # 1. brand gradient
    o.text(root, 40, 124, "品牌渐变 Brand Gradient", 16, solid("#111111"),
           name="s1-title", weight=700)
    gw = 720
    stops = [(0, GRADIENT[0]), (0.25, GRADIENT[1]), (0.5, GRADIENT[2]),
             (0.75, GRADIENT[3]), (1, GRADIENT[4])]
    seg = 144
    for i, (pos, h) in enumerate(stops):
        _swatch(o, root, 40 + i * seg, 152, seg + 1, 44,
                solid(h), f"g-{i}")
    for i, h in enumerate(GRADIENT):
        _label(o, root, 40 + i * seg, 206, h, 11, "#A8A8A8", 600, f"g-{i}-t")

    # 2. light palette
    o.text(root, 40, 240, "亮色模式 Light", 16, solid("#111111"), name="s2-title",
           weight=700)
    light_items = [
        ("bg", LIGHT["bg"]), ("surface", LIGHT["surface"]), ("text1", LIGHT["text1"]),
        ("text2", LIGHT["text2"]), ("text3", LIGHT["text3"]), ("divider", LIGHT["divider"]),
        ("search", LIGHT["search"]), ("accent", ACCENT), ("success", SUCCESS),
        ("warning", WARNING),
    ]
    for i, (name, h) in enumerate(light_items):
        cx = 40 + (i % 5) * 150
        cy = 268 + (i // 5) * 74
        _swatch(o, root, cx, cy, 44, 44, solid(h), f"lw-{name}")
        _label(o, root, cx + 52, cy + 4, name, 12, "#111111", 600, f"lw-{name}-n")
        _label(o, root, cx + 52, cy + 24, h, 11, "#A8A8A8", 500, f"lw-{name}-h")

    # 3. dark palette
    o.text(root, 40, 428, "暗色模式 Dark", 16, solid("#111111"), name="s3-title",
           weight=700)
    dark_items = [
        ("bg", DARK["bg"]), ("surface", DARK["surface"]), ("text1", DARK["text1"]),
        ("text2", DARK["text2"]), ("text3", DARK["text3"]), ("divider", DARK["divider"]),
        ("search", DARK["search"]), ("bubble_in", DARK["bubble_in"]),
    ]
    for i, (name, h) in enumerate(dark_items):
        cx = 40 + (i % 5) * 150
        cy = 456 + (i // 5) * 74
        _swatch(o, root, cx, cy, 44, 44, solid(h), f"dk-{name}")
        _label(o, root, cx + 52, cy + 4, name, 12, "#111111", 600, f"dk-{name}-n")
        _label(o, root, cx + 52, cy + 24, h, 11, "#A8A8A8", 500, f"dk-{name}-h")

    # 4. type scale
    o.text(root, 40, 620, "字号层级 Type Scale", 16, solid("#111111"),
           name="s4-title", weight=700)
    type_items = [
        ("H1 大标题", 24, 700, "IDOL BEADS 社区"),
        ("H2 模块标题", 20, 600, "发现新鲜手作"),
        ("Body 正文", 17, 400, "拼豆新手的第一件作品"),
        ("Secondary 次要", 15, 400, "@小豆手作 · 3 小时前"),
        ("Caption 辅助", 13, 400, "#教程 #日常 #活动"),
        ("Tiny 微标", 11, 600, "未读 12 · 置顶 · LV5"),
    ]
    for i, (name, size, wgt, sample) in enumerate(type_items):
        yy = 646 + i * 40
        _label(o, root, 40, yy + (size / 2 - 7), name, 11, "#A8A8A8", 600, f"ty-{i}-n")
        o.text(root, 180, yy, sample, size, solid("#111111"), name=f"ty-{i}-s",
               weight=wgt)

    # 5. radius + spacing
    o.text(root, 40, 904, "圆角 / 间距 Radius & Spacing", 16, solid("#111111"),
           name="s5-title", weight=700)
    for i, (r, label) in enumerate([(20, "弹窗 20"), (16, "卡片 16"), (12, "按钮 12"),
                                    (10, "胶囊 10")]):
        o.rect(root, 40 + i * 170, 932, 64, 64, solid("#EDEDED"), corner=r,
               name=f"r-{i}")
        _label(o, root, 40 + i * 170, 1004, label, 11, "#737373", 600, f"r-{i}-t")
    o.line(root, 40, 1048, 780, 1048, solid("#E5E5E5"), weight=1, name="hr1")
    return [{"ops": o.ops}]


def states_page(x, y):
    o = Op()
    root = o.frame("document", x, y, 390, 844, fill="#FFFFFF",
                   name="关键状态 · 亮")
    o.text(root, 16, 40, "社区关键状态", 18, solid("#111111"), name="title",
           weight=700)
    # ---- skeleton ----
    o.text(root, 16, 80, "加载骨架屏", 13, solid("#737373"), name="sk-title",
           weight=600)
    for i in range(3):
        sy = 104 + i * 76
        o.ellipse(root, 38, sy + 16, 16, solid("#EEEEEE"), name=f"sk-av{i}")
        o.rect(root, 64, sy, 120, 14, solid("#EEEEEE"), corner=7, name=f"sk-l1{i}")
        o.rect(root, 64, sy + 22, 200, 12, solid("#F3F3F3"), corner=6, name=f"sk-l2{i}")
        o.rect(root, 16, sy + 44, 358, 18, solid("#F0F0F0"), corner=9, name=f"sk-b{i}")
    # ---- empty ----
    o.text(root, 16, 340, "空状态", 13, solid("#737373"), name="em-title", weight=600)
    o.rect(root, 143, 372, 104, 104, solid("#F5F5F5"), corner=32, name="em-bg")
    o.path(root, 143 + 40, 372 + 40, 24, ICONS["grid"], solid("#A8A8A8"),
           name="em-ic")
    o.text(root, 195 - text_width("还没有作品，来发布第一个吧", 14) / 2, 492,
           "还没有作品，来发布第一个吧", 14, solid("#737373"), name="em-t")
    o.frame(root, 130, 524, 130, 38,
            fill=linear_gradient([(0, "#D62976"), (1, "#962FBF")], 0),
            corner=19, name="em-btn")
    o.text(root, 195 - text_width("去发布", 14, 600) / 2, 535, "去发布", 14,
           solid("#FFFFFF"), name="em-btn-t", weight=600)
    # ---- error ----
    o.text(root, 16, 600, "错误状态", 13, solid("#737373"), name="er-title", weight=600)
    o.rect(root, 143, 630, 104, 104, solid("#FFF0F3"), corner=32, name="er-bg")
    o.path(root, 143 + 40, 630 + 40, 24, ICONS["refresh"], solid("#ED4956"),
           name="er-ic")
    o.text(root, 195 - text_width("加载失败，请重试", 14) / 2, 750,
           "加载失败，请重试", 14, solid("#111111"), name="er-t")
    o.frame(root, 137, 780, 116, 38, fill="#FFFFFF",
            stroke=solid("#DBDBDB"), stroke_w=1, corner=19, name="er-btn")
    o.text(root, 195 - text_width("重试", 14, 500) / 2, 791, "重试", 14,
           solid("#111111"), name="er-btn-t", weight=500)
    return [{"ops": o.ops}]


def motion_notes_page(x, y):
    o = Op()
    root = o.frame("document", x, y, 820, 1080, fill="#FFFFFF",
                   name="交互与动效说明")
    o.text(root, 40, 36, "交互与动效说明", 26, solid("#111111"), name="title",
           weight=700)
    o.text(root, 40, 74, "Motion & Platform Spec", 13, solid("#737373"),
           name="sub", weight=500, family=FONT_EN)
    o.line(root, 40, 100, 780, 100, solid("#E5E5E5"), weight=1, name="hr0")

    sections = [
        ("通用动效原则", [
            "时长 200–300ms，ease-out 缓出，柔和真实，参照真人动作节奏",
            "点赞：爱心弹跳 420ms（scale 1→1.4→1，elasticOut）",
            "图片加载：渐显 220ms；列表进入：错峰上滑 240ms",
            "失败重试：按钮按压 scale 0.97 + 成功回弹",
        ]),
        ("社区", [
            "Tab 切换：下划线滑动 200ms easeInOut；胶囊点击水波纹",
            "信息流卡片入场：上移 12px + 渐显 240ms",
            "点赞前后：图标变品牌渐变 + 数字弹跳；评论数 +1 缩放",
        ]),
        ("Reels", [
            "PageView 上下滑动切换：300ms cubic-bezier(.32,.72,.35,1)",
            "双击点赞：爱心从点击点放大淡出，旋转唱片常驻 3.6s/圈",
            "文案入场：底部上移 16px + 渐显 260ms",
        ]),
        ("聊天", [
            "消息气泡入场：scale 0.96→1 + 渐显 200ms",
            "未读徽章：数字 +1 缩放弹跳；发送失败红色提示 240ms",
            "语音播放：进度条匀速推进；图片查看共享元素动画 260ms",
        ]),
        ("个人主页", [
            "关注前后：渐变实心 → 置灰描边，200ms",
            "内容 Tab：图标下划线滑动 + 宫格淡入 220ms",
            "头像 Story 环：点击放大进入 Story，280ms",
        ]),
        ("双端差异", [
            "iOS：严格 HIG —— 原生导航栏与返回手势、Safe Area、触控目标 ≥44pt、系统字体缩放",
            "Android：Material 3 定制 —— 返回键、长按菜单、水波纹反馈；保留悬浮玻璃拟态底部导航与 squircle",
            "双端一致：底部 5 栏（主页 / Reels / 社区 / 消息 / 我的），顺序固定",
            "正文对比度 ≥ 4.5:1；深色模式跟随系统；品牌渐变仅作点缀，禁止大面积高饱和色块",
        ]),
    ]
    yy = 126
    for title, lines in sections:
        o.text(root, 40, yy, title, 16, solid("#111111"), name=f"sec-{title}",
               weight=700)
        yy += 30
        for ln in lines:
            o.text(root, 40, yy, "· " + ln, 13, solid("#444444"), name=f"ln-{yy}")
            yy += 24
        yy += 14
    return [{"ops": o.ops}]

