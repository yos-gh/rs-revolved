from __future__ import annotations

import argparse
from pathlib import Path
from xml.sax.saxutils import escape

from PIL import Image


def color_to_hex(pixel: tuple[int, int, int, int]) -> str:
    r, g, b, _a = pixel
    return f"#{r:02x}{g:02x}{b:02x}"


def convert_bmp_to_svg(
    src: Path,
    dst: Path,
    transparent: list[tuple[int, int, int]],
    transparent_from_top_left: bool,
    excluded_boxes: list[tuple[int, int, int, int]],
    append_svg: Path | None,
) -> None:
    image = Image.open(src).convert("RGBA")
    width, height = image.size
    transparent_colors = set(transparent)
    if transparent_from_top_left:
        top_left = image.getpixel((0, 0))
        transparent_colors.add((top_left[0], top_left[1], top_left[2]))
    transparent_rgba = {(*color, 255) for color in transparent_colors}

    def excluded(x: int, y: int) -> bool:
        return any(left <= x < left + box_width and top <= y < top + box_height for left, top, box_width, box_height in excluded_boxes)

    rects: list[str] = []
    pixels = image.load()
    for y in range(height):
        x = 0
        while x < width:
            color = pixels[x, y]
            if color in transparent_rgba or excluded(x, y):
                x += 1
                continue
            start = x
            x += 1
            while x < width and pixels[x, y] == color and not excluded(x, y):
                x += 1
            rects.append(
                f'<rect x="{start}" y="{y}" width="{x - start}" height="1" fill="{color_to_hex(color)}"/>'
            )

    title = escape(src.name)
    svg = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}" shape-rendering="crispEdges">',
        f"<title>{title}</title>",
        *rects,
        append_svg.read_text(encoding="utf-8") if append_svg else "",
        "</svg>",
        "",
    ]
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text("\n".join(svg), encoding="utf-8", newline="\n")


def parse_rgb(value: str) -> tuple[int, int, int]:
    parts = value.split(",")
    if len(parts) != 3:
        raise argparse.ArgumentTypeError("RGB must be formatted as R,G,B")
    rgb = tuple(int(part) for part in parts)
    if any(part < 0 or part > 255 for part in rgb):
        raise argparse.ArgumentTypeError("RGB values must be in the 0-255 range")
    return rgb


def parse_box(value: str) -> tuple[int, int, int, int]:
    parts = tuple(int(part) for part in value.split(","))
    if len(parts) != 4 or parts[2] <= 0 or parts[3] <= 0:
        raise argparse.ArgumentTypeError("box must be formatted as X,Y,WIDTH,HEIGHT with a positive size")
    return parts


def main() -> None:
    parser = argparse.ArgumentParser(description="Convert low-color BMP pixel art to run-length SVG.")
    parser.add_argument("src", type=Path)
    parser.add_argument("dst", type=Path)
    parser.add_argument("--transparent", type=parse_rgb, action="append", default=[])
    parser.add_argument("--transparent-from-top-left", action="store_true")
    parser.add_argument("--exclude-box", type=parse_box, action="append", default=[])
    parser.add_argument("--append-svg", type=Path, default=None)
    args = parser.parse_args()
    convert_bmp_to_svg(args.src, args.dst, args.transparent, args.transparent_from_top_left, args.exclude_box, args.append_svg)


if __name__ == "__main__":
    main()
