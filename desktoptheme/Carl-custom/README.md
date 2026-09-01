# Carl-custom (Plasma style)

Fork of the **Carl** Plasma style (desktop theme) by **jomada**, licensed LGPL.
Only colors were touched. No shape, no layout, no icon was redrawn.

## What changed vs the original Carl

### 1. The whole theme background was lightened

Every dark background in the theme went from `#111216` to `#24272d`. This is a
plain color swap, applied in two places:

- `colors`: 14 `BackgroundNormal` / `BackgroundAlternate` keys across the
  `Button`, `Tooltip`, `View`, `Window`, `Complementary`, `Header` and
  `Header/Inactive` groups.
- Ten SVG files under `widgets/` and `dialogs/`, where the same hex value is
  written into the artwork: `background`, `clock`, `frame`, `panel-background`,
  `plasmoidheading`, `scrollbar`, `toolbar`, `tooltip`,
  `translucentbackground` and `dialogs/background`.

Worth knowing: this is **not** a panel-only change. It lightens popups,
tooltips, applet backgrounds and dialogs too.

### 2. The panel gray was then darkened a notch

`colors`, groups `Window` and `Complementary`, key `BackgroundNormal`, set to
`28,31,36` (`#1c1f24`). Dark, but deliberately not black.

**This one key is what actually paints the Plasma panel.** Editing the hex
values inside `widgets/panel-background.svgz` does nothing visible: the panel
elements are declared `fill="currentColor"` with `class="ColorScheme-Background"`,
so Plasma resolves their color from the theme's `colors` file at runtime and
ignores whatever hex is stored in the file.

Verified by setting that key to pure red and watching the panel turn red.

### 3. The panel's top shadow strip was flattened

In `widgets/panel-background.svgz`, three elements in the panel background group
went from 6 px to 1 px tall: `rect4148`, `rect1546-6` and `sb` (the latter is
the gradient strip), with the `path1671` outline adjusted to match. This removes
the soft dark band the original drew along the top edge of the panel.

## How to reload after editing

Plasma caches the theme, so editing the files changes nothing until you clear
the cache and restart the shell:

```bash
rm -f ~/.cache/plasma_theme_*.kcache
kquitapp6 plasmashell && setsid plasmashell &
```

## Credits

Original **Carl** Plasma style by jomada (gicalucejo@gmail.com), LGPL. This fork
keeps the same license.
