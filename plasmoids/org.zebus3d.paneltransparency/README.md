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
- **Always present in the panel**: when the slider is off the widget collapses to
  a small, faint handle, so it is always reachable (right-click) even though it
  is not really visible.
- Applies **only to the panel where it is placed**.

## Install

```bash
ln -s "~/github/kde-themes/plasmoids/org.zebus3d.paneltransparency" ~/.local/share/plasma/plasmoids/org.zebus3d.paneltransparency
```

or copy it with:

```bash
kpackagetool6 --type Plasma/Applet --install plasmoids/org.zebus3d.paneltransparency
```

## Use

1. Enter panel edit mode (right-click the panel → *Enter Edit Mode*).
2. Add the widget: *Add or manage widgets…* → search for **Panel transparency**.
3. Right-click the widget → **Show slider** (or **Hide slider**). The widget never
   disappears from the panel: collapsed it is just a small handle.
4. Leave edit mode: the slider is now in the panel and you can drag it. Right-click
   → **Hide slider** collapses it again.
5. Right-click → *Configure…* for the colour mode and custom colour.

> The slider only works **outside** panel edit mode: in edit mode the panel
> captures drags to move applets, so the widget stays collapsed there and the
> slider appears once you leave edit mode.

## How it works

Plasma draws the panel background with four `KSvg.FrameSvgItem` layers
(translucent/opaque × floating/not). The widget walks up the item tree to the
`Panel.qml` root, finds those layers (their `imagePath` contains
`panel-background`) and sets their `opacity`.

For a custom colour it **replaces** the background: it hides the native layers
and draws its own rectangle with the exact colour, sized to the theme background
geometry (the four layers share it). Hiding the native layers keeps their mask,
so the KWin blur behind the panel still works.

At opacity 0 the widget also drops the native panel background
(`backgroundHints = NoBackground`), which makes KWin turn off blur and contrast
behind the panel, so it becomes truly transparent instead of a blurred strip.

## Caveats

- While the widget is enabled it **takes over** the panel background opacity, so
  the native *Adaptive* mode no longer cross-fades on its own.
- Disabling or removing the widget restores opacity `1.0`, but a full restore of
  the original behaviour may need a plasmashell restart.
- Custom colour is a plain rectangle (exact colour) sized to the panel
  background, so the theme's subtle rounded corners/bevels are not reproduced.

## Credits

Technique inspired by **Panel Colorizer** (Luis Bocanegra, GPL-3.0) and
`paneltransparencybutton`. This is an independent, much smaller implementation.
