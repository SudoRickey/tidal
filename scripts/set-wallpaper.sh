
#!/usr/bin/env bash
set -euo pipefail

wallpaper="${1:?Select a wallpaper first}"
[[ -f "$wallpaper" ]] || {
    echo "Wallpaper not found: $wallpaper" >&2
    exit 1
}

mkdir -p "$HOME/.config/quickshell/state"
printf '%s\n' "$wallpaper" > "$HOME/.config/quickshell/state/current-wallpaper"

pkill -x swaybg 2>/dev/null || true
swaybg -i "$wallpaper" -m fill >/dev/null 2>&1 &

matugen image --source-color-index 0 --quiet "$wallpaper" || {
    echo "Wallpaper applied, but Matugen failed." >&2
}

