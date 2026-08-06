"""Chat (聊天) screens — list / single / group, light & dark."""
from design_tokens import (
    LIGHT, DARK, ACCENT, GRADIENT, SUCCESS,
    FONT_ZH, FONT_EN,
    solid, linear_gradient, shadow, text_width,
)
from builder import Op, ICONS, status_bar, bottom_nav, avatar_squircle, search_bar

AVATARS = [
    ("#FF6A88", "#FF9A5A"),
    ("#7A5CFF", "#4E9BFF"),
    ("#43D3A4", "#34B3F1"),
    ("#F5576C", "#F093FB"),
    ("#5B8DFF", "#7C4DFF"),
]


def _group_avatar(o, parent, x, y, size, name="gav"):
    r = size / 2
    o.rect(parent, x, y, size, size, solid("#F0F1F2"), corner=size * 0.3,
           name=f"{name}-bg")
    o.ellipse(parent, x + size * 0.36, y + size * 0.36, size * 0.17,
              linear_gradient([(0, AVATARS[1][0]), (1, AVATARS[1][1])], 45),
              name=f"{name}-1")
    o.ellipse(parent, x + size * 0.68, y + size * 0.40, size * 0.14,
              linear_gradient([(0, AVATARS[0][0]), (1, AVATARS[0][1])], 45),
              name=f"{name}-2")
    o.ellipse(parent, x + size * 0.30, y + size * 0.72, size * 0.14,
              linear_gradient([(0, AVATARS[2][0]), (1, AVATARS[2][1])], 45),
              name=f"{name}-3")


def _list_row(o, parent, y, theme, name, preview, time, unread, group=False,
              pinned=False, g1=None, g2=None):
    if group:
        _group_avatar(o, parent, 16, y, 52)
    else:
        o.rect(parent, 16, y, 52, 52,
               linear_gradient([(0, g1), (1, g2)], 45), corner=16, name="row-av")
    o.text(parent, 82, y + 3, name, 16, theme["text1"], name="row-name", weight=700)
    o.text(parent, 82, y + 29, preview, 14, theme["text2"], name="row-preview")
    o.text(parent, 300, y + 5, time, 12, theme["text3"], name="row-time")
    if unread:
        o.ellipse(parent, 344, y + 12, 11,
                  linear_gradient([(0, GRADIENT[2]), (1, GRADIENT[4])], 0),
                  name="row-badge")
        o.text(parent, 344 - text_width(str(unread), 11, 700) / 2, y + 6,
               str(unread), 11, solid("#FFFFFF"), name="row-badge-t", weight=700)
    if pinned:
        o.text(parent, 82, y - 16, "置顶", 10, theme["text3"], name="row-pin", weight=600)
    o.line(parent, 16, y + 66, 374, y + 66, theme["divider"], weight=1, name="row-line")


def chat_list_screen(theme_name, x, y):
    theme = LIGHT if theme_name == "light" else DARK
    o = Op()
    root = o.frame("document", x, y, 390, 844, fill=theme["bg"],
                   name=f"会话列表 · {theme_name}")
    status_bar(o, root, theme)
    # nav
    o.rect(root, 16, 58, 36, 36,
           linear_gradient([(0, AVATARS[0][0]), (1, AVATARS[0][1])], 45),
           corner=12, name="my-av")
    o.text(root, 195 - text_width("聊天", 20, 700) / 2, 62, "聊天", 20,
           theme["text1"], name="title", weight=700)
    o.path(root, 296, 66, 20, ICONS["filter"], theme["text1"], name="filter-ic")
    o.text(root, 322, 66, "全部", 14, theme["text1"], name="filter-label", weight=500)
    o.path(root, 358, 66, 20, ICONS["plus"], theme["text1"], name="new-ic")
    search_bar(o, root, 16, 104, 358, theme, "搜索会话或消息", name="search")
    _list_row(o, root, 158, theme, "小豆手作", "明天下午到店可以吗？", "09:32",
              unread=2, pinned=True, g1=AVATARS[0][0], g2=AVATARS[0][1])
    _list_row(o, root, 240, theme, "拼豆兴趣群", "阿满：新教程发群里了", "昨天",
              unread=12, group=True)
    _list_row(o, root, 322, theme, "IDOL BEADS 客服", "您预约的课程已核销，期待到店", "周二",
              unread=0, g1=AVATARS[3][0], g2=AVATARS[3][1])
    _list_row(o, root, 404, theme, "手作阿满", "[图片]", "周一",
              unread=0, g1=AVATARS[1][0], g2=AVATARS[1][1])
    batch_a = {"ops": o.ops}
    o2 = Op()
    bottom_nav(o2, "{{ROOT}}", theme, 3)
    return [batch_a, {"ops": o2.ops}]


def _chat_nav(o, root, theme, title, subtitle=None, g1=None, g2=None, group=False):
    o.path(root, 16, 64, 24, ICONS["back"], theme["text1"], name="back")
    if group:
        _group_avatar(o, root, 52, 54, 40, name="nav-gav")
    else:
        o.rect(root, 52, 54, 40, 40,
               linear_gradient([(0, g1), (1, g2)], 45), corner=13, name="nav-av")
    o.text(root, 102, 56, title, 17, theme["text1"], name="nav-title", weight=700)
    if subtitle:
        o.text(root, 102, 78, subtitle, 11, theme["text3"], name="nav-sub")
    else:
        o.ellipse(root, 100 + text_width(title, 17, 700) + 10, 66, 4,
                  solid(SUCCESS), name="online")
    o.path(root, 354, 66, 20, ICONS["more"], theme["text1"], name="nav-more")


def _bubble(o, root, y, theme, text, mine, name="b", width=None, bubble_fill=None,
            text_color=None, failed=False):
    w = width or text_width(text, 15) + 36
    if mine:
        x = 390 - 16 - w
    else:
        x = 16
    fill = bubble_fill or (theme["bubble_out"] if mine else theme["bubble_in"])
    color = text_color or (theme["bubble_out_text"] if mine else theme["text1"])
    b = o.frame(root, x, y, w, 40, fill=fill, corner=16, name=f"{name}-b")
    o.text(b, 18, 10, text, 15, solid(color), name=f"{name}-t")
    if failed:
        o.text(root, 390 - 16 - w, y + 44, "发送失败，点击重试", 11,
               solid("#ED4956"), name=f"{name}-err", weight=500)
        o.path(root, 390 - 16 - w - 22, y + 42, 16, ICONS["refresh"],
               solid("#ED4956"), name=f"{name}-retry")
    return b


def single_chat_screen(theme_name, x, y):
    theme = LIGHT if theme_name == "light" else DARK
    o = Op()
    root = o.frame("document", x, y, 390, 844, fill=theme["bg"],
                   name=f"单聊 · {theme_name}")
    status_bar(o, root, theme)
    _chat_nav(o, root, theme, "小豆手作", g1=AVATARS[0][0], g2=AVATARS[0][1])
    # time divider
    o.text(root, 195 - text_width("今天 14:32", 12) / 2, 110, "今天 14:32", 12,
           theme["text3"], name="time")
    # incoming
    _bubble(o, root, 134, theme, "明天下午到店可以吗？", False, name="m1")
    # outgoing
    _bubble(o, root, 188, theme, "可以，2 点后都有位置～", True, name="m2")
    # incoming image
    o.frame(root, 16, 248, 160, 120,
            fill=linear_gradient([(0, "#FFD9E2"), (1, "#B8A7FF")], 45),
            corner=16, name="img-bubble")
    o.path(root, 16 + 68, 248 + 46, 24, ICONS["image"], solid("#FFFFFF"),
           name="img-ic", opacity=0.9)
    # incoming voice
    vb = o.frame(root, 16, 384, 168, 40, fill=theme["bubble_in"], corner=16,
                 name="voice-b")
    o.path(vb, 14, 10, 20, ICONS["mic"], theme["text1"], name="voice-mic")
    o.rect(vb, 44, 18, 80, 4, theme["divider"], corner=2, name="voice-progress")
    o.rect(vb, 44, 18, 40, 4, solid(ACCENT), corner=2, name="voice-played")
    o.text(vb, 136, 10, "12\"", 13, theme["text2"], name="voice-dur")
    # outgoing failed
    _bubble(o, root, 448, theme, "对了，帮我留两杯拼豆材料包", True, name="m3",
            failed=True)
    # read status
    o.text(root, 16, 522, "对方已读", 11, theme["text3"], name="read-state")
    # input bar
    bar = o.frame(root, 0, 770, 390, 74, fill=theme["bg"],
                  stroke=theme["divider"], stroke_w=1, name="input-bar")
    o.path(bar, 18, 789, 24, ICONS["mic"], theme["text1"], name="in-mic")
    o.frame(bar, 52, 783, 272, 36, fill=theme["search"], corner=18, name="in-field")
    o.text(bar, 68, 792, "Aa", 15, theme["text3"], name="in-ph", family=FONT_EN)
    o.path(bar, 296, 790, 20, ICONS["camera"], theme["text1"], name="in-cam")
    o.path(bar, 336, 788, 24, ICONS["plus"], theme["text1"], name="in-plus")
    o.path(bar, 366, 790, 20, ICONS["send"], theme["text1"], name="in-send")
    return [{"ops": o.ops}]


def group_chat_screen(x, y):
    theme = LIGHT
    o = Op()
    root = o.frame("document", x, y, 390, 844, fill=theme["bg"],
                   name="群聊 · 亮")
    status_bar(o, root, theme)
    _chat_nav(o, root, theme, "拼豆兴趣群", subtitle="3 位成员", group=True)
    # notice
    n = o.frame(root, 16, 108, 358, 52, fill=theme["surface2"], corner=12,
                name="notice")
    o.text(n, 12, 10, "群公告", 12, theme["text2"], name="notice-tag", weight=600)
    o.text(n, 12, 28, "本周六到店拼豆体验课，记得提前预约哦～", 13, theme["text1"],
           name="notice-t")
    # incoming with sender name
    o.text(root, 16, 176, "小豆手作", 12, theme["text3"], name="s1")
    _bubble(o, root, 192, theme, "这期教程我发群里啦，快去看", False, name="g1")
    o.text(root, 16, 246, "阿满", 12, theme["text3"], name="s2")
    _bubble(o, root, 262, theme, "收到！周末一起拼", False, name="g2")
    _bubble(o, root, 316, theme, "我已经预约了 3 个人的位置～", True, name="g3")
    o.text(root, 16, 372, "你", 12, theme["text3"], name="s3")
    _bubble(o, root, 388, theme, "太棒了，周六见！", False, name="g4")
    bar = o.frame(root, 0, 770, 390, 74, fill=theme["bg"],
                  stroke=theme["divider"], stroke_w=1, name="input-bar")
    o.path(bar, 18, 789, 24, ICONS["mic"], theme["text1"], name="in-mic")
    o.frame(bar, 52, 783, 272, 36, fill=theme["search"], corner=18, name="in-field")
    o.text(bar, 68, 792, "Aa", 15, theme["text3"], name="in-ph", family=FONT_EN)
    o.path(bar, 296, 790, 20, ICONS["camera"], theme["text1"], name="in-cam")
    o.path(bar, 336, 788, 24, ICONS["plus"], theme["text1"], name="in-plus")
    o.path(bar, 366, 790, 20, ICONS["send"], theme["text1"], name="in-send")
    return [{"ops": o.ops}]
