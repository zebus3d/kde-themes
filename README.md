# KDE Carl themes, fixed

Forks of the **Carl** and **Scratchy** themes for KDE Plasma by jomada, with a
few things fixed. Two Aurorae window decorations and one Plasma style.

## Window decorations: CarlSlim and ScratchySlim

**What this fixes:** on the original **Carl** and **Scratchy** Aurorae window
decorations, the bottom border of every window is drawn about three times
thicker than the side borders (6 px against 2 px), which makes windows look
bottom-heavy. These forks make the bottom border match the sides. Nothing else
changes: same artwork, same colors, same buttons, same title bar.

![before and after](docs/before-after.png)

No artwork was modified, only two layout values. Full details in
[`aurorae/CarlSlim/README.md`](aurorae/CarlSlim/README.md).

*(Version en castellano mas abajo.)*

### The problem

On these themes the bottom border of every window looks much thicker than the
side borders: 6 px at the bottom against 2 px at the sides.

The cause is not just `BorderBottom`. The theme's `decoration.svg` paints an
opaque dark band **inside the padding area**, the region that is supposed to
hold the drop shadow. That band shifts vertically with `PaddingBottom`, so it
spills below the window frame and adds to the real border. This is why lowering
`BorderBottom` on its own changes nothing you can see.

### The fix

Two values in the `[Layout]` section of the theme's rc file:

| Key | Original | Fork |
|---|---|---|
| `BorderLeft` | 2 | 2 |
| `BorderRight` | 2 | 2 |
| `BorderBottom` | 7 | **2** |
| `PaddingBottom` | 90 | **86** |

`PaddingBottom` was calibrated by measuring pixels on screen:

| `PaddingBottom` | Visible bottom border |
|---|---|
| 90 | 6 px |
| 88 | 4 px |
| **86** | **2 px, same as the sides** |
| 84 or lower | the border disappears entirely |

If you change `BorderBottom`, you have to recalibrate `PaddingBottom`.

## Plasma style: Carl-custom

A fork of the **Carl** Plasma style with a lighter background than the original,
which was almost black. Two changes:

- The theme background went from `#111216` to `#24272d`, across the `colors`
  file and ten SVG files. This affects popups, tooltips and dialogs too, not
  only the panel.
- The panel gray was then set to `#1c1f24`. Dark, but deliberately not black.

One trap worth knowing: **the panel color lives in the `colors` file**, key
`BackgroundNormal` of the `Window` group. Editing the hex values inside
`widgets/panel-background.svgz` does nothing visible, because those elements are
declared `fill="currentColor"` and Plasma resolves their color from `colors` at
runtime. Full details in
[`desktoptheme/Carl-custom/README.md`](desktoptheme/Carl-custom/README.md).

## Install

```bash
git clone https://github.com/zebus3d/aurorae-slim-themes.git
cd aurorae-slim-themes
./install.sh
```

Then pick them in *System Settings > Colors & Themes*: **CarlSlim** or
**ScratchySlim** under *Window Decorations*, and **Carl-custom** under
*Plasma Style*.

The installer only copies into `~/.local/share/`. It does not touch the original
themes, so you can switch back at any time.

### Two traps when tweaking the decorations

**1. KWin caches the theme rc in memory.** Running
`qdbus6 org.kde.KWin /KWin reconfigure` does *not* re-read it. You have to
switch to another theme and back:

```bash
sw() { kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme "__aurorae__svg__$1"; qdbus6 org.kde.KWin /KWin reconfigure; sleep 2; }
sw Breeze; sw CarlSlim
```

**2. The global KDE "Border size" setting clamps these values.** It lives in
`~/.config/kwinrc`, group `org.kde.kdecoration2`, key `BorderSize`. With `Tiny`
the cap is 4 px, so writing 25 in the theme does nothing. These forks are tuned
for `BorderSize=Tiny`.

### Measuring borders properly

Eyeballing a screenshot is misleading, mostly because the SVG band falls
*outside* the window frame. Ask KWin instead, comparing `frameGeometry` with
`clientGeometry`. A ready-to-use script ships in each theme folder as
`borders.js`:

```bash
id=$(qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript ~/.local/share/aurorae/themes/CarlSlim/borders.js probe)
qdbus6 org.kde.KWin /Scripting/Script$id org.kde.kwin.Script.run
qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript probe
journalctl --user -b --since "-20s" | grep BORDERS
```

That gives the real frame border. The SVG band sits outside it and only shows up
when you measure pixels on a full-screen capture.

## Repository layout

```
aurorae/CarlSlim            window decoration
aurorae/ScratchySlim        window decoration
desktoptheme/Carl-custom    plasma style
install.sh                  copies all three into ~/.local/share
reload.sh                   reloads them after an edit
```

Each theme folder carries its own README with the full diagnosis of what was
changed and why.

## Working on these themes

The two caches are the thing that wastes time here. KWin keeps the decoration's
rc file in memory, and Plasma keeps a compiled cache of the style, so editing a
file and looking at the screen tells you nothing. `reload.sh` handles both:

```bash
./reload.sh          # reload both
./reload.sh kwin     # only the window decoration
./reload.sh plasma   # only the Plasma style
```

For the decoration it switches to another theme and back, which is what actually
forces KWin to re-read the file. For the style it clears
`~/.cache/plasma_theme_*.kcache` and restarts the shell.

### Editing in place

You can point the system at a clone instead of copying files, so that editing
the repository *is* editing the live theme:

```bash
git clone git@github.com:zebus3d/aurorae-slim-themes.git ~/github/aurorae-slim-themes
cd ~/.local/share/aurorae/themes
ln -s ~/github/aurorae-slim-themes/aurorae/CarlSlim CarlSlim
ln -s ~/github/aurorae-slim-themes/aurorae/ScratchySlim ScratchySlim
cd ~/.local/share/plasma/desktoptheme
ln -s ~/github/aurorae-slim-themes/desktoptheme/Carl-custom Carl-custom
```

Both KWin and Plasma follow the symlinks without complaining. Then the loop is
edit, `./reload.sh`, and commit when you like the result.

Note that the Plasma style ships `.svgz` files, which are gzipped SVG. To edit
one:

```bash
zcat widgets/panel-background.svgz > /tmp/x.svg
# edit /tmp/x.svg
gzip -9 < /tmp/x.svg > widgets/panel-background.svgz
```

## Tested on

KDE Plasma 6 on Wayland, Arch Linux, `BorderSize=Tiny`, display scale 1.

---

# En castellano

Forks de los temas **Carl** y **Scratchy** de jomada para KDE Plasma. Dos
decoraciones de ventana y un estilo de Plasma.

## Decoraciones de ventana: CarlSlim y ScratchySlim

**Que arregla:** en los temas originales **Carl** y **Scratchy** el borde
inferior de las ventanas se dibuja unas tres veces mas grueso que los laterales,
6 px frente a 2 px, y las ventanas quedan como cargadas por abajo. Estos forks
igualan el borde de abajo al de los lados. No cambia nada mas: mismo dibujo,
mismos colores, mismos botones, misma barra de titulo.

### El problema

El borde de abajo se ve mucho mas grueso que los de los lados: 6 px frente a
2 px. La causa no es solo `BorderBottom`. El archivo `decoration.svg` pinta una
banda oscura opaca dentro de la zona de *padding*, la que en teoria se reserva
para la sombra. Esa banda se desplaza segun `PaddingBottom`, se cuela por debajo
del marco y se suma al borde real. Por eso bajar solo `BorderBottom` no cambia
nada visible.

### La solucion

Dos valores en la seccion `[Layout]`: `BorderBottom` de 7 a 2, y `PaddingBottom`
de 90 a 86. El 86 esta calibrado midiendo pixeles: con 88 quedan 4 px, con 84 o
menos el borde desaparece del todo.

## Instalacion

```bash
git clone https://github.com/zebus3d/aurorae-slim-themes.git
cd aurorae-slim-themes
./install.sh
```

Luego elige **CarlSlim** o **ScratchySlim** en *Preferencias del sistema >
Colores y temas > Decoraciones de ventana*. Los temas originales no se tocan.

### Dos trampas al probar cambios

KWin **cachea** el rc del tema, asi que `reconfigure` no basta: hay que cambiar a
otro tema y volver. Y el ajuste global **Tamano de borde** de KDE recorta estos
valores, con tope de 4 px cuando esta en `Tiny`.

## Estilo de Plasma: Carl-custom

Fork del estilo **Carl** con el fondo mas claro que el original, que era casi
negro, y el gris del panel fijado en `#1c1f24`. Ojo con una trampa: el color del
panel vive en el archivo `colors`, clave `BackgroundNormal` del grupo `Window`.
Cambiar los valores hexadecimales dentro de `widgets/panel-background.svgz` no
se nota, porque esos elementos usan `fill="currentColor"` y Plasma resuelve el
color desde `colors` en tiempo de ejecucion.

## Trabajar sobre estos temas

Las dos caches son lo que hace perder el tiempo aqui: KWin guarda en memoria el
rc de la decoracion y Plasma guarda una cache compilada del estilo, asi que
editar un archivo y mirar la pantalla no dice nada. `reload.sh` se encarga:

```bash
./reload.sh          # recarga los dos
./reload.sh kwin     # solo la decoracion de ventana
./reload.sh plasma   # solo el estilo de Plasma
```

Puedes apuntar el sistema a un clon con enlaces simbolicos, y asi editar el
repositorio es editar el tema en vivo. Los archivos `.svgz` del estilo son SVG
comprimidos con gzip: `zcat` para abrirlos y `gzip -9` para volver a guardarlos.

## Creditos y licencias

Temas originales de **jomada** (gicalucejo@gmail.com).

- Las decoraciones de ventana **CarlSlim** y **ScratchySlim** heredan la
  **GPL v3** del tema original: ver `LICENSES-GPL-3.0.txt`.
- El estilo de Plasma **Carl-custom** hereda la **LGPL** del tema original: ver
  `LICENSES-LGPL-3.0.txt`.
