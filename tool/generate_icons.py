from pathlib import Path

from PIL import Image, ImageDraw

BACKGROUND = (14, 20, 33, 255)
HOUSE = (242, 181, 68, 255)
HOUSE_OUTLINE = [(0.50, 0.08), (0.96, 0.50), (0.84, 0.50), (0.84, 0.92), (0.16, 0.92), (0.16, 0.50), (0.04, 0.50)]
CHIMNEY = (0.66, 0.14, 0.78, 0.40)
DOOR = (0.41, 0.60, 0.59, 0.92)
SCALE = 8
WEB = Path(__file__).resolve().parent.parent / 'web'


def draw_icon(size, inset, corner, full_bleed=False):
    big = size * SCALE
    image = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    if full_bleed:
        draw.rectangle((0, 0, big, big), fill=BACKGROUND)
    else:
        draw.rounded_rectangle((0, 0, big - 1, big - 1), radius=corner * big, fill=BACKGROUND)
    span = big * (1 - 2 * inset)
    origin = big * inset

    def point(x, y):
        return origin + x * span, origin + y * span

    draw.polygon([point(x, y) for x, y in HOUSE_OUTLINE], fill=HOUSE)
    draw.rectangle((*point(CHIMNEY[0], CHIMNEY[1]), *point(CHIMNEY[2], CHIMNEY[3])), fill=HOUSE)
    door_left, door_top = point(DOOR[0], DOOR[1])
    door_right, door_bottom = point(DOOR[2], DOOR[3])
    draw.rounded_rectangle(
        (door_left, door_top, door_right, door_bottom + span * 0.05),
        radius=(door_right - door_left) * 0.35,
        fill=BACKGROUND,
    )
    return image.resize((size, size), Image.LANCZOS)


draw_icon(32, 0.14, 0.22).save(WEB / 'favicon.png')
draw_icon(180, 0.18, 0.22, full_bleed=True).save(WEB / 'icons' / 'apple-touch-icon.png')
for size in (192, 512):
    draw_icon(size, 0.16, 0.22).save(WEB / 'icons' / f'Icon-{size}.png')
    draw_icon(size, 0.26, 0, full_bleed=True).save(WEB / 'icons' / f'Icon-maskable-{size}.png')
