"""Reels (短视频) screens — light & dark."""
from design_tokens import (
    LIGHT, DARK, ACCENT, GRADIENT,
    FONT_ZH, FONT_EN,
    solid, linear_gradient, shadow, text_width,
)
from builder import Op, ICONS, status_bar, bottom_nav, avatar_squircle


def reels_screen(theme_name, x, y):
    theme = LIGHT if theme_name == "light" else DARK
    o = Op()
    bg1, bg2 = (("#FFE3EC", "#C9B8FF"), ("#FFD9E2", "#A78BFF"))
    if theme_name == "dark":
        bg1, bg2 = ("#1A1A22", "#3A2B4A"), ("#141419", "#2B2140")
    root = o.frame("document", x, y, 390, 844,
                   fill=linear_gradient([(0, bg1[0]), (1, bg1[1])], 90),
                   name=f"Reels · {theme_name}", clips=True)
    # video frame overlay (slightly darker for contrast)
    o.rect(root, 0, 0, 390, 844,
           linear_gradient([(0, bg2[0]), (1, bg2[1])], 90),
           name="video-bg", opacity=0.85)
    # status bar
    status_bar(o, root, theme, dark_icons=(theme_name == "dark"))
    # top pills 关注/推荐
    o.frame(root, 118, 54, 154, 36, fill="rgba(255,255,255,0.22)",
            corner=18, stroke="rgba(255,255,255,0.5)", stroke_w=1, name="feed-pill")
    o.frame(root, 118, 54, 77, 36, fill="rgba(255,255,255,0.92)",
            corner=18, name="feed-pill-active")
    o.text(root, 156.5 - text_width("推荐", 14, 600) / 2, 63, "推荐", 14,
           solid("#111111"), name="pill-rec", weight=600)
    o.text(root, 118 + 77 + 38.5 - text_width("关注", 14, 500) / 2, 63, "关注", 14,
           solid("#FFFFFF"), name="pill-follow", weight=500)
    # publish button
    o.ellipse(root, 346, 72, 18, solid("rgba(255,255,255,0.30)"),
              stroke=solid("rgba(255,255,255,0.7)"), stroke_w=1, name="publish-bg")
    o.path(root, 334, 60, 24, ICONS["camera"], solid("#FFFFFF"), name="publish-ic")

    # page indicator
    o.text(root, 16, 62, "1 / 8", 13, solid("rgba(255,255,255,0.85)"),
           name="page", weight=600, family=FONT_EN)

    # ---- right action rail ----
    rx = 332
    avatar_squircle(o, root, rx + 18, 300, 40,
                    linear_gradient([(0, "#FF6A88"), (1, "#FF9A5A")], 45),
                    name="rail-av", plus=True, ring=True)
    # like
    o.path(root, rx, 356, 36, ICONS["heart"], solid("#ED4956"), name="rail-like")
    o.text(root, rx + 18 - text_width("32.4w", 12, 600) / 2, 394, "32.4w", 12,
           solid("#FFFFFF"), name="rail-like-c", weight=600)
    # comment
    o.path(root, rx + 3, 422, 30, ICONS["comment"], solid("#FFFFFF"), name="rail-cmt")
    o.text(root, rx + 18 - text_width("482", 12, 600) / 2, 454, "482", 12,
           solid("#FFFFFF"), name="rail-cmt-c", weight=600)
    # share
    o.path(root, rx + 3, 478, 30, ICONS["share"], solid("#FFFFFF"), name="rail-share")
    o.text(root, rx + 18 - text_width("128", 12, 600) / 2, 510, "128", 12,
           solid("#FFFFFF"), name="rail-share-c", weight=600)
    # spinning disc
    o.ellipse(root, rx + 18, 570, 21,
              linear_gradient([(0, GRADIENT[0]), (0.5, GRADIENT[2]), (1, GRADIENT[4])], 45),
              name="disc", stroke=solid("#FFFFFF"), stroke_w=2)
    o.ellipse(root, rx + 18, 570, 6, solid("#FFFFFF"), name="disc-c")

    # center play button
    o.ellipse(root, 195, 430, 32, solid("rgba(0,0,0,0.35)"), name="play-bg")
    o.path(root, 183, 418, 24, ICONS["play"], solid("#FFFFFF"), name="play-ic")

    # ---- bottom info ----
    o.text(root, 16, 668, "@小豆手作", 17, solid("#FFFFFF"), name="info-author", weight=700)
    o.text(root, 16, 694, "拼豆时光记录，每一次点亮都是热爱", 14,
           solid("rgba(255,255,255,0.95)"), name="info-cap")
    o.text(root, 16, 716, "#拼豆 #手作 #治愈系", 13,
           solid("rgba(255,255,255,0.85)"), name="info-tags", weight=500)
    o.path(root, 16, 738, 16, ICONS["music"], solid("#FFFFFF"), name="music-ic")
    o.text(root, 38, 735, "原声 - 小豆手作", 13, solid("#FFFFFF"),
           name="music-name", weight=500)

    batch_a = {"ops": o.ops}
    o2 = Op()
    bottom_nav(o2, "{{ROOT}}", theme, 1, gradient_active=True)
    batch_b = {"ops": o2.ops}
    return [batch_a, batch_b]
