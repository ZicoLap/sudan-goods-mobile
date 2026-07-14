"""Remove solid white / checkerboard backgrounds from illustration PNGs."""

from __future__ import annotations

import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    raise SystemExit("Pillow required: pip install Pillow")


def _alpha_for_pixel(r: int, g: int, b: int) -> int:
    """Return 0 (transparent) to 255 (opaque) for background-like pixels."""
    brightness = (r + g + b) / 3
    max_c = max(r, g, b)
    min_c = min(r, g, b)
    saturation = 0 if max_c == 0 else (max_c - min_c) / max_c

    # Pure/near-white background
    if r >= 248 and g >= 248 and b >= 248:
        return 0

    # Light gray checkerboard tiles (low saturation, high brightness)
    if brightness >= 210 and saturation <= 0.08:
        return 0

    # Soft anti-aliased edges between subject and white bg
    if brightness >= 235 and saturation <= 0.12:
        fade = int((255 - brightness) * 18)
        return max(0, min(255, fade))

    return 255


def remove_background(input_path: Path, output_path: Path) -> None:
    img = Image.open(input_path).convert("RGBA")
    pixels = img.load()
    width, height = img.size

    for y in range(height):
        for x in range(width):
            r, g, b, _ = pixels[x, y]
            alpha = _alpha_for_pixel(r, g, b)
            pixels[x, y] = (r, g, b, alpha)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    img.save(output_path, "PNG", optimize=True)
    print(f"Saved {output_path}")


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    assets = root / "assets" / "order"
    src_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else assets

    pairs = [
        ("order_success_confirmed_v2.png", "order_success_confirmed.png"),
        ("order_success_pending_v2.png", "order_success_pending.png"),
    ]

    for src_name, dst_name in pairs:
        src = src_dir / src_name
        if not src.exists():
            # Try cursor generated path
            alt = Path(
                r"C:\Users\Besitzer\.cursor\projects"
                r"\c-Users-Besitzer-Desktop-sudan-goods-mobile\assets"
            ) / src_name
            src = alt if alt.exists() else src
        if not src.exists():
            print(f"Skip missing: {src_name}")
            continue
        remove_background(src, assets / dst_name)


if __name__ == "__main__":
    main()
