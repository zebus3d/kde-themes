#!/usr/bin/env bash
# Installs the CarlSlim and ScratchySlim Aurorae themes for the current user.
# Does not touch the original Carl / Scratchy themes.
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dest="$HOME/.local/share/aurorae/themes"

mkdir -p "$dest"
for theme in CarlSlim ScratchySlim; do
    rm -rf "${dest:?}/$theme"
    cp -r "$src/$theme" "$dest/"
    echo "installed: $dest/$theme"
done

cat <<'MSG'

Done. Pick CarlSlim or ScratchySlim in:
  System Settings > Colors & Themes > Window Decorations

If you had one of them selected already, KWin caches the theme config in
memory: switch to another decoration and back for the change to show up.
MSG
