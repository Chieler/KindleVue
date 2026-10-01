#!/usr/bin/env python3
"""
Generates AppIcon.icns from PapershadeIcon.png and StatusIcon assets from
PapershadeStatus.png.
"""
import os
import io
import struct
import numpy as np
from PIL import Image, ImageDraw

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
K_SRC = os.path.join(SCRIPT_DIR, "PapershadeIcon.png")
K1_SRC = os.path.join(SCRIPT_DIR, "PapershadeStatus.png")

def build_app_icon():
    print("Building AppIcon.icns from PapershadeIcon.png...")
    src = Image.open(K_SRC).convert("RGBA")
    hi_size = 4096
    src_hi = src.resize((hi_size, hi_size), Image.Resampling.LANCZOS)

    # Standard macOS squircle mask (corner radius ~22.5%)
    mask_hi = Image.new("L", (hi_size, hi_size), 0)
    draw_hi = ImageDraw.Draw(mask_hi)
    draw_hi.rounded_rectangle([(0, 0), (hi_size - 1, hi_size - 1)], radius=920, fill=255)
    src_hi.putalpha(mask_hi)

    # Subtle border outline so white icon has clear definition on white/light backgrounds
    border_draw = ImageDraw.Draw(src_hi)
    border_draw.rounded_rectangle([(0, 0), (hi_size - 1, hi_size - 1)], radius=920, outline=(0, 0, 0, 30), width=6)

    icns_out = os.path.join(SCRIPT_DIR, "AppIcon.icns")
    # Package PNG renditions in an ICNS container directly. This avoids the
    # platform icon encoders, which can reject valid iconsets in sandboxed
    # environments. The chunk IDs are Apple's standard PNG-based ICNS types.
    renditions = [
        (b"icp4", 16), (b"icp5", 32), (b"icp6", 64),
        (b"ic07", 128), (b"ic08", 256), (b"ic09", 512),
        (b"ic10", 1024),
    ]
    chunks = []
    for chunk_type, size in renditions:
        image = src_hi.resize((size, size), Image.Resampling.LANCZOS)
        png = io.BytesIO()
        image.save(png, format="PNG")
        payload = png.getvalue()
        chunks.append(struct.pack(">4sI", chunk_type, len(payload) + 8) + payload)

    payload = b"".join(chunks)
    with open(icns_out, "wb") as icns_file:
        icns_file.write(struct.pack(">4sI", b"icns", len(payload) + 8))
        icns_file.write(payload)
    print(f"Generated {icns_out}")

def build_status_icon():
    print("Building StatusIcon assets from PapershadeStatus.png...")
    src = Image.open(K1_SRC)
    bbox = src.getbbox()
    cropped = src.crop(bbox).convert("RGBA")

    # Template image standard: RGB=(0,0,0), alpha preserved
    arr = np.array(cropped)
    arr[:, :, :3] = 0
    template_master = Image.fromarray(arr)

    # Standard menu bar dimensions (18pt height, 15pt width matching aspect ratio)
    icon_1x = template_master.resize((15, 18), Image.Resampling.LANCZOS)
    icon_2x = template_master.resize((30, 36), Image.Resampling.LANCZOS)

    p_1x = os.path.join(SCRIPT_DIR, "StatusIcon.png")
    p_2x = os.path.join(SCRIPT_DIR, "StatusIcon@2x.png")
    icon_1x.save(p_1x, dpi=(72, 72))
    icon_2x.save(p_2x, dpi=(144, 144))
    print(f"Generated {p_1x} and {p_2x}")

if __name__ == "__main__":
    build_app_icon()
    build_status_icon()
