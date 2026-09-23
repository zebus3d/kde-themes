# KDE themes

My KDE Plasma 6 themes: three Aurorae window decorations, one Plasma style and
one color scheme. Some are forks of themes by **jomada** with a few things
fixed; one (**DarkOne**) is a port from Enlightenment 16.

| Folder | Type | What it is |
|---|---|---|
| `aurorae/CarlSlim` | window decoration | Carl fork, bottom border made as thin as the sides |
| `aurorae/ScratchySlim` | window decoration | Scratchy fork, same fix |
| `aurorae/DarkOne` | window decoration | port of the DarkOne theme from Enlightenment 16 |
| `desktoptheme/Carl-custom` | Plasma style | Carl fork with a lighter background |
| `desktoptheme/DarkOne` | Plasma style | Carl-custom re-coloured to the DarkOne palette |
| `color-schemes/DarkOne.colors` | color scheme | greys and red of the DarkOne theme |
| `color-schemes/Zebus3d.colors` | color scheme | dark scheme with a blue focus accent |

## Window decorations

### CarlSlim and ScratchySlim

**What this fixes:** on the original **Carl** and **Scratchy** Aurorae window
decorations, the bottom border of every window is drawn about three times
thicker than the side borders (6 px against 2 px), which makes windows look
bottom-heavy. These forks make the bottom border match the sides. Nothing else
changes: same artwork, same colors, same buttons, same title bar.

![before and after](docs/before-after.png)

No artwork was modified, only two layout values. Full details in
[`aurorae/CarlSlim/README.md`](aurorae/CarlSlim/README.md).

#### The problem

On these themes the bottom border of every window looks much thicker than the
side borders: 6 px at the bottom against 2 px at the sides.

The cause is not just `BorderBottom`. The theme's `decoration.svg` paints an
opaque dark band **inside the padding area**, the region that is supposed to
hold the drop shadow. That band shifts vertically with `PaddingBottom`, so it
spills below the window frame and adds to the real border. This is why lowering
`BorderBottom` on its own changes nothing you can see.

#### The fix

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

### DarkOne

A port of **DarkOne for Enlightenment 16** (`DarkOne/e16` in
`garrett/enlightenment-themes`) to an Aurorae decoration. The SVGs are drawn
from scratch and the colors are sampled from the original E16 artwork. It is not
a fork of Carl or Scratchy.

Black 5 px frame with a bevel (lit on the left, shaded on the right and bottom)
and mitered corners; a 22 px title bar that is the **same grey when active and
inactive** (in the original the only focus cue is the title text color), with a
near-black 1 px edge under it; and beveled buttons with the original glyphs,
plus `menu`, `appmenu`, `alldesktops`, `keepabove`, `keepbelow`, `shade` and
`help`.

Three geometry traps are documented in
[`aurorae/DarkOne/README.md`](aurorae/DarkOne/README.md): the title bar height
is driven by the rc and not by the SVG, maximized windows paint only the centre
(so a missing `decoration-maximized` gives a black title bar), and the bottom
corners must be mitered or a bevel spike shows up. That theme also ships the
`generate.py` that produced it.

## Plasma styles

### DarkOne

A first pass at a Plasma style to go with the DarkOne decoration and color
scheme. It starts from Carl-custom and **re-colours** it to the DarkOne palette:
backgrounds to the DarkOne greys (`#2b2b2b`, `#1a1a1a`), text to `#d2d2d2` and
the blue/purple accents to a muted steel blue (`#5a8ab0`). The shapes are still
Carl's, not E16's; the panel and popups are not redrawn with the DarkOne bevel
yet. It is a starting point, not a finished port.

### Carl-custom

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

## Color schemes

### DarkOne

A color scheme to go with the DarkOne decoration, sampled from the same E16
artwork: greys for the window (`#2b2b2b`), view (`#1a1a1a`) and buttons
(`#3a3a3a`), text `#d2d2d2` / `#808080`, and a muted steel blue (`#5a8ab0`) as
the selection and focus accent. It is the part that colors Qt apps and dialogs,
not only Plasma.

A note on the accent: in the E16 original the only colored element is the
progress bar, which is **red** (`#850b0b`). Red was tried here for selections
too and it works, but it tires the eye and reads as a warning, so the scheme
uses a muted blue instead. If you want the faithful red, it is a handful of
values (`DecorationFocus`, `ForegroundActive` and the `Selection` group).

### Zebus3d

A dark color scheme to go with the Carl decorations. Window background
`#2b2b2b`, view `#1e1e1e`, buttons `#252525`, and a muted blue focus accent
(`#6292af`, `98,146,175`).

## Install

```bash
git clone https://github.com/zebus3d/kde-themes.git
cd kde-themes
./install.sh
```

Then pick them in *System Settings > Colors & Themes*: **CarlSlim**,
**ScratchySlim** or **DarkOne** under *Window Decorations*, **Carl-custom**
or **DarkOne** under *Plasma Style*, and **DarkOne** or **Zebus3d** under *Colors*.

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
the cap is 4 px, so writing 25 in the theme does nothing. These themes are tuned
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
aurorae/CarlSlim              window decoration
aurorae/ScratchySlim          window decoration
aurorae/DarkOne               window decoration (port from Enlightenment 16)
desktoptheme/Carl-custom      plasma style (Carl)
desktoptheme/DarkOne          plasma style (DarkOne)
color-schemes/DarkOne.colors  color scheme (DarkOne)
color-schemes/Zebus3d.colors  color scheme (Carl)
install.sh                    copies all of them into ~/.local/share
reload.sh                     reloads them after an edit
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
git clone git@github.com:zebus3d/kde-themes.git ~/github/kde-themes
R=~/github/kde-themes

cd ~/.local/share/aurorae/themes
ln -s "$R/aurorae/CarlSlim" CarlSlim
ln -s "$R/aurorae/ScratchySlim" ScratchySlim
ln -s "$R/aurorae/DarkOne" DarkOne

cd ~/.local/share/plasma/desktoptheme
ln -s "$R/desktoptheme/Carl-custom" Carl-custom
ln -s "$R/desktoptheme/DarkOne" DarkOne

cd ~/.local/share/color-schemes
ln -s "$R/color-schemes/DarkOne.colors" DarkOne.colors
ln -s "$R/color-schemes/Zebus3d.colors" Zebus3d.colors
```

Both KWin and Plasma follow the symlinks without complaining. Then the loop is
edit, `./reload.sh`, and commit when you like the result.

**If you ever rename or move the clone, fix the symlinks**, or KWin/Plasma lose
the theme (the link points at a path that no longer exists) and it disappears
from System Settings without any error. Re-run the `ln -s` block above with the
new path.

Note that the Plasma style ships `.svgz` files, which are gzipped SVG. To edit
one:

```bash
zcat widgets/panel-background.svgz > /tmp/x.svg
# edit /tmp/x.svg
gzip -9 < /tmp/x.svg > widgets/panel-background.svgz
```

## Tested on

KDE Plasma 6 on Wayland, Arch Linux, `BorderSize=Tiny`, display scale 1.

## Credits and licenses

Original **Carl** and **Scratchy** themes by **jomada** (gicalucejo@gmail.com).

- The **CarlSlim** and **ScratchySlim** window decorations inherit the **GPL
  v3** of the original theme: see `LICENSES-GPL-3.0.txt`.
- The **Carl-custom** Plasma style inherits the **LGPL** of the original theme:
  see `LICENSES-LGPL-3.0.txt`.
- **DarkOne** is a re-creation of the DarkOne theme for Enlightenment 16
  (`garrett/enlightenment-themes`), GPL v3.
- The **Zebus3d** color scheme is my own.

---

# En castellano

Mis temas de KDE Plasma 6: tres decoraciones de ventana Aurorae, un estilo de
Plasma y un esquema de color. Algunos son forks de temas de **jomada** con
algunas cosas arregladas; uno (**DarkOne**) es un port de Enlightenment 16.

| Carpeta | Tipo | Que es |
|---|---|---|
| `aurorae/CarlSlim` | decoracion | fork de Carl, borde inferior igualado a los lados |
| `aurorae/ScratchySlim` | decoracion | fork de Scratchy, mismo arreglo |
| `aurorae/DarkOne` | decoracion | port del tema DarkOne de Enlightenment 16 |
| `desktoptheme/Carl-custom` | estilo de Plasma | fork de Carl con el fondo mas claro |
| `desktoptheme/DarkOne` | estilo de Plasma | Carl-custom recoloreado a la paleta DarkOne |
| `color-schemes/DarkOne.colors` | esquema de color | grises y rojo del tema DarkOne |
| `color-schemes/Zebus3d.colors` | esquema de color | oscuro, con acento azul |

## Decoraciones de ventana

### CarlSlim y ScratchySlim

**Que arregla:** en los temas originales **Carl** y **Scratchy** el borde
inferior de las ventanas se dibuja unas tres veces mas grueso que los laterales,
6 px frente a 2 px, y las ventanas quedan como cargadas por abajo. Estos forks
igualan el borde de abajo al de los lados. No cambia nada mas: mismo dibujo,
mismos colores, mismos botones, misma barra de titulo.

#### El problema

El borde de abajo se ve mucho mas grueso que los de los lados: 6 px frente a
2 px. La causa no es solo `BorderBottom`. El archivo `decoration.svg` pinta una
banda oscura opaca dentro de la zona de *padding*, la que en teoria se reserva
para la sombra. Esa banda se desplaza segun `PaddingBottom`, se cuela por debajo
del marco y se suma al borde real. Por eso bajar solo `BorderBottom` no cambia
nada visible.

#### La solucion

Dos valores en la seccion `[Layout]`: `BorderBottom` de 7 a 2, y `PaddingBottom`
de 90 a 86. El 86 esta calibrado midiendo pixeles: con 88 quedan 4 px, con 84 o
menos el borde desaparece del todo.

### DarkOne

Port de **DarkOne para Enlightenment 16** (`DarkOne/e16` en
`garrett/enlightenment-themes`). Los SVG estan dibujados desde cero y los
colores muestreados del artwork original de E16. No es un fork de Carl ni de
Scratchy.

Marco negro de 5 px con bisel (claro a la izquierda, oscuro a la derecha y
abajo) y esquinas a inglete; barra de titulo de 22 px que es **igual de gris
activa que inactiva** (en el original el unico indicador de foco es el color del
texto), con un canto casi negro de 1 px debajo; y botones biselados con los
glifos originales, mas `menu`, `appmenu`, `alldesktops`, `keepabove`,
`keepbelow`, `shade` y `help`.

Las tres trampas de geometria estan documentadas en
[`aurorae/DarkOne/README.md`](aurorae/DarkOne/README.md): el alto de la barra lo
fija el rc y no el SVG, al maximizar Aurorae pinta solo el centro (sin
`decoration-maximized` la barra sale negra) y las esquinas inferiores van a
inglete o sale un pico. Ese tema incluye ademas el `generate.py` que lo genero.

## Estilos de Plasma

### DarkOne

Primer pase de un estilo de Plasma para acompasar la decoracion y el esquema
DarkOne. Parte de Carl-custom y lo **recolorea** a la paleta DarkOne: fondos a
los grises DarkOne (`#2b2b2b`, `#1a1a1a`), texto a `#d2d2d2` y los acentos
azul/morado a un azul acero apagado (`#5a8ab0`). Las formas siguen siendo las de Carl,
no las de E16; el panel y los popups todavia no llevan el bisel DarkOne. Es un
punto de partida, no un port terminado.

### Carl-custom

Fork del estilo **Carl** con el fondo mas claro que el original, que era casi
negro, y el gris del panel fijado en `#1c1f24`. Ojo con una trampa: el color del
panel vive en el archivo `colors`, clave `BackgroundNormal` del grupo `Window`.
Cambiar los valores hexadecimales dentro de `widgets/panel-background.svgz` no
se nota, porque esos elementos usan `fill="currentColor"` y Plasma resuelve el
color desde `colors` en tiempo de ejecucion.

## Esquemas de color

### DarkOne

Un esquema que acompana a la decoracion DarkOne, muestreado del mismo artwork
de E16: grises para ventana (`#2b2b2b`), vista (`#1a1a1a`) y botones
(`#3a3a3a`), texto `#d2d2d2` / `#808080`, y un **azul acero apagado**
(`#5a8ab0`) como acento de seleccion y foco. Es la parte que tine las apps Qt y
los dialogos, no solo Plasma.

Sobre el acento: en el original de E16 el unico elemento con color es la barra
de progreso, que es **roja** (`#850b0b`). Se probo el rojo tambien para
seleccion y funciona, pero cansa y parece un aviso de error, asi que el esquema
usa un azul apagado. Si lo quieres rojo fiel, son un punado de valores
(`DecorationFocus`, `ForegroundActive` y el grupo `Selection`).

### Zebus3d

Un esquema oscuro que acompana a las decoraciones Carl. Fondo de ventana
`#2b2b2b`, vista `#1e1e1e`, botones `#252525`, y un acento azul apagado
(`#6292af`, `98,146,175`).

## Instalacion

```bash
git clone https://github.com/zebus3d/kde-themes.git
cd kde-themes
./install.sh
```

Luego elige **CarlSlim**, **ScratchySlim** o **DarkOne** en *Preferencias del
sistema > Colores y temas > Decoraciones de ventana*, **Carl-custom** en *Estilo
de Plasma* (o **DarkOne** en *Estilo de Plasma*) y **DarkOne** o **Zebus3d**
en *Colores*. Los temas originales no se tocan.

### Dos trampas al probar cambios

KWin **cachea** el rc del tema, asi que `reconfigure` no basta: hay que cambiar a
otro tema y volver. Y el ajuste global **Tamano de borde** de KDE recorta estos
valores, con tope de 4 px cuando esta en `Tiny`.

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
repositorio es editar el tema en vivo:

```bash
R=~/github/kde-themes
cd ~/.local/share/aurorae/themes
ln -s "$R/aurorae/CarlSlim" CarlSlim
ln -s "$R/aurorae/ScratchySlim" ScratchySlim
ln -s "$R/aurorae/DarkOne" DarkOne
cd ~/.local/share/plasma/desktoptheme
ln -s "$R/desktoptheme/Carl-custom" Carl-custom
ln -s "$R/desktoptheme/DarkOne" DarkOne
cd ~/.local/share/color-schemes
ln -s "$R/color-schemes/DarkOne.colors" DarkOne.colors
ln -s "$R/color-schemes/Zebus3d.colors" Zebus3d.colors
```

**Si renombras o mueves el clon, arregla los enlaces**: KWin/Plasma pierden el
tema (el enlace apunta a una ruta que ya no existe) y desaparece de Preferencias
sin ningun error. Vuelve a lanzar el bloque de `ln -s` con la ruta nueva.

Los archivos `.svgz` del estilo son SVG comprimidos con gzip: `zcat` para
abrirlos y `gzip -9` para volver a guardarlos.

## Creditos y licencias

Temas originales **Carl** y **Scratchy** de **jomada** (gicalucejo@gmail.com).

- Las decoraciones **CarlSlim** y **ScratchySlim** heredan la **GPL v3** del
  tema original: ver `LICENSES-GPL-3.0.txt`.
- El estilo de Plasma **Carl-custom** hereda la **LGPL** del tema original: ver
  `LICENSES-LGPL-3.0.txt`.
- **DarkOne** es una re-creacion del tema DarkOne de Enlightenment 16
  (`garrett/enlightenment-themes`), GPL v3.
- El esquema de color **Zebus3d** es mio.
