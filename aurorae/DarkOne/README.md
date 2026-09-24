# DarkOne

Decoracion de ventanas Aurorae para KDE Plasma 6, **port del tema DarkOne de
Enlightenment 16** (`DarkOne/e16` en `garrett/enlightenment-themes`). Creada el
2026-09-23.

No es un fork de Carl ni de Scratchy: los SVG estan dibujados desde cero y los
colores estan muestreados del artwork original de E16 (los PNG de
`artwork/border/` y `artwork/windowbutton/`). El tema original de E16 se puede
seguir usando en Enlightenment; esto es una re-creacion para KWin.

## Que tiene

- Marco negro de 5 px con bisel (claro a la izquierda, oscuro a la derecha y
  abajo), esquinas a inglete.
- Barra de titulo de 22 px. **Activa e inactiva son iguales** (gris
  `#343434 -> #2c2c2c`): en el DarkOne original el unico indicador de foco es el
  color del texto del titulo, y aqui tambien. La barra roja `titlebar_r.png` del
  original **no** es la barra activa: en E16 solo se usa para epplets (mirar
  `imageclasses/borders.cfg`, donde todos los estados mapean a `titlebar.png`).
- Canto inferior de 2 px `#080808`, casi negro, como las dos ultimas filas del
  `titlebar.png` original (`#1B1B1B` + `#0C0C0C`). La linea solo ocupa el tramo
  entre los bordes laterales: los biseles verticales de las esquinas llegan
  hasta abajo del titulo y la linea no los corta.
- Botones biselados con los glifos originales: cerrar, minimizar, maximizar,
  restaurar, y ademas `menu` (menu de ventana), `appmenu` (hamburguesa),
  `alldesktops`, `keepabove`, `keepbelow`, `shade` y `help`.

## Tres trampas de geometria que cuestan una tarde

**1. El alto de la barra lo fija el rc, no el SVG.** El contenido de la ventana
empieza en `20 + TitleEdgeBottom` px desde arriba (el 20 es fijo con
`BorderSize=Tiny`). El tile `decoration-top` del SVG se dibuja dentro de ese
margen, asi que tiene que medir lo mismo: `T = 20 + TitleEdgeBottom`. Con
`TitleEdgeBottom=2` (el que usa este tema), `T=22`. `TitleHeight` y
`TitleEdgeTop` no mueven ese offset; solo `TitleEdgeBottom`. Si `T` y
`TitleEdgeBottom` no cuadran, el canto inferior desaparece o se descuadra.

Los botones empiezan en `TitleEdgeTop + ButtonMarginTop` y miden `ButtonHeight`.
Con una barra de 20 y `ButtonHeight=16, ButtonMarginTop=2` el boton queda a ras
por abajo (4 px arriba, 0 abajo); con la barra de 22 quedan 1 px de aire y 1 px
de canto.

**2. Al maximizar, Aurorae pinta solo el centro.** KWin desactiva todos los
bordes y dibuja unicamente `decoration-maximized-center` (y `-inactive-center`).
Si no se definen, cae al `decoration-center` normal y la barra de titulo sale
del color del centro (negra si el centro es negro) ademas de quedar franjas sin
cubrir. Aqui estan puestos en `#2f2f2f`.

**3. Las esquinas inferiores van a inglete, no en anillos.** Si se dibuja el
bisel como anillos concentricos es facil pintar el anillo encima de la fila
exterior negra, y entonces el borde de abajo se ve gris y "sobresale un pico".
La forma que empalma exacto: la fila superior del corner son las columnas del
borde lateral, y la columna interior son las filas del borde inferior.

## Los botones `menu` y `appmenu`

La documentacion de KDE dice que el menu de ventana (`M`) **no** se puede
tematizar por SVG, pero el plugin `org.kde.kwin.aurorae.v2` si pinta `menu.svg`
(verificado en Plasma 6.7: sin el fichero sale un icono de reserva generico, con
el fichero sale el tuyo). `appmenu.svg` es la hamburguesa del menu de
aplicacion. Sin ninguno de los dos, esos botones muestran un icono generico.

## Editar el tema

Los SVG y el rc se pueden tocar a mano, pero el tema se genero con
[`generate.py`](generate.py). Cambia el diccionario `CONFIG` (paleta y
geometria) y vuelve a generar:

```bash
python3 generate.py    # reescribe ~/.local/share/aurorae/themes/DarkOne/
```

Ya mete el acoplamiento `T = 20 + TitleEdgeBottom`, el `decoration-maximized` y
las esquinas a inglete.

## Verificar sin tocar la sesion

KWin cachea el rc en memoria: `reconfigure` no lo relee. Hay que cambiar a otro
tema y volver (ver el `reload.sh` de la raiz).

Para medir pixeles de verdad, lo comodo es renderizar en un **KWin anidado** con
framebuffer virtual y capturar una ventana real, sin tocar la sesion. Y para el
borde del marco, `borders.js` (incluido aqui) pregunta a KWin comparando
`frameGeometry` con `clientGeometry`.
