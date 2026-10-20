"""Pack a light and a dark wallpaper into one macOS Dynamic Desktop HEIC.

macOS shows the light image from 07:00 to 19:00 and the dark one otherwise
when the wallpaper is set to "Dynamic", and follows Light/Dark mode when it
is set to "Automatic". The schedule lives in Apple's apple_desktop:h24 XMP
tag, a base64 binary plist.

    python3 tools/dynamic-desktop.py LIGHT.png DARK.png OUT.heic

Needs pillow-heif.
"""

import base64
import plistlib
import sys

import pillow_heif
from PIL import Image

pillow_heif.register_heif_opener()


def xmp(light_from=7 / 24, dark_from=19 / 24):
    h24 = {
        "ap": {"l": 0, "d": 1},
        "ti": [{"t": light_from, "i": 0}, {"t": dark_from, "i": 1}],
    }
    b64 = base64.b64encode(plistlib.dumps(h24, fmt=plistlib.FMT_BINARY)).decode()
    return (
        '<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="XMP Core 6.0.0">'
        '<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">'
        '<rdf:Description rdf:about="" '
        'xmlns:apple_desktop="http://ns.apple.com/namespace/1.0/" '
        f'apple_desktop:h24="{b64}"/>'
        "</rdf:RDF></x:xmpmeta>"
    ).encode()


def main(light, dark, out):
    a, b = (Image.open(p).convert("RGB") for p in (light, dark))
    a.save(out, format="HEIF", quality=90, save_all=True, append_images=[b], xmp=xmp())


if __name__ == "__main__":
    main(*sys.argv[1:4])
