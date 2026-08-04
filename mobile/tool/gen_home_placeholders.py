#!/usr/bin/env python3
"""生成「拾染爱恋」首页占位图（纯标准库实现，无第三方依赖）。

产物（输出到 assets/images/home/）：
  avatar.png            顶部圆形头像（粉色二次元风格）
  banner_art.png        Banner 右侧拼豆作品图（透明底，爱心拼豆）
  product_kuromi.png    库洛米系列
  product_kirby.png     星之卡比系列
  product_flower.png    花花系列
  product_pet.png       可爱萌宠系列
"""
import math
import os
import struct
import zlib

OUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'assets', 'images', 'home')


def new_canvas(w, h):
    return [[[0, 0, 0, 0] for _ in range(w)] for _ in range(h)]


def blend(px, x, y, col, a=255):
    w = len(px[0])
    h = len(px)
    if x < 0 or y < 0 or x >= w or y >= h:
        return
    cur = px[y][x]
    a0 = cur[3] / 255.0
    a1 = a / 255.0
    out_a = a1 + a0 * (1 - a1)
    if out_a <= 0:
        return
    px[y][x] = [
        (col[0] * a1 + cur[0] * a0 * (1 - a1)) / out_a,
        (col[1] * a1 + cur[1] * a0 * (1 - a1)) / out_a,
        (col[2] * a1 + cur[2] * a0 * (1 - a1)) / out_a,
        out_a * 255,
    ]


def vgrad(px, top, bot):
    h = len(px)
    w = len(px[0])
    for y in range(h):
        t = y / (h - 1) if h > 1 else 0
        col = tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3))
        for x in range(w):
            px[y][x] = [col[0], col[1], col[2], 255]


def circle(px, cx, cy, r, col, a=255):
    x0, x1 = int(cx - r) - 1, int(cx + r) + 2
    y0, y1 = int(cy - r) - 1, int(cy + r) + 2
    r2 = r * r
    for y in range(y0, y1):
        for x in range(x0, x1):
            if (x - cx) ** 2 + (y - cy) ** 2 <= r2:
                blend(px, x, y, col, a)


def rect(px, x0, y0, x1, y1, col, a=255):
    for y in range(int(y0), int(y1) + 1):
        for x in range(int(x0), int(x1) + 1):
            blend(px, x, y, col, a)


def rrect(px, x0, y0, x1, y1, r, col, a=255):
    rect(px, x0 + r, y0, x1 - r, y1, col, a)
    rect(px, x0, y0 + r, x1, y1 - r, col, a)
    for cx, cy in ((x0 + r, y0 + r), (x1 - r, y0 + r), (x0 + r, y1 - r), (x1 - r, y1 - r)):
        circle(px, cx, cy, r, col, a)


def line(px, x0, y0, x1, y1, t, col, a=255):
    steps = int(max(abs(x1 - x0), abs(y1 - y0), 1))
    for i in range(steps + 1):
        tt = i / steps
        circle(px, x0 + (x1 - x0) * tt, y0 + (y1 - y0) * tt, t / 2, col, a)


def in_poly(px_, py_, pts):
    n = len(pts)
    inside = False
    j = n - 1
    for i in range(n):
        xi, yi = pts[i]
        xj, yj = pts[j]
        if ((yi > py_) != (yj > py_)) and (
            px_ < (xj - xi) * (py_ - yi) / (yj - yi) + xi
        ):
            inside = not inside
        j = i
    return inside


def poly(px, pts, col, a=255):
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]
    for y in range(int(min(ys)), int(max(ys)) + 1):
        for x in range(int(min(xs)), int(max(xs)) + 1):
            if in_poly(x, y, pts):
                blend(px, x, y, col, a)


def star(px, cx, cy, r_out, r_in, col, a=255):
    pts = []
    for i in range(10):
        ang = -math.pi / 2 + i * math.pi / 5
        rad = r_out if i % 2 == 0 else r_in
        pts.append((cx + rad * math.cos(ang), cy + rad * math.sin(ang)))
    poly(px, pts, col, a)


def write_png(path, w, h, px):
    raw = bytearray()
    for y in range(h):
        raw.append(0)  # filter: none
        for x in range(w):
            raw += bytes(
                (int(px[y][x][0]), int(px[y][x][1]), int(px[y][x][2]), int(px[y][x][3]))
            )

    def chunk(tag, data):
        return (
            struct.pack('>I', len(data))
            + tag
            + data
            + struct.pack('>I', zlib.crc32(tag + data) & 0xFFFFFFFF)
        )

    ihdr = struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0)
    png = (
        b'\x89PNG\r\n\x1a\n'
        + chunk(b'IHDR', ihdr)
        + chunk(b'IDAT', zlib.compress(bytes(raw), 9))
        + chunk(b'IEND', b'')
    )
    with open(path, 'wb') as f:
        f.write(png)


# ────────────────────────────────────────────
# 1. 头像：粉色二次元风格
# ────────────────────────────────────────────
def gen_avatar():
    W = H = 96
    px = new_canvas(W, H)
    vgrad(px, (255, 226, 236), (255, 208, 221))
    hair = (255, 143, 168)
    face = (255, 235, 216)
    # 头发 + 刘海
    circle(px, 48, 47, 33, hair)
    circle(px, 48, 32, 11, hair)
    circle(px, 33, 38, 9, hair)
    circle(px, 63, 38, 9, hair)
    # 脸蛋
    circle(px, 48, 55, 25, face)
    # 眼睛
    circle(px, 39, 55, 3, (82, 58, 70))
    circle(px, 57, 55, 3, (82, 58, 70))
    # 腮红
    circle(px, 30, 62, 4.5, (255, 158, 175), 170)
    circle(px, 66, 62, 4.5, (255, 158, 175), 170)
    # 嘴巴
    circle(px, 48, 66, 2.4, (206, 118, 132))
    # 高光
    circle(px, 40, 27, 5, (255, 255, 255), 200)
    write_png(os.path.join(OUT_DIR, 'avatar.png'), W, H, px)


# ────────────────────────────────────────────
# 2. Banner 拼豆作品：透明底爱心
# ────────────────────────────────────────────
def gen_banner_art():
    W, H = 340, 300
    px = new_canvas(W, H)
    mask = ['0110110', '1111111', '1111111', '0111110', '0011100', '0001000']
    palette = [
        (255, 113, 141), (255, 143, 168), (255, 182, 201),
        (255, 211, 222), (255, 92, 122), (252, 141, 161),
    ]
    cell = 26
    rows = len(mask)
    cols = len(mask[0])
    x0 = (W - cols * cell) // 2
    y0 = (H - rows * cell) // 2
    for ry, row in enumerate(mask):
        for cx_, ch in enumerate(row):
            if ch != '1':
                continue
            c = palette[(ry * 2 + cx_ * 3) % len(palette)]
            cx, cy = x0 + cx_ * cell + cell / 2, y0 + ry * cell + cell / 2
            circle(px, cx, cy, cell / 2 - 2.5, c)
            circle(px, cx - 3.5, cy - 3.5, 3, (255, 255, 255), 200)
    # 散落的零散豆子
    loose = [(52, 70, 5), (286, 84, 6), (62, 232, 6), (282, 214, 5), (170, 30, 5), (286, 150, 4)]
    for cx, cy, r in loose:
        circle(px, cx, cy, r, palette[(cx + cy) % len(palette)], 235)
    write_png(os.path.join(OUT_DIR, 'banner_art.png'), W, H, px)


# ────────────────────────────────────────────
# 3. 库洛米系列
# ────────────────────────────────────────────
def gen_kuromi():
    W = H = 240
    px = new_canvas(W, H)
    vgrad(px, (96, 80, 142), (58, 46, 92))
    white = (246, 242, 251)
    pink = (255, 150, 168)
    # 耳朵
    poly(px, [(86, 104), (60, 46), (110, 76)], white)
    poly(px, [(154, 104), (180, 46), (130, 76)], white)
    poly(px, [(86, 96), (70, 62), (102, 82)], pink)
    poly(px, [(154, 96), (170, 62), (138, 82)], pink)
    # 脸
    circle(px, 120, 130, 54, white)
    # 眼睛
    circle(px, 100, 126, 8, (70, 56, 78))
    circle(px, 140, 126, 8, (70, 56, 78))
    # 腮红
    circle(px, 86, 144, 6, pink, 150)
    circle(px, 154, 144, 6, pink, 150)
    # 嘴巴（小 w 形）
    line(px, 112, 156, 120, 161, 3, (150, 110, 130))
    line(px, 120, 161, 128, 156, 3, (150, 110, 130))
    write_png(os.path.join(OUT_DIR, 'product_kuromi.png'), W, H, px)


# ────────────────────────────────────────────
# 4. 星之卡比系列
# ────────────────────────────────────────────
def gen_kirby():
    W = H = 240
    px = new_canvas(W, H)
    vgrad(px, (255, 233, 238), (255, 209, 222))
    body = (255, 159, 189)
    dark = (86, 68, 82)
    # 脚
    circle(px, 102, 178, 13, (255, 142, 163))
    circle(px, 138, 178, 13, (255, 142, 163))
    # 身体
    circle(px, 120, 118, 62, body)
    # 眼睛
    circle(px, 101, 114, 7, dark)
    circle(px, 139, 114, 7, dark)
    # 腮红
    circle(px, 88, 132, 6, (255, 128, 152), 160)
    circle(px, 152, 132, 6, (255, 128, 152), 160)
    # 嘴巴
    circle(px, 120, 136, 3.2, (150, 104, 122))
    # 金色星星
    star(px, 200, 48, 18, 7, (255, 213, 79))
    star(px, 40, 46, 9, 4, (255, 213, 79), 230)
    write_png(os.path.join(OUT_DIR, 'product_kirby.png'), W, H, px)


# ────────────────────────────────────────────
# 5. 花花系列
# ────────────────────────────────────────────
def gen_flower():
    W = H = 240
    px = new_canvas(W, H)
    vgrad(px, (255, 247, 240), (255, 233, 224))
    petal_colors = [
        (255, 159, 189), (255, 190, 214), (214, 186, 255),
        (255, 209, 178), (255, 190, 214), (255, 159, 189),
    ]
    # 花瓣
    for i in range(6):
        ang = math.pi / 6 + i * math.pi / 3
        cx = 120 + 34 * math.cos(ang)
        cy = 118 + 34 * math.sin(ang)
        circle(px, cx, cy, 19, petal_colors[i])
    # 花心
    circle(px, 120, 118, 21, (255, 213, 79))
    circle(px, 113, 111, 4, (255, 244, 200), 200)
    # 叶子
    circle(px, 66, 184, 11, (196, 232, 196))
    circle(px, 174, 184, 11, (196, 232, 196))
    write_png(os.path.join(OUT_DIR, 'product_flower.png'), W, H, px)


# ────────────────────────────────────────────
# 6. 可爱萌宠系列（橘猫）
# ────────────────────────────────────────────
def gen_pet():
    W = H = 240
    px = new_canvas(W, H)
    vgrad(px, (255, 244, 238), (255, 228, 214))
    head = (255, 214, 178)
    ear = (255, 201, 162)
    dark = (110, 84, 70)
    # 耳朵
    poly(px, [(78, 100), (48, 38), (106, 70)], ear)
    poly(px, [(162, 100), (192, 38), (134, 70)], ear)
    poly(px, [(80, 92), (62, 58), (100, 78)], (255, 172, 152))
    poly(px, [(160, 92), (178, 58), (140, 78)], (255, 172, 152))
    # 头
    circle(px, 120, 130, 55, head)
    # 斑纹
    line(px, 112, 82, 120, 90, 5, (232, 178, 140), 160)
    line(px, 128, 82, 120, 90, 5, (232, 178, 140), 160)
    # 眼睛
    circle(px, 100, 124, 7, dark)
    circle(px, 140, 124, 7, dark)
    # 鼻子 / 嘴
    poly(px, [(120, 138), (114, 145), (126, 145)], (255, 150, 150))
    line(px, 120, 145, 111, 152, 2.6, dark)
    line(px, 120, 145, 129, 152, 2.6, dark)
    # 胡须
    line(px, 62, 124, 94, 130, 2, (205, 162, 140), 200)
    line(px, 62, 142, 94, 138, 2, (205, 162, 140), 200)
    line(px, 178, 124, 146, 130, 2, (205, 162, 140), 200)
    line(px, 178, 142, 146, 138, 2, (205, 162, 140), 200)
    # 腮红
    circle(px, 84, 138, 5, (255, 172, 152), 170)
    circle(px, 156, 138, 5, (255, 172, 152), 170)
    write_png(os.path.join(OUT_DIR, 'product_pet.png'), W, H, px)


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    gen_avatar()
    gen_banner_art()
    gen_kuromi()
    gen_kirby()
    gen_flower()
    gen_pet()
    print('生成完成 →', os.path.abspath(OUT_DIR))


if __name__ == '__main__':
    main()
