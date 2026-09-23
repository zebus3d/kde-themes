#!/usr/bin/env python3
"""Generate the DarkOne (Enlightenment 16) Aurorae window decoration for Plasma 6.

Colours sampled from the original e16 artwork (artwork/border, artwork/windowbutton):
  titlebar inactive : #343434 -> #2c2c2c, top highlight #696969, bottom #080808
  titlebar active   : #a41313 -> #920d0d, top highlight #a11212, bottom #6d0f0f
  frame left bevel  : #000000 / #6a6a6a / #545454 / #3a3a3a / #000000
  frame right+bottom: #000000 / #191919 / #191919 / #3a3a3a / #000000
  button raised     : #7e7e7e highlight, #545454 -> #444444, #151515 shadow, glyph #b4b4b4
"""
import os

OUT = os.path.expanduser("~/.local/share/aurorae/themes/DarkOne")
os.makedirs(OUT, exist_ok=True)

NAME = "DarkOne"

# The real DarkOne e16 border maps titlebar.png (dark grey) to *every* state,
# active included; titlebar_r.png (red) is only used for epplets. So active and
# inactive windows share the same frame. Flip this to True for a red active bar.
ACTIVE_IS_RED = False

# ---------------------------------------------------------------- decoration
L, T, B, MID = 5, 22, 5, 50          # left/right, top, bottom, middle tile length
ACT_TOP, ACT_BOT = "#a41313", "#920d0d"
INA_TOP, INA_BOT = "#343434", "#2c2c2c"


def deco_set(prefix, active, ox, oy):
    """Return the 9 decoration elements for one state, translated by (ox, oy)."""
    red = active and ACTIVE_IS_RED
    g = "gradTitleActive" if red else "gradTitleInactive"
    hi = "#a11212" if red else "#6a6a6a"
    b1 = "#7d0f0f" if red else "#4a4a4a"
    edge = "#080808"                       # canto inferior del titulo (casi negro, como el original)
    # bevel rings, outer -> inner.  left/top are the lit side, right/bottom the shade.
    l1, l2, l3, l4 = "#6a6a6a", "#545454", "#3a3a3a", "#1a1a1a"
    r1, r2, r3, r4 = "#5a5a5a", "#464646", "#333333", "#1a1a1a"
    p = f"{prefix}-"
    s = []

    # top-left corner (L x T): concentric L rings, like the bottom corners, so
    # the vertical bevel and the top bevel join without a step. The top bevel is
    # 3 px (l1/l2/l3) to match the side bevels, as in the E16 original.
    s.append(f'''    <g id="{p}topleft" transform="translate({ox},{oy})">
      <rect x="0" y="0" width="{L}" height="{T}" fill="#000000"/>
      <rect x="1" y="1" width="{L-1}" height="{T-2}" fill="url(#{g})"/>
      <rect x="1" y="1" width="1" height="{T-2}" fill="{l1}"/>
      <rect x="2" y="2" width="1" height="{T-3}" fill="{l2}"/>
      <rect x="3" y="3" width="1" height="{T-4}" fill="{l3}"/>
      <rect x="1" y="1" width="{L-1}" height="1" fill="{l1}"/>
      <rect x="2" y="2" width="{L-2}" height="1" fill="{l2}"/>
      <rect x="3" y="3" width="{L-3}" height="1" fill="{l3}"/>
      <rect x="1" y="{T-1}" width="{L-1}" height="1" fill="{edge}"/>
    </g>''')

    # top (MID x T): plain titlebar strip, 3 px bevel like the sides
    s.append(f'''    <g id="{p}top" transform="translate({ox + L},{oy})">
      <rect x="0" y="0" width="{MID}" height="{T}" fill="#000000"/>
      <rect x="0" y="1" width="{MID}" height="{T-2}" fill="url(#{g})"/>
      <rect x="0" y="1" width="{MID}" height="1" fill="{l1}"/>
      <rect x="0" y="2" width="{MID}" height="1" fill="{l2}"/>
      <rect x="0" y="3" width="{MID}" height="1" fill="{l3}"/>
      <rect x="0" y="{T-1}" width="{MID}" height="1" fill="{edge}"/>
    </g>''')

    # top-right corner (L x T): concentric L rings, lit top / shaded right
    s.append(f'''    <g id="{p}topright" transform="translate({ox + L + MID},{oy})">
      <rect x="0" y="0" width="{L}" height="{T}" fill="#000000"/>
      <rect x="0" y="1" width="{L-1}" height="{T-2}" fill="url(#{g})"/>
      <rect x="{L-2}" y="1" width="1" height="{T-2}" fill="{r1}"/>
      <rect x="{L-3}" y="2" width="1" height="{T-3}" fill="{r2}"/>
      <rect x="{L-4}" y="3" width="1" height="{T-4}" fill="{r3}"/>
      <rect x="0" y="1" width="{L-1}" height="1" fill="{l1}"/>
      <rect x="0" y="2" width="{L-2}" height="1" fill="{l2}"/>
      <rect x="0" y="3" width="{L-3}" height="1" fill="{l3}"/>
      <rect x="0" y="{T-1}" width="{L-1}" height="1" fill="{edge}"/>
    </g>''')

    # left (L x MID)
    s.append(f'''    <g id="{p}left" transform="translate({ox},{oy + T})">
      <rect x="0" y="0" width="{L}" height="{MID}" fill="#000000"/>
      <rect x="1" y="0" width="1" height="{MID}" fill="{l1}"/>
      <rect x="2" y="0" width="1" height="{MID}" fill="{l2}"/>
      <rect x="3" y="0" width="1" height="{MID}" fill="{l3}"/>
      <rect x="4" y="0" width="1" height="{MID}" fill="{l4}"/>
    </g>''')

    # center
    s.append(f'''    <g id="{p}center" transform="translate({ox + L},{oy + T})">
      <rect x="0" y="0" width="{MID}" height="{MID}" fill="#000000"/>
    </g>''')

    # right (L x MID)
    s.append(f'''    <g id="{p}right" transform="translate({ox + L + MID},{oy + T})">
      <rect x="0" y="0" width="{L}" height="{MID}" fill="#000000"/>
      <rect x="0" y="0" width="1" height="{MID}" fill="{r4}"/>
      <rect x="1" y="0" width="1" height="{MID}" fill="{r3}"/>
      <rect x="2" y="0" width="1" height="{MID}" fill="{r2}"/>
      <rect x="3" y="0" width="1" height="{MID}" fill="{r1}"/>
    </g>''')

    # bottom-left (L x B): mitered join.
    # top row = left border columns, right column = bottom border rows,
    # so the corner empalma exacto con los dos bordes (sin pico ni escalon).
    s.append(f'''    <g id="{p}bottomleft" transform="translate({ox},{oy + T + MID})">
      <rect x="0" y="0" width="{L}" height="{B}" fill="#000000"/>
      <rect x="1" y="0" width="1" height="1" fill="{l1}"/>
      <rect x="2" y="0" width="1" height="1" fill="{l2}"/>
      <rect x="3" y="0" width="1" height="1" fill="{l3}"/>
      <rect x="4" y="0" width="1" height="1" fill="{l4}"/>
      <rect x="1" y="1" width="1" height="1" fill="{l1}"/>
      <rect x="2" y="1" width="1" height="1" fill="{l2}"/>
      <rect x="3" y="1" width="2" height="1" fill="{r3}"/>
      <rect x="1" y="2" width="1" height="1" fill="{l1}"/>
      <rect x="2" y="2" width="3" height="1" fill="{r2}"/>
      <rect x="1" y="3" width="4" height="1" fill="{r1}"/>
    </g>''')

    # bottom (MID x B)
    s.append(f'''    <g id="{p}bottom" transform="translate({ox + L},{oy + T + MID})">
      <rect x="0" y="0" width="{MID}" height="{B}" fill="#000000"/>
      <rect x="0" y="0" width="{MID}" height="1" fill="{r4}"/>
      <rect x="0" y="1" width="{MID}" height="1" fill="{r3}"/>
      <rect x="0" y="2" width="{MID}" height="1" fill="{r2}"/>
      <rect x="0" y="3" width="{MID}" height="1" fill="{r1}"/>
    </g>''')

    # bottom-right (L x B): mitered join (mirror)
    s.append(f'''    <g id="{p}bottomright" transform="translate({ox + L + MID},{oy + T + MID})">
      <rect x="0" y="0" width="{L}" height="{B}" fill="#000000"/>
      <rect x="0" y="0" width="1" height="1" fill="{r4}"/>
      <rect x="1" y="0" width="1" height="1" fill="{r3}"/>
      <rect x="2" y="0" width="1" height="1" fill="{r2}"/>
      <rect x="3" y="0" width="1" height="1" fill="{r1}"/>
      <rect x="0" y="1" width="2" height="1" fill="{r3}"/>
      <rect x="2" y="1" width="1" height="1" fill="{r2}"/>
      <rect x="3" y="1" width="1" height="1" fill="{r1}"/>
      <rect x="0" y="2" width="3" height="1" fill="{r2}"/>
      <rect x="3" y="2" width="1" height="1" fill="{r1}"/>
      <rect x="0" y="3" width="4" height="1" fill="{r1}"/>
    </g>''')

    return "\n".join(s)


DECO = f'''<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg xmlns="http://www.w3.org/2000/svg" width="220" height="100" version="1.1">
  <defs>
    <linearGradient id="gradTitleActive" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="{ACT_TOP}"/>
      <stop offset="1" stop-color="{ACT_BOT}"/>
    </linearGradient>
    <linearGradient id="gradTitleInactive" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="{INA_TOP}"/>
      <stop offset="1" stop-color="{INA_BOT}"/>
    </linearGradient>
  </defs>

{deco_set("decoration", True, 0, 0)}

{deco_set("decoration-inactive", False, 110, 0)}

  <rect id="decoration-maximized-center"          x="200" y="55" width="5" height="5" fill="#2f2f2f"/>
  <rect id="decoration-maximized-inactive-center" x="200" y="65" width="5" height="5" fill="#2f2f2f"/>

  <rect id="hint-top-margin"    x="200" y="0"  width="5" height="{T}" fill="#00ff29"/>
  <rect id="hint-bottom-margin" x="200" y="25" width="5" height="{B}" fill="#00ff29"/>
  <rect id="hint-left-margin"   x="200" y="35" width="{L}" height="5" fill="#00ff29"/>
  <rect id="hint-right-margin"  x="200" y="45" width="{L}" height="5" fill="#00ff29"/>
</svg>
'''
with open(os.path.join(OUT, "decoration.svg"), "w") as f:
    f.write(DECO)

# -------------------------------------------------------------------- buttons
S = 16

# glyphs, drawn inside a 16x16 box
GLYPHS = {
    "close": '''<path d="M4.5,4.5 L11.5,11.5 M11.5,4.5 L4.5,11.5" stroke="{c}" stroke-width="1.8" fill="none"/>''',
    "minimize": '''<path d="M3.5,5 L12.5,5 L8,11.5 Z" fill="{c}"/>''',
    "maximize": '''<rect x="4" y="3.5" width="8" height="8" fill="none" stroke="{c}" stroke-width="1.5"/>
      <rect x="5.5" y="8" width="4" height="4" fill="{c}"/>''',
    "restore": '''<rect x="5.5" y="3.5" width="7" height="7" fill="none" stroke="{c}" stroke-width="1.4"/>
      <rect x="3.5" y="5.5" width="7" height="7" fill="none" stroke="{c}" stroke-width="1.4"/>''',
    "alldesktops": '''<rect x="3.5" y="4.5" width="4" height="4" fill="{c}"/>
      <rect x="8.5" y="4.5" width="4" height="4" fill="{c}" opacity="0.55"/>
      <rect x="3.5" y="9.5" width="4" height="4" fill="{c}" opacity="0.55"/>
      <rect x="8.5" y="9.5" width="4" height="4" fill="{c}" opacity="0.55"/>''',
    "keepabove": '''<path d="M8,3.5 L12.5,9 L3.5,9 Z" fill="{c}"/><rect x="6.5" y="9.5" width="3" height="3.5" fill="{c}"/>''',
    "keepbelow": '''<path d="M8,12.5 L3.5,7 L12.5,7 Z" fill="{c}"/><rect x="6.5" y="3" width="3" height="3.5" fill="{c}"/>''',
    "shade": '''<rect x="3.5" y="4" width="9" height="1.8" fill="{c}"/><rect x="3.5" y="7" width="9" height="1.8" fill="{c}"/><path d="M4.5,12 L8,9.2 L11.5,12 Z" fill="{c}"/>''',
    "help": '''<text x="8" y="12.5" font-family="sans-serif" font-size="12" font-weight="bold" text-anchor="middle" fill="{c}">?</text>''',
    "appmenu": '''<rect x="3.5" y="4" width="9" height="1.6" fill="{c}"/>
      <rect x="3.5" y="7.2" width="9" height="1.6" fill="{c}"/>
      <rect x="3.5" y="10.4" width="9" height="1.6" fill="{c}"/>''',
    "menu": '''<rect x="3.5" y="4" width="9" height="8" fill="none" stroke="{c}" stroke-width="1.4"/>
      <rect x="3.5" y="4" width="9" height="2.2" fill="{c}"/>''',
}

STATES = [
    ("hover",            "gradBtnHover",    "#d6d6d6"),
    ("active",           "gradBtn",         "#b4b4b4"),
    ("pressed",          "gradBtnPressed",  "#b4b4b4"),
    ("inactive",         "gradBtn",         "#b4b4b4"),
    ("deactivated",      "gradBtnDisabled", "#555555"),
    ("hover-inactive",   "gradBtnHover",    "#d6d6d6"),
    ("pressed-inactive", "gradBtnPressed",  "#b4b4b4"),
]


def button_svg(kind):
    grads = f'''  <defs>
    <linearGradient id="gradBtn" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#545454"/><stop offset="1" stop-color="#444444"/>
    </linearGradient>
    <linearGradient id="gradBtnHover" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#616161"/><stop offset="1" stop-color="#515151"/>
    </linearGradient>
    <linearGradient id="gradBtnPressed" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#383838"/><stop offset="1" stop-color="#313131"/>
    </linearGradient>
    <linearGradient id="gradBtnInactive" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#3a3a3a"/><stop offset="1" stop-color="#303030"/>
    </linearGradient>
    <linearGradient id="gradBtnDisabled" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#2c2c2c"/><stop offset="1" stop-color="#262626"/>
    </linearGradient>
  </defs>
'''
    groups = []
    for i, (state, grad, col) in enumerate(STATES):
        pressed = state == "pressed"
        hi = "#151515" if pressed else "#7e7e7e"
        lo = "#7e7e7e" if pressed else "#151515"
        glyph = GLYPHS[kind].format(c=col)
        groups.append(f'''  <g id="{state}-center" transform="translate({i * S},0)">
    <rect x="0" y="0" width="{S}" height="{S}" fill="#000000"/>
    <rect x="1" y="1" width="{S-2}" height="{S-2}" fill="url(#{grad})"/>
    <rect x="1" y="1" width="{S-2}" height="1" fill="{hi}"/>
    <rect x="1" y="1" width="1" height="{S-2}" fill="{hi}"/>
    <rect x="1" y="{S-2}" width="{S-2}" height="1" fill="{lo}"/>
    <rect x="{S-2}" y="1" width="1" height="{S-2}" fill="{lo}"/>
    {glyph}
  </g>''')
    return f'''<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg xmlns="http://www.w3.org/2000/svg" width="{5 * S}" height="{S}" version="1.1">
{grads}
{chr(10).join(groups)}
</svg>
'''


for kind in GLYPHS:
    with open(os.path.join(OUT, kind + ".svg"), "w") as f:
        f.write(button_svg(kind))

# ----------------------------------------------------------------------- rc
RC = '''[General]
ActiveTextColor=210,210,210
InactiveTextColor=128,128,128
UseTextShadow=true
ActiveTextShadowColor=0,0,0
InactiveTextShadowColor=0,0,0
TextShadowOffsetX=0
TextShadowOffsetY=1
TitleAlignment=Center
TitleVerticalAlignment=Center
Animation=100
LeftButtons=
RightButtons=AIX
Shadow=false

[Layout]
BorderLeft=5
BorderRight=5
BorderBottom=5
TitleHeight=16
TitleEdgeTop=2
TitleEdgeBottom=2
TitleEdgeLeft=5
TitleEdgeRight=5
TitleBorderLeft=2
TitleBorderRight=2
ButtonWidth=16
ButtonHeight=16
ButtonSpacing=3
ButtonMarginTop=2
ButtonMarginLeft=3
ExplicitButtonSpacer=6
PaddingTop=0
PaddingBottom=0
PaddingLeft=0
PaddingRight=0
TitleEdgeTopMaximized=0
TitleEdgeBottomMaximized=0
TitleEdgeLeftMaximized=0
TitleEdgeRightMaximized=0
'''
with open(os.path.join(OUT, NAME + "rc"), "w") as f:
    f.write(RC)

# ------------------------------------------------------------------ metadata
META_DESKTOP = f'''[Desktop Entry]
Name={NAME}
Comment=Aurorae decoration inspired by the DarkOne theme for Enlightenment 16

X-KDE-PluginInfo-Author=zebus3d
X-KDE-PluginInfo-Email=
X-KDE-PluginInfo-Name={NAME}
X-KDE-PluginInfo-Version=1.0
X-KDE-PluginInfo-Category=
X-KDE-PluginInfo-Depends=
X-KDE-PluginInfo-License=GPL_V3
X-KDE-PluginInfo-EnabledByDefault=true
X-KDE-PluginInfo-blur=false
'''
with open(os.path.join(OUT, "metadata.desktop"), "w") as f:
    f.write(META_DESKTOP)

META_JSON = f'''{{
    "KPackageStructure": "aurorae",
    "KPlugin": {{
        "Authors": [
            {{
                "Name": "zebus3d"
            }}
        ],
        "Category": "Plasma 6 Window Decorations",
        "ServiceTypes": [
            "aurorae"
        ],
        "EnabledByDefault": true,
        "Name": "{NAME}",
        "Description": "Aurorae decoration inspired by the DarkOne theme for Enlightenment 16",
        "Id": "{NAME}",
        "Version": "1.0",
        "License": "GPL_V3",
        "X-KDE-PluginInfo-blur": false
    }}
}}
'''
with open(os.path.join(OUT, "metadata.json"), "w") as f:
    f.write(META_JSON)

print("written to", OUT)
for fn in sorted(os.listdir(OUT)):
    print(" ", fn)
