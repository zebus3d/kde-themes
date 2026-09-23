# DarkOne (Plasma style)

Primer pase de un estilo de Plasma para acompasar la decoracion de ventana y el
esquema de color DarkOne. Parte de **Carl-custom** (fork de Carl de jomada,
LGPL) y lo **recolorea** a la paleta del DarkOne de Enlightenment 16.

## Que cambia

- Fondos: los grises de Carl-custom pasan a los de DarkOne (`#24272d` y `#232629`
  -> `#2b2b2b`, `#1a1c1e` -> `#1e1e1e`, `#111314` -> `#1a1a1a`).
- Texto: `#eff0f1` / `#fcfcfc` -> `#d2d2d2`.
- Acentos azul y morado de Carl (`#3c78ff`, `#7040ff`, `#3daee9`…) -> un **azul
  acero apagado** (`#5a8ab0`), que cuadra con los grises. El rojo `#850b0b` del
  DarkOne original queda solo para el esquema de color si se quiere fiel; aqui
  se descarto porque para seleccion cansa y parece un aviso de error.
- El archivo `colors` del estilo, a la misma paleta.

**No se redibuja ninguna forma**: las del panel, popups, botones, etc. siguen
siendo las de Carl. Falta el bisel DarkOne (marco negro con bisel) en el panel y
los popups, que es lo que le daria el aire de E16. Es un punto de partida, no un
port terminado.

## Como se genero

Recoloreado automatico de todos los `.svgz` y del `colors` del Carl-custom. Los
hints de Plasma (`#ff00ff`, `#00ff00`, `#800080`…) se conservan porque son
marcadores, no color visible.

## Licencia

Hereda la **LGPL** de Carl-custom / Carl (jomada). Ver `LICENSES-LGPL-3.0.txt`
en la raiz del repositorio.
