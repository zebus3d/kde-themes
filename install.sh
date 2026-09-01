#!/usr/bin/env bash
# Installs the forked KDE themes for the current user.
# Nothing outside ~/.local/share is touched, and the original themes are left
# alone, so you can always switch back.
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Aurorae window decorations
dest="$HOME/.local/share/aurorae/themes"
mkdir -p "$dest"
for theme in CarlSlim ScratchySlim; do
    rm -rf "${dest:?}/$theme"
    cp -r "$src/aurorae/$theme" "$dest/"
    echo "installed window decoration: $theme"
done

# Plasma style (desktop theme)
dest="$HOME/.local/share/plasma/desktoptheme"
mkdir -p "$dest"
for theme in Carl-custom; do
    rm -rf "${dest:?}/$theme"
    cp -r "$src/desktoptheme/$theme" "$dest/"
    echo "installed plasma style: $theme"
done

cat <<'MSG'

Done. Now pick them in System Settings:

  Colors & Themes > Window Decorations  ->  CarlSlim or ScratchySlim
  Colors & Themes > Plasma Style        ->  Carl-custom

Both KWin and Plasma cache themes in memory, so if one of these was already
selected the change will not show up on its own:

  window decoration:  switch to another decoration and back
  plasma style:       rm -f ~/.cache/plasma_theme_*.kcache
                      kquitapp6 plasmashell && setsid plasmashell &
MSG
