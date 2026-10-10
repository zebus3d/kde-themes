#!/usr/bin/env bash
# Reloads the themes after editing them, working around the two caches that
# make edits look like they did nothing.
#
#   ./reload.sh            reload both
#   ./reload.sh kwin       only the window decoration
#   ./reload.sh plasma     only the Plasma style
#   ./reload.sh plasmoid   only the panel-transparency widget
set -euo pipefail

what="${1:-all}"

reload_kwin() {
    local current
    current=$(kreadconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme)
    if [[ -z "$current" ]]; then
        echo "no aurorae decoration active, nothing to do"
        return
    fi
    # KWin caches the theme rc in memory: switching away and back is what
    # actually forces a re-read.
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme "__aurorae__svg__Breeze"
    qdbus6 org.kde.KWin /KWin reconfigure
    sleep 1
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme "$current"
    qdbus6 org.kde.KWin /KWin reconfigure
    echo "window decoration reloaded: $current"
}

reload_plasma() {
    rm -f "$HOME"/.cache/plasma_theme_*.kcache
    kquitapp6 plasmashell >/dev/null 2>&1 || true
    sleep 2
    setsid plasmashell >/dev/null 2>&1 &
    echo "plasma style reloaded (shell restarting)"
}

reload_plasmoid() {
    # The widget's QML is loaded by plasmashell, so a shell restart is what
    # picks up edits. Unlike `plasma` this leaves the theme cache alone.
    kquitapp6 plasmashell >/dev/null 2>&1 || true
    sleep 2
    setsid plasmashell >/dev/null 2>&1 &
    echo "plasmashell restarted (plasmoid reloaded)"
}

case "$what" in
    kwin)     reload_kwin ;;
    plasma)   reload_plasma ;;
    plasmoid) reload_plasmoid ;;
    all)      reload_kwin; reload_plasma ;;
    *)        echo "usage: $0 [all|kwin|plasma|plasmoid]" >&2; exit 1 ;;
esac
