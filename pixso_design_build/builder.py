"""Emits apply_design operation strings."""
import json
import math

from design_tokens import (
    LIGHT, DARK, ACCENT, SUCCESS, WARNING, GRADIENT, GRADIENT_ACCENT,
    FONT_ZH, FONT_EN, TYPE, RADII,
    solid, linear_gradient, shadow, parse_css_color, text_width,
)


def _coerce_fill(fill):
    """Accept paint list or css color string."""
    if isinstance(fill, str):
        return solid(fill)
    return fill


def _coerce_stroke(stroke):
    if isinstance(stroke, str):
        return [{"type": "SOLID", "color": parse_css_color(stroke)}]
    return stroke


class Op:
    def __init__(self):
        self.ops = []
        self.n = 0

    def name(self, prefix="n"):
        self.n += 1
        return f"{prefix}{self.n}"

    def _insert(self, v, parent, kind, props):
        props = {k: vv for k, vv in props.items() if vv is not None}
        p = {**{"name": f"{v}", "type": kind}, **props}
        self.ops.append(f'{v}=I({parent}, {json.dumps(p, ensure_ascii=False)});')
        return v

    def frame(self, parent, x, y, w, h, name=None, fill=None, corner=None,
              stroke=None, stroke_w=0, effects=None, opacity=None,
              clips=True, radii=None):
        v = self.name("f")
        p = {"left": x, "top": y, "width": w, "height": h}
        if name:
            p["name"] = name
        if fill is not None:
            p["fillPaints"] = _coerce_fill(fill)
        if corner is not None:
            p["cornerRadius"] = corner
        if radii:
            p.update(radii)
        if stroke is not None:
            p["strokePaints"] = _coerce_stroke(stroke)
            p["strokeWeight"] = stroke_w
        if effects is not None:
            p["effects"] = effects
        if opacity is not None:
            p["opacity"] = opacity
        if clips is not None:
            p["clipsContent"] = clips
        self.ops.append(f'{v}=I({parent}, {json.dumps(p, ensure_ascii=False)});')
        return v

    def rect(self, parent, x, y, w, h, fill, corner=None, name=None, stroke=None,
             stroke_w=0, effects=None, opacity=None):
        v = self.name("r")
        p = {"left": x, "top": y, "width": w, "height": h, "type": "rect",
             "name": name or v}
        if fill is not None:
            p["fillPaints"] = _coerce_fill(fill)
        if corner is not None:
            p["cornerRadius"] = corner
        if stroke is not None:
            p["strokePaints"] = _coerce_stroke(stroke)
            p["strokeWeight"] = stroke_w
        if effects is not None:
            p["effects"] = effects
        if opacity is not None:
            p["opacity"] = opacity
        self.ops.append(f'{v}=I({parent}, {json.dumps(p, ensure_ascii=False)});')
        return v

    def ellipse(self, parent, cx, cy, r, fill, name=None, stroke=None, stroke_w=0,
                opacity=None):
        v = self.name("e")
        p = {"left": round(cx - r, 2), "top": round(cy - r, 2),
             "width": round(r * 2, 2), "height": round(r * 2, 2),
             "type": "ellipse", "name": name or v}
        if fill is not None:
            p["fillPaints"] = _coerce_fill(fill)
        if stroke is not None:
            p["strokePaints"] = _coerce_stroke(stroke)
            p["strokeWeight"] = stroke_w
        if opacity is not None:
            p["opacity"] = opacity
        self.ops.append(f'{v}=I({parent}, {json.dumps(p, ensure_ascii=False)});')
        return v

    def line(self, parent, x1, y1, x2, y2, stroke, weight=1.5, name=None):
        v = self.name("l")
        p = {"left": min(x1, x2), "top": min(y1, y2),
             "width": abs(x2 - x1) or 0.01, "height": abs(y2 - y1) or 0.01,
             "type": "line", "name": name or v,
             "strokePaints": _coerce_stroke(stroke), "strokeWeight": weight}
        self.ops.append(f'{v}=I({parent}, {json.dumps(p, ensure_ascii=False)});')
        return v

    def path(self, parent, x, y, size, d, fill, name=None, opacity=None):
        v = self.name("p")
        p = {"left": x, "top": y, "width": size, "height": size, "type": "path",
             "path": d, "name": name or v}
        if fill is not None:
            p["fillPaints"] = _coerce_fill(fill)
        if opacity is not None:
            p["opacity"] = opacity
        self.ops.append(f'{v}=I({parent}, {json.dumps(p, ensure_ascii=False)});')
        return v

    def text(self, parent, x, y, s, size, fill, name=None, weight=400,
             letter_spacing=0, family=None, align=None, width=None):
        v = self.name("t")
        p = {"left": x, "top": y, "type": "text", "nodeText": s, "name": name or v,
             "fontSize": size, "fontWeight": weight,
             "fontFamily": family or FONT_ZH,
             "fillPaints": _coerce_fill(fill)}
        if letter_spacing:
            p["letterSpacing"] = letter_spacing
        self.ops.append(f'{v}=I({parent}, {json.dumps(p, ensure_ascii=False)});')
        return v

    def group(self, parent, name=None):
        v = self.name("g")
        p = {"name": name or v, "type": "frame"}
        self.ops.append(f'{v}=I({parent}, {json.dumps(p, ensure_ascii=False)});')
        return v


# ---------------- shared widgets ----------------

ICONS = {
    "heart": "M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z",
    "comment": "M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z",
    "bookmark": "M17 3H7c-1.1 0-1.99.9-1.99 2L5 21l7-3 7 3V5c0-1.1-.9-2-2-2z",
    "send": "M2.01 21L23 12 2.01 3 2 10l15 2-15 2z",
    "play": "M8 5v14l11-7z",
    "search": "M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z",
    "plus": "M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z",
    "person": "M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z",
    "home": "M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z",
    "grid": "M3 3h8v8H3zM13 3h8v8h-8zM3 13h8v8H3zM13 13h8v8h-8z",
    "bubble": "M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z",
    "music": "M12 3v10.55A4 4 0 1 0 14 17V7h4V3h-6z",
    "mic": "M12 14a3 3 0 0 0 3-3V5a3 3 0 0 0-6 0v6a3 3 0 0 0 3 3zm5-3a5 5 0 0 1-10 0H5a7 7 0 0 0 6 6.92V21h2v-3.08A7 7 0 0 0 19 11h-2z",
    "camera": "M12 15.2a3.2 3.2 0 1 0 0-6.4 3.2 3.2 0 0 0 0 6.4zM9 2L7.17 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2h-3.17L15 2H9zm3 15c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5z",
    "image": "M21 19V5c0-1.1-.9-2-2-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2zM8.5 13.5l2.5 3.01L14.5 12l4.5 6H5l3.5-4.5z",
    "more": "M6 10c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm12 0c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm-6 0c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z",
    "back": "M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z",
    "share": "M18 16.08c-.76 0-1.44.3-1.96.77L8.91 12.7c.05-.23.09-.46.09-.7s-.04-.47-.09-.7l7.05-4.11c.54.5 1.25.81 2.04.81 1.66 0 3-1.34 3-3s-1.34-3-3-3-3 1.34-3 3c0 .24.04.47.09.7L8.04 9.81C7.5 9.31 6.79 9 6 9c-1.66 0-3 1.34-3 3s1.34 3 3 3c.79 0 1.5-.31 2.04-.81l7.12 4.16c-.05.21-.08.43-.08.65 0 1.61 1.31 2.92 2.92 2.92 1.61 0 2.92-1.31 2.92-2.92s-1.31-2.92-2.92-2.92z",
    "check": "M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z",
    "close": "M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z",
    "edit": "M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z",
    "trash": "M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z",
    "star": "M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z",
    "refresh": "M17.65 6.35C16.2 4.9 14.21 4 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08c-.82 2.33-3.04 4-5.65 4-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z",
    "filter": "M10 18h4v-2h-4v2zM3 6v2h18V6H3zm3 7h12v-2H6v2z",
    "video": "M17 10.5V7c0-.55-.45-1-1-1H4c-.55 0-1 .45-1 1v10c0 .55.45 1 1 1h12c.55 0 1-.45 1-1v-3.5l4 4v-11l-4 4z",
    "wallet": "M21 18v1c0 1.1-.9 2-2 2H5c-1.11 0-2-.9-2-2V5c0-1.1.89-2 2-2h14c1.1 0 2 .9 2 2v1h-9c-1.11 0-2 .9-2 2v8c0 1.1.89 2 2 2h9zm-9-2h10V8H12v8zm4-2.5c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5z",
    "clock": "M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67z",
    "location": "M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z",
    "eye": "M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z",
    "bell": "M12 22c1.1 0 2-.9 2-2h-4c0 1.1.9 2 2 2zm6-6v-5c0-3.07-1.63-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.64 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z",
    "menu": "M3 18h18v-2H3v2zm0-5h18v-2H3v2zm0-7v2h18V6H3z",
    "chevron": "M10 6L8.59 7.41 13.17 12l-4.58 4.59L10 18l6-6z",
    "diamond": "M12 2l3.09 5.4L21 8.5l-4.5 4.5L18 19l-6-2.8L6 19l1.5-6L3 8.5l5.91-1.1z",
    "crown": "M5 16L3 5l5.5 5L12 4l3.5 6L21 5l-2 11H5zm14 3c0 .55-.45 1-1 1H6c-.55 0-1-.45-1-1v-1h14v1z",
    "send2": "M3 20.5l18-8.5-18-8.5v6.79l12.86 1.71L3 13.71v6.79z",
}


def status_bar(o, screen, theme, dark_icons=True):
    c = parse_css_color(theme["text1"])
    o.text(screen, 28, 15, "9:41", 15, solid("#000000" if dark_icons else "#FFFFFF"),
           name="time", weight=600, family=FONT_EN)
    # battery
    o.rect(screen, 340, 17, 22, 11, None, corner=4,
           stroke=solid("#000000" if dark_icons else "#FFFFFF"), stroke_w=1, name="battery")
    o.rect(screen, 342, 19, 16, 7, solid("#000000" if dark_icons else "#FFFFFF"), corner=2,
           name="battery-fill")
    o.rect(screen, 364, 20, 2, 5, solid("#000000" if dark_icons else "#FFFFFF"), corner=1,
           name="battery-tip")
    # signal bars
    for i, hh in enumerate([4, 7, 10]):
        o.rect(screen, 318 + i * 4, 24 - hh + 3, 3, hh,
               solid("#000000" if dark_icons else "#FFFFFF"), corner=1, name="signal")


def bottom_nav(o, screen, theme, active, y=760, gradient_active=False,
               labels=("主页", "Reels", "社区", "消息", "我的")):
    icons = ("home", "video", "grid", "bubble", "person")
    nav = o.frame(screen, 16, y, 358, 62, fill=theme["nav_glass"],
                  corner=31, stroke=theme["nav_border"], stroke_w=1,
                  effects=shadow((0, 0, 0), 30, 16, 6), name="glass-nav")
    item_w = 358 / 5
    for i, label in enumerate(labels):
        cx = 16 + item_w * i + item_w / 2
        is_active = (i == active)
        if is_active:
            pill = o.frame(nav, cx - 34, 6, 68, 50,
                           fill=linear_gradient([(0, GRADIENT[0]), (0.5, GRADIENT[2]), (1, GRADIENT[4])])
                           if gradient_active else theme["active_pill"],
                           corner=25, name=f"nav-active-{label}")
            ic = o.path(pill, 23, 9, 22, ICONS[icons[i]], solid("#FFFFFF"), name=f"ic-{label}")
            o.text(pill, 34 - text_width(label, 10, 600) / 2, 33, label, 10,
                   solid("#FFFFFF"), name=f"lb-{label}", weight=600, family=FONT_ZH)
        else:
            ic = o.path(nav, cx - 11, 8, 22, ICONS[icons[i]], theme["tabinactive"],
                        name=f"ic-{label}")
            o.text(nav, cx - text_width(label, 10, 500) / 2, 34, label, 10,
                   theme["tabinactive"], name=f"lb-{label}", weight=500, family=FONT_ZH)


def avatar_squircle(o, parent, cx, cy, size, gradient, name="avatar", plus=False,
                    ring=True, ring_color=None):
    """Squircle avatar with optional gradient story ring."""
    r = size / 2
    if ring:
        o.ellipse(parent, cx, cy, r + 2.5, linear_gradient(
            [(0, GRADIENT[0]), (0.25, GRADIENT[1]), (0.5, GRADIENT[2]),
             (0.75, GRADIENT[3]), (1, GRADIENT[4])], 45),
            name=f"{name}-ring")
        o.ellipse(parent, cx, cy, r - 2.5, solid("#FFFFFF"), name=f"{name}-gap")
    av = o.ellipse(parent, cx, cy, r - 4 if ring else r, gradient,
                   name=name)
    if plus:
        o.ellipse(parent, cx + r - 8, cy + r - 8, 9,
                  solid("#ED4956"), stroke=solid("#FFFFFF"), stroke_w=2, name=f"{name}-plus-bg")
        o.path(parent, cx + r - 12, cy + r - 12, 8, ICONS["plus"],
               solid("#FFFFFF"), name=f"{name}-plus")
    return av


def chip(o, parent, cx, y, label, fill, text_color, size=(None, 30), name="chip"):
    w = size[0] if size[0] else text_width(label, 13, 500) + 26
    c = o.frame(parent, cx - w / 2, y, w, size[1], fill=fill, corner=15,
                name=name)
    o.text(c, w / 2 - text_width(label, 13, 500) / 2, (size[1] - 18) / 2,
           label, 13, text_color, name=f"{name}-t", weight=500)
    return c


def search_bar(o, parent, x, y, w, theme, placeholder, name="search"):
    c = o.frame(parent, x, y, w, 38, fill=theme["search"], corner=12, name=name)
    o.path(c, 12, 9, 20, ICONS["search"], theme["text3"], name=f"{name}-ic")
    o.text(c, 40, 10, placeholder, 14, theme["text3"], name=f"{name}-t")
    return c


def story_ring(o, parent, cx, cy, size, inner_gradient, name="story", seen=False):
    r = size / 2
    ring = linear_gradient([(0, GRADIENT[0]), (0.25, GRADIENT[1]), (0.5, GRADIENT[2]),
                            (0.75, GRADIENT[3]), (1, GRADIENT[4])], 45) if not seen \
        else solid("#DBDBDB")
    o.ellipse(parent, cx, cy, r + 2, ring, name=f"{name}-ring")
    o.ellipse(parent, cx, cy, r - 2.2, solid("#FFFFFF"), name=f"{name}-gap")
    o.ellipse(parent, cx, cy, r - 4.2, inner_gradient, name=name)
