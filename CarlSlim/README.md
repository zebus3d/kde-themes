# CarlSlim

Fork propio de la decoracion de ventanas Aurorae **Carl**, creado el 2026-09-01.
El tema original sigue instalado y sin modificar en `../Carl/`.

## Que se arreglo

El borde inferior de las ventanas se veia mucho mas grueso que los laterales:
6 px abajo frente a 2 px a los lados.

La causa no era solo `BorderBottom`. El archivo `decoration.svg` pinta una
banda oscura opaca dentro de la zona de *padding*, la que en teoria se reserva
para la sombra. Esa banda se desplaza verticalmente segun `PaddingBottom`, se
cuela por debajo del marco y se suma al borde real. Por eso bajar solo
`BorderBottom` no cambiaba nada visible.

## Cambios respecto al original

| Clave en `[Layout]` | Carl | CarlSlim |
|---|---|---|
| `BorderLeft` | 2 | 2 |
| `BorderRight` | 2 | 2 |
| `BorderBottom` | 7 | **2** |
| `PaddingBottom` | 90 | **86** |

Tambien cambian el nombre y el id en `metadata.desktop` y `metadata.json`,
para que el fork aparezca como un tema aparte en Preferencias del sistema.

## Calibracion de PaddingBottom

Medido pixel a pixel sobre capturas de pantalla:

| `PaddingBottom` | Borde inferior visible |
|---|---|
| 90 | 6 px |
| 88 | 4 px |
| **86** | **2 px, igual que los lados** |
| 84 o menos | el borde desaparece |

Si cambias `BorderBottom`, hay que recalibrar `PaddingBottom`.

## Dos trampas al probar cambios

**KWin cachea este archivo en memoria.** Lanzar `qdbus6 org.kde.KWin /KWin
reconfigure` no vuelve a leerlo. Hay que cambiar a otro tema y volver:

```bash
sw() { kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme "__aurorae__svg__$1"; qdbus6 org.kde.KWin /KWin reconfigure; sleep 2; }
sw Carl; sw CarlSlim
```

**El ajuste global de KDE "Tamano de borde" recorta estos valores.** Vive en
`~/.config/kwinrc`, grupo `org.kde.kdecoration2`, clave `BorderSize`. Con
`Tiny` el tope son 4 px, asi que poner 25 aqui no sirve de nada. Estos valores
estan pensados para `BorderSize=Tiny`.

## Como medir los bordes de verdad

Mirar una captura enganna, sobre todo porque la banda del SVG cae fuera del
marco. Lo fiable es preguntarle a KWin comparando `frameGeometry` con
`clientGeometry`:

```javascript
// borders.js (incluido en esta carpeta)
var ws = workspace.windowList();
for (var i = 0; i < ws.length; i++) {
  var c = ws[i];
  if (!c.normalWindow) continue;
  var f = c.frameGeometry, b = c.clientGeometry;
  print("BORDERS " + c.resourceClass + " L=" + (b.x - f.x) +
        " R=" + (f.x + f.width - (b.x + b.width)) +
        " T=" + (b.y - f.y) +
        " B=" + (f.y + f.height - (b.y + b.height)));
}
```

```bash
id=$(qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript ~/.local/share/aurorae/themes/CarlSlim/borders.js probe)
qdbus6 org.kde.KWin /Scripting/Script$id org.kde.kwin.Script.run
qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript probe
journalctl --user -b --since "-20s" | grep BORDERS
```

Ese metodo da el borde real del marco. La banda del SVG queda por fuera y solo
se ve midiendo pixeles en una captura de pantalla completa.
