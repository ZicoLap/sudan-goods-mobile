"""Remove cream/light backgrounds from onboarding PNGs using edge flood fill."""

from __future__ import annotations

import math
import sys
from collections import deque
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "assets" / "onboarding"

SOURCE_CANDIDATES = {
    "language_welcome.png": [
        ROOT / "assets" / "language_welcome.png",
        OUT_DIR / "language_welcome.png",
    ],
    "onb_01_welcome.png": [
        ROOT / "assets" / "onb_01_welcome.png",
        OUT_DIR / "onb_01_welcome.png",
    ],
    "onb_02_order.png": [
        ROOT / "assets" / "onb_02_order.png",
        OUT_DIR / "onb_02_order.png",
    ],
    "onb_03_discover.png": [
        ROOT / "assets" / "onb_03_discover.png",
        OUT_DIR / "onb_03_discover.png",
    ],
    "onb_04_start.png": [
        ROOT / "assets" / "onb_04_start.png",
        OUT_DIR / "onb_04_start.png",
    ],
}


def resolve_source(name: str) -> Path:
    for path in SOURCE_CANDIDATES[name]:
        if path.exists():
            return path
    raise FileNotFoundError(f"No source found for {name}")


def _color_distance(a: tuple[int, int, int], b: tuple[int, int, int]) -> float:
    return math.sqrt(sum((a[i] - b[i]) ** 2 for i in range(3)))


def _is_background_pixel(
    rgb: tuple[int, int, int],
    reference: tuple[int, int, int],
    tolerance: float,
) -> bool:
    r, g, b = rgb
    if r > 238 and g > 232 and b > 220:
        return True
    return _color_distance(rgb, reference) <= tolerance


def remove_background(image: Image.Image, tolerance: float = 42.0) -> Image.Image:
    rgba = image.convert("RGBA")
    width, height = rgba.size
    pixels = rgba.load()

    corners = [
        pixels[0, 0][:3],
        pixels[width - 1, 0][:3],
        pixels[0, height - 1][:3],
        pixels[width - 1, height - 1][:3],
    ]
    reference = tuple(sum(color[i] for color in corners) // 4 for i in range(3))

    visited: set[tuple[int, int]] = set()
    queue: deque[tuple[int, int]] = deque()

    for x in range(width):
        queue.append((x, 0))
        queue.append((x, height - 1))
    for y in range(height):
        queue.append((0, y))
        queue.append((width - 1, y))

    while queue:
        x, y = queue.popleft()
        if (x, y) in visited:
            continue
        if x < 0 or x >= width or y < 0 or y >= height:
            continue

        visited.add((x, y))
        r, g, b, _ = pixels[x, y]
        if not _is_background_pixel((r, g, b), reference, tolerance):
            continue

        pixels[x, y] = (r, g, b, 0)
        queue.extend([(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)])

    bbox = rgba.getbbox()
    if bbox is not None:
        rgba = rgba.crop(bbox)
    return rgba


def process(name: str) -> None:
    source = resolve_source(name)
    output = OUT_DIR / name
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    image = remove_background(Image.open(source))
    image.save(output, format="PNG", optimize=True)
    print(f"Wrote {output} ({image.size[0]}x{image.size[1]})")


def main() -> int:
    for name in SOURCE_CANDIDATES:
        process(name)
    return 0


if __name__ == "__main__":
    sys.exit(main())
