
#!/usr/bin/env bash

set -u

state="$HOME/.config/quickshell/state/current-wallpaper"

[[ -f "$state" ]] || exit 0

IFS= read -r wallpaper < "$state"
[[ -f "$wallpaper" ]] || exit 0

# Restore the wallpaper
pkill -x swaybg 2>/dev/null || true
swaybg -i "$wallpaper" -m fill >/dev/null 2>&1 &

# Restore the matching Matugen colors
if command -v matugen >/dev/null 2>&1; then
    matugen image --source-color-index 0 --quiet "$wallpaper" || true
fi
