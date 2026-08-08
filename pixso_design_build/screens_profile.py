"""Profile (个人主页) screens — mine / others, light & dark."""
from design_tokens import (
    LIGHT, DARK, ACCENT, GRADIENT,
    FONT_ZH, FONT_EN,
    solid, linear_gradient, shadow, text_width,
)
from builder import Op, ICONS, status_bar, bottom_nav, avatar_squircle

AVATARS = [
    ("#FF6A88", "#FF9A5A"),
    ("#7A5CFF", "#4E9BFF"),
    ("#43D3A4", "#34B3F1"),
]
MEDIA = [
    ("#FFD9E2", "#B8A7FF"),
    ("#FFE3C8", "#FFB39B"),
    ("#C8F0E3", "#8FD3F4"),
    ("#E4D5FF", "#9F8CFF"),
    ("#FFD1D8", "#FF8A9B"),
    ("#FFF3C4", "#FFC46B"),
]


def _stats(o, parent, y, theme, items, name="stats"):
    x = 16
    for (num, label) in items:
        o.text(parent, x, y, num, 18, theme["text1"], name=f"{name}-n", weight=700)
        o.text(parent, x + text_width(num, 18, 700) + 4, y + 4, label, 12,
               theme["text3"], name=f"{name}-l")
        x += text_width(num, 18, 700) + 4 + text_width(label, 12) + 18


def _action_button(o, parent, x, y, w, label, theme, filled=False, icon=None,
                   name="btn"):
    if filled:
        b = o.frame(parent, x, y, w, 40,
                    fill=linear_gradient([(0, GRADIENT[2]), (1, GRADIENT[4])], 0),
                    corner=12, name=f"{name}-b")
        tw = text_width(label, 14, 600)
        ix = x + w / 2 - tw / 2
        o.text(b, w / 2 - tw / 2, 11, label, 14, solid("#FFFFFF"),
               name=f"{name}-t", weight=600)
        if icon:
            o.path(b, w / 2 - tw / 2 - 24, 9, 22, ICONS[icon], solid("#FFFFFF"),
                   name=f"{name}-ic")
    else:
        b = o.frame(parent, x, y, w, 40, fill=theme["bg"],
                    stroke=theme["divider"], stroke_w=1, corner=12, name=f"{name}-b")
        tw = text_width(label, 14, 500)
        o.text(b, w / 2 - tw / 2, 11, label, 14, theme["text1"],
               name=f"{name}-t", weight=500)
        if icon:
            o.path(b, w / 2 - tw / 2 - 24, 9, 22, ICONS[icon], theme["text1"],
                   name=f"{name}-ic")
    return b


def _grid_tile(o, parent, x, y, size, g1, g2, name, icon=None, label=None):
    o.rect(parent, x, y, size, size,
           linear_gradient([(0, g1), (1, g2)], 45), corner=0, name=name)
    if icon:
        o.path(parent, x + size / 2 - 11, y + size / 2 - 11, 22, ICONS[icon],
               solid("#FFFFFF"), name=f"{name}-ic", opacity=0.95)
    if label:
        o.text(parent, x + 8, y + 8, label, 12, solid("rgba(255,255,255,0.92)"),
               name=f"{name}-t", weight=600)


def my_profile_screen(theme_name, x, y):
    theme = LIGHT if theme_name == "light" else DARK
    o = Op()
    root = o.frame("document", x, y, 390, 844, fill=theme["bg"],
                   name=f"我的主页 · {theme_name}")
    status_bar(o, root, theme)
    # nav
    o.path(root, 16, 66, 22, ICONS["plus"], theme["text1"], name="nav-plus")
    o.text(root, 195 - text_width("小豆手作", 18, 700) / 2, 64, "小豆手作", 18,
           theme["text1"], name="nav-name", weight=700)
    o.path(root, 352, 66, 22, ICONS["menu"], theme["text1"], name="nav-menu")
    # info
    avatar_squircle(o, root, 62, 168, 88,
                    linear_gradient([(0, AVATARS[0][0]), (1, AVATARS[0][1])], 45),
                    name="big-av", plus=True)
    o.text(root, 120, 130, "小豆手作", 20, theme["text1"], name="nickname", weight=700)
    o.text(root, 120, 160, "拼豆爱好者 | 手作治愈生活", 13, theme["text2"],
           name="bio")
    _stats(o, root, 196, theme,
           [("128", "帖子"), ("2.4k", "粉丝"), ("386", "关注")], name="st")
    # action buttons
    _action_button(o, root, 16, 250, 112, "编辑主页", theme, icon="edit", name="btn-edit")
    _action_button(o, root, 138, 250, 112, "分享主页", theme, icon="share", name="btn-share")
    _action_button(o, root, 260, 250, 112, "添加好友", theme, icon="person", name="btn-add")
    # member card
    mc = o.frame(root, 16, 306, 358, 62, fill=theme["surface"],
                 stroke=linear_gradient([(0, GRADIENT[0]), (0.5, GRADIENT[2]), (1, GRADIENT[4])], 0),
                 stroke_w=1.5, corner=16, name="member-card")
    o.path(mc, 16, 18, 26, ICONS["crown"], solid("#D62976"), name="member-ic")
    o.text(mc, 54, 12, "IDOL BEADS 会员", 14, theme["text1"], name="member-t", weight=700,
           family=FONT_EN)
    o.text(mc, 54, 34, "LV2 · 到店拼豆 9 折", 11, theme["text3"], name="member-sub")
    o.frame(mc, 288, 15, 56, 32,
            fill=linear_gradient([(0, GRADIENT[2]), (1, GRADIENT[4])], 0),
            corner=16, name="member-btn")
    o.text(mc, 316 - text_width("开通", 13, 600) / 2, 23, "开通", 13,
           solid("#FFFFFF"), name="member-btn-t", weight=600)
    # tabs
    tabs = ("帖子", "笔记", "视频")
    for i, t in enumerate(tabs):
        tw = text_width(t, 15, 600)
        tx = 16 + i * 124 + 62 - tw / 2
        o.text(root, tx, 388, t, 15, theme["text1"] if i == 0 else theme["text3"],
               name=f"tab-{t}", weight=600)
        if i == 0:
            o.rect(root, 195 - 14, 418, 28, 3, theme["text1"], corner=1.5,
                   name="tab-line")
    o.line(root, 0, 428, 390, 428, theme["divider"], weight=1, name="tab-divider")
    # grid 3x2
    gy = 432
    size = 118
    gap = 6
    for i in range(6):
        gx = 16 + (i % 3) * (size + gap)
        yy = gy + (i // 3) * (size + gap)
        g1, g2 = MEDIA[i % len(MEDIA)]
        _grid_tile(o, root, gx, yy, size, g1, g2, f"g{i}",
                   icon=("play" if i in (1, 4) else None),
                   label=("拼豆新手教程" if i == 1 else None))
    batch_a = {"ops": o.ops}
    o2 = Op()
    bottom_nav(o2, "{{ROOT}}", theme, 4)
    return [batch_a, {"ops": o2.ops}]


def other_profile_screen(theme_name, x, y):
    theme = LIGHT if theme_name == "light" else DARK
    o = Op()
    root = o.frame("document", x, y, 390, 844, fill=theme["bg"],
                   name=f"他人主页 · {theme_name}")
    status_bar(o, root, theme)
    o.path(root, 16, 64, 24, ICONS["back"], theme["text1"], name="back")
    o.text(root, 195 - text_width("手作阿满", 17, 700) / 2, 63, "手作阿满", 17,
           theme["text1"], name="nav-name", weight=700)
    o.path(root, 352, 66, 22, ICONS["share"], theme["text1"], name="nav-share")
    # info
    avatar_squircle(o, root, 56, 168, 80,
                    linear_gradient([(0, AVATARS[1][0]), (1, AVATARS[1][1])], 45),
                    name="av", ring=False)
    o.text(root, 108, 132, "手作阿满", 20, theme["text1"], name="nickname", weight=700)
    lv = o.frame(root, 108 + text_width("手作阿满", 20, 700) + 8, 136, 42, 20,
                 fill=linear_gradient([(0, "#FFD58A"), (1, "#FFB347")], 0),
                 corner=10, name="lv")
    o.text(lv, 21 - text_width("LV5", 11, 700) / 2, 4, "LV5", 11, solid("#7A4A00"),
           name="lv-t", weight=700)
    o.text(root, 108, 162, "女 | 安徽 | 加入 11 天", 13, theme["text2"], name="region")
    o.text(root, 108, 182, "IP 属地：重庆", 12, theme["text3"], name="ip")
    o.text(root, 16, 214, "生而自由，爱而无畏。", 15, theme["text1"], name="sig")
    _stats(o, root, 244, theme,
           [("96", "帖子"), ("8.6k", "粉丝"), ("412", "关注")], name="st")
    # actions
    _action_button(o, root, 16, 286, 170, "私信", theme, icon="send2", name="btn-msg")
    _action_button(o, root, 196, 286, 178, "关注", theme, filled=True, name="btn-follow")
    # posts
    py = 346
    for pi in range(2):
        card = o.frame(root, 16, py, 358, 196, fill=theme["surface"],
                       corner=16, effects=shadow((0, 0, 0), 12, 10, 3),
                       name=f"post-{pi}")
        o.text(card, 14, 14, "#教程", 12, solid("#D62976"), name=f"post-{pi}-tag",
               weight=600)
        o.text(card, 60, 12, "拼豆新手入门指南", 15, theme["text1"],
               name=f"post-{pi}-title", weight=600)
        g1, g2 = MEDIA[(pi + 1) % len(MEDIA)]
        o.rect(card, 14, 40, 330, 100,
               linear_gradient([(0, g1), (1, g2)], 45), corner=12,
               name=f"post-{pi}-media")
        o.path(card, 14 + 330 / 2 - 12, 40 + 50 - 12, 24, ICONS["play"],
               solid("#FFFFFF"), name=f"post-{pi}-play", opacity=0.95)
        o.path(card, 14, 150, 16, ICONS["eye"], theme["text2"], name=f"post-{pi}-v")
        o.text(card, 34, 148, "1.2w", 12, theme["text2"], name=f"post-{pi}-vc")
        o.path(card, 84, 150, 16, ICONS["heart"], theme["text2"], name=f"post-{pi}-l")
        o.text(card, 104, 148, "863", 12, theme["text2"], name=f"post-{pi}-lc")
        o.path(card, 144, 150, 16, ICONS["comment"], theme["text2"],
               name=f"post-{pi}-c")
        o.text(card, 164, 148, "45", 12, theme["text2"], name=f"post-{pi}-cc")
        o.path(card, 204, 150, 16, ICONS["share"], theme["text2"],
               name=f"post-{pi}-s")
        o.text(card, 224, 148, "12", 12, theme["text2"], name=f"post-{pi}-sc")
        py += 208
    batch_a = {"ops": o.ops}
    o2 = Op()
    bottom_nav(o2, "{{ROOT}}", theme, 4)
    return [batch_a, {"ops": o2.ops}]
