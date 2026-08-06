"""Pixel-verify screenshots for key regions."""
import json
import sys
from PIL import Image


def near(px, target, tol=28):
    return all(abs(a - b) <= tol for a, b in zip(px, target))


def sample(im, x, y):
    w, h = im.size
    sx = min(int(x / 390 * w), w - 1)
    sy = min(int(y / 844 * h), h - 1)
    return im.getpixel((sx, sy))


def region_has(im, x0, y0, x1, y1, pred, step=3):
    w, h = im.size
    for px in range(int(x0 / 390 * w), int(x1 / 390 * w), step):
        for py in range(int(y0 / 844 * h), int(y1 / 844 * h), step):
            if pred(im.getpixel((px, py))):
                return True
    return False


def count_colors(im, x0, y0, x1, y1, pred, step=3):
    w, h = im.size
    n = 0
    for px in range(int(x0 / 390 * w), int(x1 / 390 * w), step):
        for py in range(int(y0 / 844 * h), int(y1 / 844 * h), step):
            if pred(im.getpixel((px, py))):
                n += 1
    return n


def check(name, im):
    w, h = im.size
    issues = []
    # background corner sample (top area near x=10,y=50 within content)
    bg = sample(im, 6, 60)
    nonwhite = count_colors(im, 0, 0, 390, 844, lambda p: sum(p) < 720)
    print(f"  bg(6,60)={bg} nonwhite_px={nonwhite}")
    return issues


def main():
    for name in json.load(open("batches/ids.json")):
        im = Image.open(f"previews/{name}.png").convert("RGB")
        print(f"== {name} {im.size}")
        check(name, im)


if __name__ == "__main__":
    main()

