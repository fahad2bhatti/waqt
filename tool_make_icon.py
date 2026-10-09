"""Waqt app icon: green W + gold clock arch + cream hands.
Draws everything as clean vector shapes (supersampled), no source image needed.
Outputs: assets/icon/icon.png, icon_foreground.png, icon_monochrome.png
"""
import math
import os

from PIL import Image, ImageChops, ImageDraw

SIZE = 1024
SS = 4  # supersampling for smooth edges

BG = (14, 21, 18, 255)        # AppColors.background
GREEN = (46, 158, 118, 255)   # AppColors.green
GOLD = (217, 178, 107, 255)   # AppColors.gold
CREAM = (242, 239, 230, 255)  # AppColors.textPrimary

# Mark geometry in its own coordinate space (centre ~ (340, 600)).
W_POINTS = [(132, 585), (243, 782), (340, 678), (437, 782), (548, 585)]
W_STROKE = 102
ARCH_CENTER = (340, 585)
ARCH_OUTER, ARCH_INNER = 211, 168
ARCH_FROM, ARCH_TO = 160, 20  # degrees, sweeping over the top
HUB = (340, 590)
HUB_R = 29
HAND_W = 26
HOUR_END = (340, 468)
MINUTE_END = (458, 524)
GAP = 12  # clean gap between arch and W


def make_tx(scale):
    def tx(p):
        return (
            (SIZE / 2 + scale * (p[0] - 340)) * SS,
            (SIZE / 2 + scale * (p[1] - 600)) * SS,
        )

    return tx


def blank():
    return Image.new("RGBA", (SIZE * SS, SIZE * SS), (0, 0, 0, 0))


def thick_line(draw, pts, width, fill):
    draw.line(pts, fill=fill, width=int(width), joint="curve")
    r = width / 2
    for x, y in (pts[0], pts[-1]):
        draw.ellipse((x - r, y - r, x + r, y + r), fill=fill)


def dot(draw, c, r, fill):
    draw.ellipse((c[0] - r, c[1] - r, c[0] + r, c[1] + r), fill=fill)


def arch_polygon(tx):
    cx, cy = ARCH_CENTER
    steps = 120
    angles = [ARCH_FROM + (ARCH_TO - ARCH_FROM) * i / steps for i in range(steps + 1)]
    outer = [
        tx((cx + ARCH_OUTER * math.cos(math.radians(a)),
            cy - ARCH_OUTER * math.sin(math.radians(a))))
        for a in angles
    ]
    inner = [
        tx((cx + ARCH_INNER * math.cos(math.radians(a)),
            cy - ARCH_INNER * math.sin(math.radians(a))))
        for a in reversed(angles)
    ]
    return outer + inner


def render_mark(scale, colors):
    """Returns the mark on a transparent canvas (SS-size)."""
    tx = make_tx(scale)
    w_pts = [tx(p) for p in W_POINTS]

    # Arch, with a small gap cut where the W is close to it.
    arch = blank()
    ImageDraw.Draw(arch).polygon(arch_polygon(tx), fill=colors["arch"])
    cut = Image.new("L", arch.size, 0)
    thick_line(ImageDraw.Draw(cut), w_pts, (W_STROKE + 2 * GAP) * scale * SS, 255)
    arch.putalpha(ImageChops.subtract(arch.getchannel("A"), cut))

    mark = blank()
    mark.alpha_composite(arch)
    d = ImageDraw.Draw(mark)
    thick_line(d, w_pts, W_STROKE * scale * SS, colors["w"])

    # Clock hands + hub.
    hub = tx(HUB)
    thick_line(d, [hub, tx(HOUR_END)], HAND_W * scale * SS, colors["hands"])
    thick_line(d, [hub, tx(MINUTE_END)], HAND_W * scale * SS, colors["hands"])
    dot(d, hub, HUB_R * scale * SS, colors["hands"])
    return mark


def finish(img, path):
    img.resize((SIZE, SIZE), Image.LANCZOS).save(path)


os.makedirs("assets/icon", exist_ok=True)

colors = {"w": GREEN, "arch": GOLD, "hands": CREAM}

# Adaptive foreground: transparent, artwork inside the 66% safe zone.
finish(render_mark(1.15, colors), "assets/icon/icon_foreground.png")

# Full icon for legacy launchers: background + artwork.
full = Image.new("RGBA", (SIZE * SS, SIZE * SS), BG)
full.alpha_composite(render_mark(1.25, colors))
finish(full, "assets/icon/icon.png")

# Monochrome (Android 13 themed icons): one colour, the system tints it.
white = (255, 255, 255, 255)
finish(
    render_mark(1.15, {"w": white, "arch": white, "hands": white}),
    "assets/icon/icon_monochrome.png",
)
print("icons written to assets/icon/")
