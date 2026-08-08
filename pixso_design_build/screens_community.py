"""Community (社区) screens — light & dark."""
from design_tokens import (
    LIGHT, DARK, ACCENT, GRADIENT, GRADIENT_ACCENT,
    FONT_ZH, FONT_EN,
    solid, linear_gradient, shadow, parse_css_color, text_width,
)
from builder import Op, ICONS, status_bar, bottom_nav, avatar_squircle, chip

MEDIA_GRADS = [
    ("#FFD9E2", "#B8A7FF"),
    ("#FFE3C8", "#FFB39B"),
    ("#C8F0E3", "#8FD3F4"),
    ("#E4D5FF", "#9F8CFF"),
    ("#FFD1D8", "#FF8A9B"),
    ("#FFF3C4", "#FFC46B"),
    ("#D5E9FF", "#8FB8FF"),
    ("#DFF5D9", "#9AD98B"),
]
AVATAR_GRADS = [
    ("#FF6A88", "#FF9A5A"),
    ("#7A5CFF", "#4E9BFF"),
    ("#FFB347", "#FF6A5A"),
    ("#43D3A4", "#34B3F1"),
    ("#F5576C", "#F093FB"),
    ("#5B8DFF", "#7C4DFF"),
]


def _author_row(o, parent, y, name, tag, time, theme, g1, g2, ring=True, name_p="author"):
    if ring:
        avatar_squircle(o, parent, 42, y + 22, 44,
                        linear_gradient([(0, g1), (1, g2)], 45), name=f"{name_p}-av")
    else:
        o.ellipse(parent, 42, y + 22, 20,
                  linear_gradient([(0, g1), (1, g2)], 45), name=f"{name_p}-av")
    o.text(parent, 72, y + 4, name, 15, theme["text1"], name=f"{name_p}-name", weight=600)
    o.text(parent, 72, y + 26, f"{tag} · {time}", 12, theme["text3"],
           name=f"{name_p}-meta")


def _action_row(o, parent, y, theme, liked=False, counts=("1.2k", "86", "32"), name="act"):
    items = [
        (ICONS["heart"], counts[0], liked, ACCENT if liked else theme["text2"]),
        (ICONS["comment"], counts[1], False, theme["text2"]),
        (ICONS["bookmark"], counts[2], False, theme["text2"]),
        (ICONS["send"], None, False, theme["text2"]),
    ]
    x = 16
    for i, (d, label, on, color) in enumerate(items):
        o.path(parent, x, y + 2, 20, d, solid(color), name=f"{name}-ic{i}")
        if label:
            o.text(parent, x + 26, y + 1, label, 13, theme["text2"],
                   name=f"{name}-c{i}")
        x += 44 if label else 32


def community_screen(theme_name, x, y, active_tab="发现"):
    theme = LIGHT if theme_name == "light" else DARK
    o = Op()
    root = o.frame("document", x, y, 390, 844, fill=theme["bg"],
                   name=f"社区 · {theme_name}")
    # status bar
    status_bar(o, root, theme)
    # header
    o.text(root, 16, 62, "IDOL", 20, theme["text1"], name="logo-en", weight=700,
           family=FONT_EN, letter_spacing=0.5)
    o.text(root, 16 + text_width("IDOL", 20, 700, 0.5), 62, "BEADS", 20,
           solid("#D62976"), name="logo-accent", weight=700, family=FONT_EN,
           letter_spacing=0.5)
    o.path(root, 352, 66, 22, ICONS["search"], theme["text1"], name="header-search")
    # tabs
    tabs = ("发现", "关注")
    txs = []
    for i, t in enumerate(tabs):
        tw = text_width(t, 17, 700)
        tx = 195 - tw / 2 + (i - 0.5) * 76
        txs.append((tx, tw))
        o.text(root, tx, 98, t, 17, theme["text1"] if t == active_tab else theme["text3"],
               name=f"tab-{t}", weight=700 if t == active_tab else 500)
    if active_tab == "发现":
        o.rect(root, 195 - 11, 130, 22, 3, theme["text1"], corner=1.5, name="tab-line")
    # category pills
    cats = ("推荐", "最新", "热门", "教程", "日常", "活动")
    cx = 16
    for i, c in enumerate(cats):
        w = text_width(c, 13, 500) + 22
        if i == 0:
            o.frame(root, cx, 144, w, 30,
                    fill=linear_gradient([(0, GRADIENT[2]), (1, GRADIENT[4])], 0),
                    corner=15, name=f"pill-{c}")
            o.text(root, cx + 11 - text_width(c, 13, 500) / 2, 150, c, 13,
                   solid("#FFFFFF"), name=f"pill-{c}-t", weight=500)
        else:
            o.frame(root, cx, 144, w, 30, fill=theme["surface2"], corner=15,
                    name=f"pill-{c}")
            o.text(root, cx + 11 - text_width(c, 13, 500) / 2, 150, c, 13,
                   theme["text2"], name=f"pill-{c}-t", weight=500)
        cx += w + 6

    # ---- feed card 1 ----
    _author_row(o, root, 196, "小豆手作", "#教程", "3 小时前", theme,
                AVATAR_GRADS[0][0], AVATAR_GRADS[0][1], name_p="c1")
    # 2-column media
    o.rect(root, 16, 244, 172, 168,
           linear_gradient([(0, MEDIA_GRADS[0][0]), (1, MEDIA_GRADS[0][1])], 45),
           corner=16, name="c1-m1")
    o.rect(root, 194, 244, 172, 168,
           linear_gradient([(0, MEDIA_GRADS[1][0]), (1, MEDIA_GRADS[1][1])], 45),
           corner=16, name="c1-m2")
    o.text(root, 16 + 172 / 2 - text_width("拼豆杯垫", 13) / 2, 244 + 168 / 2 - 9,
           "拼豆杯垫", 13, solid("rgba(255,255,255,0.9)"), name="c1-m1-t", weight=600)
    o.text(root, 194 + 172 / 2 - text_width("春日挂件", 13) / 2, 244 + 168 / 2 - 9,
           "春日挂件", 13, solid("rgba(255,255,255,0.9)"), name="c1-m2-t", weight=600)
    o.text(root, 16, 424, "拼豆新手的第一件作品，杯垫 + 挂件组合～", 15, theme["text1"],
           name="c1-cap", weight=400)
    _action_row(o, root, 454, theme, liked=True, counts=("1.2k", "86", "32"), name="c1")

    # ---- feed card 2 (partial) ----
    _author_row(o, root, 508, "手作阿满", "#日常", "昨天", theme,
                AVATAR_GRADS[1][0], AVATAR_GRADS[1][1], ring=False, name_p="c2")
    o.rect(root, 16, 556, 82, 82,
           linear_gradient([(0, MEDIA_GRADS[2][0]), (1, MEDIA_GRADS[2][1])], 45),
           corner=12, name="c2-m1")
    o.rect(root, 102, 556, 82, 82,
           linear_gradient([(0, MEDIA_GRADS[3][0]), (1, MEDIA_GRADS[3][1])], 45),
           corner=12, name="c2-m2")
    o.rect(root, 188, 556, 82, 82,
           linear_gradient([(0, MEDIA_GRADS[4][0]), (1, MEDIA_GRADS[4][1])], 45),
           corner=12, name="c2-m3")
    o.rect(root, 274, 556, 82, 82,
           linear_gradient([(0, MEDIA_GRADS[5][0]), (1, MEDIA_GRADS[5][1])], 45),
           corner=12, name="c2-m4")
    o.text(root, 16, 648, "周末的治愈时光，把喜欢的图案一颗颗拼出来", 14, theme["text2"],
           name="c2-cap")
    _action_row(o, root, 678, theme, liked=False, counts=("468", "32", "9"), name="c2")
    o.text(root, 16, 716, "加载更多…", 13, theme["text3"], name="more-hint")

    batch_a = {"ops": o.ops}
    o2 = Op()
    bottom_nav(o2, "{{ROOT}}", theme, 2, gradient_active=False)
    batch_b = {"ops": o2.ops}
    return [batch_a, batch_b]
