// Mide los bordes reales del marco de cada ventana segun KWin.
// Ver README.md de este tema para saber como lanzarlo.
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
