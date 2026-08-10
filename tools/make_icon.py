#!/usr/bin/env python3
"""Generate the launcher icon: a knight silhouette in the app's palette.

Written against the standard library only — the build machine has no Pillow
or ImageMagick, and pulling one in for a single static asset isn't worth it.
PNG is a simple enough container to emit directly.

The knight is a polygon, filled with a scanline rasteriser at 4x supersample
and box-downsampled for antialiasing. `--preview` prints an ASCII rendering
so the silhouette can be checked without opening the file.

Outputs:
  assets/icon/app_icon.png             1024px, walnut background
  assets/icon/app_icon_foreground.png  1024px, transparent, adaptive-icon
                                       safe zone (content within centre 66%)
"""
import argparse
import struct
import zlib
from pathlib import Path

WALNUT = (0x3B, 0x2A, 0x20)
CREAM = (0xE8, 0xDC, 0xC4)
BRASS = (0xB8, 0x89, 0x3B)

SS = 4  # supersample factor

# Knight facing left, in a 0..100 box. Traced clockwise from the base's
# bottom-left: base, up the back, over the mane, both ears, down the face to
# the muzzle, back along the jaw and chest.
KNIGHT = [
    (20, 95), (82, 95), (82, 84), (70, 84),
    (68, 72), (71, 59), (72, 46), (68, 34),
    (63, 24), (60, 12), (53, 24), (48, 11),
    (41, 27), (29, 31), (19, 39), (11, 49),
    (7, 58), (12, 67), (26, 72), (36, 78),
    (43, 83), (35, 89), (27, 93),
]


def fill_polygon(points, size):
    """Scanline-fill a polygon into a coverage bytearray (0/255), size x size."""
    n = size * SS
    scaled = [(x / 100.0 * n, y / 100.0 * n) for x, y in points]
    cov = bytearray(n * n)

    edges = []
    for i in range(len(scaled)):
        x0, y0 = scaled[i]
        x1, y1 = scaled[(i + 1) % len(scaled)]
        if y0 != y1:
            edges.append((x0, y0, x1, y1))

    for py in range(n):
        yc = py + 0.5
        xs = []
        for x0, y0, x1, y1 in edges:
            if (y0 <= yc < y1) or (y1 <= yc < y0):
                t = (yc - y0) / (y1 - y0)
                xs.append(x0 + t * (x1 - x0))
        if not xs:
            continue
        xs.sort()
        row = py * n
        for i in range(0, len(xs) - 1, 2):
            a = max(0, int(xs[i] + 0.5))
            b = min(n, int(xs[i + 1] + 0.5))
            if b > a:
                cov[row + a:row + b] = b"\xff" * (b - a)
    return cov, n


def downsample(cov, n, size):
    """Box-downsample the SSxSS supersample into per-pixel alpha 0..255."""
    out = bytearray(size * size)
    area = SS * SS
    for y in range(size):
        base = y * SS
        for x in range(size):
            total = 0
            bx = x * SS
            for dy in range(SS):
                row = (base + dy) * n + bx
                total += sum(cov[row:row + SS])
            out[y * size + x] = total // area
    return out


def write_png(path, size, rgba):
    raw = bytearray()
    stride = size * 4
    for y in range(size):
        raw.append(0)
        raw += rgba[y * stride:(y + 1) * stride]

    def chunk(typ, data):
        return (struct.pack(">I", len(data)) + typ + data
                + struct.pack(">I", zlib.crc32(typ + data) & 0xFFFFFFFF))

    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    png += chunk(b"IEND", b"")
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    Path(path).write_bytes(png)


def inset(points, factor):
    """Shrink toward the centre — adaptive icons crop to a circle, so the
    foreground layer needs its content inside the middle ~66%."""
    return [(50 + (x - 50) * factor, 50 + (y - 50) * factor) for x, y in points]


def compose(alpha, size, fg, bg):
    """Composite a single-colour shape over a background (bg=None → transparent)."""
    out = bytearray(size * size * 4)
    for i in range(size * size):
        a = alpha[i]
        o = i * 4
        if bg is None:
            out[o:o + 3] = bytes(fg)
            out[o + 3] = a
        else:
            for c in range(3):
                out[o + c] = (fg[c] * a + bg[c] * (255 - a)) // 255
            out[o + 3] = 255
    return out


def preview(alpha, size, cols=46):
    ramp = " .:-=+*#%@"
    step = size // cols
    lines = []
    for y in range(0, size - step + 1, step * 2):
        line = ""
        for x in range(0, size - step + 1, step):
            total = sum(
                alpha[(y + dy) * size + x + dx]
                for dy in range(0, step, max(1, step // 2))
                for dx in range(0, step, max(1, step // 2))
            )
            count = len(range(0, step, max(1, step // 2))) ** 2
            line += ramp[min(len(ramp) - 1, (total // count) * len(ramp) // 256)]
        lines.append(line)
    return "\n".join(lines)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--preview", action="store_true")
    ap.add_argument("--size", type=int, default=1024)
    args = ap.parse_args()

    root = Path(__file__).resolve().parent.parent

    # Main icon: knight at full bleed over walnut.
    cov, n = fill_polygon(KNIGHT, args.size)
    alpha = downsample(cov, n, args.size)

    if args.preview:
        print(preview(alpha, args.size))
        return

    write_png(root / "assets/icon/app_icon.png", args.size,
              compose(alpha, args.size, CREAM, WALNUT))

    # Adaptive foreground: same knight, inset into the safe zone, transparent.
    cov_fg, n_fg = fill_polygon(inset(KNIGHT, 0.62), args.size)
    alpha_fg = downsample(cov_fg, n_fg, args.size)
    write_png(root / "assets/icon/app_icon_foreground.png", args.size,
              compose(alpha_fg, args.size, CREAM, None))

    print("wrote assets/icon/app_icon.png and app_icon_foreground.png")


if __name__ == "__main__":
    main()
