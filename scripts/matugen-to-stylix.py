#!/usr/bin/env python3
"""Map Matugen's dark Material palette to Stylix's Base16 colors."""

import colorsys
import json
import sys


def plain(color):
    return color.removeprefix("#").lower()


def accent(color, hue_shift, saturation, lightness):
    red, green, blue = (
        int(color[index : index + 2], 16) / 255 for index in (1, 3, 5)
    )
    hue, _, _ = colorsys.rgb_to_hls(red, green, blue)
    red, green, blue = colorsys.hls_to_rgb(
        (hue + hue_shift / 360) % 1, lightness, saturation
    )
    return "".join(f"{round(channel * 255):02x}" for channel in (red, green, blue))


with open(sys.argv[1], encoding="utf-8") as source:
    material = json.load(source)


def role(name):
    return plain(material["colors"][name]["dark"])


primary = material["colors"]["primary"]["dark"]
scheme = {
    "scheme": "Matugen wallpaper",
    "author": "Matugen",
    "base00": role("surface"),
    "base01": role("surface_container_low"),
    "base02": role("surface_container_high"),
    "base03": role("outline"),
    "base04": role("on_surface_variant"),
    "base05": role("on_surface"),
    "base06": plain(material["palettes"]["neutral"]["95"]),
    "base07": plain(material["palettes"]["neutral"]["98"]),
    "base08": role("error"),
    # Base16 needs more syntax accents than Material's three accent roles.
    # These hue shifts keep them tied to the wallpaper's generated primary.
    "base09": accent(primary, 0, 0.81, 0.73),
    "base0A": accent(primary, 34, 1, 0.72),
    "base0B": accent(primary, 93, 1, 0.75),
    "base0C": role("tertiary"),
    "base0D": role("primary"),
    "base0E": role("secondary"),
    "base0F": accent(primary, -13, 1, 0.81),
}
json.dump(scheme, sys.stdout, sort_keys=True)
