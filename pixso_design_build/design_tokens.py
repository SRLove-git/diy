"""IDOL BEADS redesign design tokens shared by the screen builder."""

# ---- Neutral palettes ----
LIGHT = {
    "bg": "#FFFFFF",
    "surface": "#FFFFFF",
    "surface2": "#F7F7F7",
    "search": "#EFEFEF",
    "text1": "#111111",
    "text2": "#737373",
    "text3": "#A8A8A8",
    "divider": "#DBDBDB",
    "outline": "#E8E8E8",
    "tabinactive": "#8E8E93",
    "bubble_in": "#F0F1F2",
    "bubble_out": "#111111",
    "bubble_out_text": "#FFFFFF",
    "nav_glass": "rgba(255,255,255,0.86)",
    "nav_border": "rgba(17,17,17,0.08)",
    "active_pill": "#111111",
    "scrim": "rgba(0,0,0,0.5)",
    "skeleton": "#EEEEEE",
}

DARK = {
    "bg": "#000000",
    "surface": "#121212",
    "surface2": "#1A1A1A",
    "search": "#1E1E24",
    "text1": "#F5F5F5",
    "text2": "#A8A8A8",
    "text3": "#7A7A7A",
    "divider": "#2A2A2A",
    "outline": "#2E2E2E",
    "tabinactive": "#8E8E93",
    "bubble_in": "#262626",
    "bubble_out": "#FFFFFF",
    "bubble_out_text": "#111111",
    "nav_glass": "rgba(24,24,28,0.88)",
    "nav_border": "rgba(255,255,255,0.10)",
    "active_pill": "#FFFFFF",
    "scrim": "rgba(0,0,0,0.6)",
    "skeleton": "#1F1F1F",
}

# ---- Brand ----
ACCENT = "#ED4956"          # IG red
SUCCESS = "#2E9E5B"
WARNING = "#E6A23C"
GRADIENT = ["#FEDA75", "#FA7E1E", "#D62976", "#962FBF", "#4F5BD5"]
GRADIENT_ACCENT = ["#ED4956", "#962FBF"]

# ---- Typography ----
FONT_ZH = "Noto Sans SC"
FONT_EN = "Inter"
TYPE = {
    "h1": (24, 700),
    "h2": (20, 700),
    "module": (20, 600),
    "body": (17, 400),
    "primary": (15, 500),
    "secondary": (13, 400),
    "caption": (12, 400),
    "tiny": (10, 600),
}

# ---- Radius ----
RADII = {
    "card": 16,
    "cardLg": 20,
    "button": 12,
    "chip": 10,
    "input": 12,
    "modal": 20,
    "bubble": 16,
    "pill": 999,
}


def hex_rgb(hexstr, alpha=255):
    h = hexstr.lstrip("#")
    return {"r": int(h[0:2], 16), "g": int(h[2:4], 16), "b": int(h[4:6], 16), "a": alpha}


def parse_css_color(s, alpha=255):
    """Accept '#RRGGBB' or 'rgba(r,g,b,a)'."""
    if s.startswith("rgba"):
        inner = s[s.index("(") + 1:s.index(")")]
        parts = [p.strip() for p in inner.split(",")]
        return {"r": int(parts[0]), "g": int(parts[1]), "b": int(parts[2]),
                "a": int(float(parts[3]) * 255)}
    return hex_rgb(s, alpha)


def solid(hexstr, alpha=255):
    return [{"type": "SOLID", "color": parse_css_color(hexstr, alpha)}]


def linear_gradient(stops, angle=45):
    """stops: list of (position, hex). Pixso gradient: stops + size + rotation."""
    stops_p = [{"color": parse_css_color(h, 255), "position": pos} for pos, h in stops]
    return [{"type": "GRADIENT_LINEAR", "stops": stops_p,
             "size": {"width": 1, "height": 0.05}, "rotation": angle}]


def shadow(rgb=(0, 0, 0), a=25, radius=12, y=4):
    return [{"type": "DROP_SHADOW",
             "color": {"r": rgb[0], "g": rgb[1], "b": rgb[2], "a": a},
             "offset": {"x": 0, "y": y}, "radius": radius}]


def text_width(text, size, weight=400, letter_spacing=0):
    w = 0.0
    for ch in text:
        if ch == "\n":
            continue
        if ord(ch) > 0x2E80 or ch in "，。！？：；、（）「」【】《》…—·":
            w += 1.0
        else:
            w += 0.52
    return w * size + (letter_spacing * len(text))
