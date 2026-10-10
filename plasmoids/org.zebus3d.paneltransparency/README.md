# Panel transparency (plasmoid)

A small Plasma 6 widget that adds a **continuous transparency control** for the
panel it is placed in, which Plasma does not offer natively (the panel only has
three fixed modes: *Adaptive*, *Opaque*, *Translucent*).

It also lets you replace the panel background colour with a custom one, or keep
the current theme colour.

## What it does

- **Transparency slider** for the panel background, 0 % (fully transparent) to
  100 % (solid), adjustable live.
- **Colour source**: *Theme colour* (untouched, uses the Plasma style) or
  *Custom colour* (tints the panel background to any RGB colour).
- **Only visible in panel edit mode** by default, so it does not take space the
  rest of the time. Toggle this in the widget settings.
- Applies **only to the panel where it is placed**.

## Install

```bash
ln -s "$PWD/plasmoids/org.zebus3d.paneltransparency" \
      ~/.local/share/plasma/plasmoids/org.zebus3d.paneltransparency
```

or copy it with:

```bash
kpackagetool6 --type Plasma/Applet --install plasmoids/org.zebus3d.paneltransparency
```

## Use

1. Enter panel edit mode (right-click the panel → *Enter Edit Mode*).
2. Add the widget: *Add or manage widgets…* → search for **Panel transparency**.
   In edit mode the widget shows a small icon, not the slider, because while
   editing the applet is dragged around and a slider there could not be used.
3. Right-click the icon → **Show widget** to keep it visible outside edit mode.
4. Leave edit mode: the slider is now in the panel and you can drag it to set
   the opacity. Right-click → **Hide widget** sends it back to edit-mode only.
5. Right-click → *Configure…* for the colour mode, custom colour and the
   "only in edit mode" option.

> The opacity slider only works **outside** panel edit mode. In edit mode the
> panel captures drags to move applets, so the widget shows an icon there and
> the slider appears once you leave edit mode.

## How it works

Plasma draws the panel background with four `KSvg.FrameSvgItem` layers
(translucent/opaque × floating/not). The widget walks up the item tree to the
`Panel.qml` root, finds those layers (their `imagePath` contains
`panel-background`) and sets their `opacity`. For a custom colour it tints the
same layers with a `MultiEffect` colourisation, which keeps the theme's shape,
border and the KWin blur mask intact.

## Caveats

- While the widget is enabled it **takes over** the panel background opacity, so
  the native *Adaptive* mode no longer cross-fades on its own.
- Disabling or removing the widget restores opacity `1.0`, but a full restore of
  the original behaviour may need a plasmashell restart.
- Custom colour is applied by colourising the theme artwork; the subtle bevels
  and edges of the theme are tinted rather than flattened.

## Credits

Technique inspired by **Panel Colorizer** (Luis Bocanegra, GPL-3.0) and
`paneltransparencybutton`. This is an independent, much smaller implementation.
