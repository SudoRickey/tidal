
#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

QS_DIR="$CONFIG_HOME/quickshell"
MATUGEN_DIR="$CONFIG_HOME/matugen"
BACKUP_DIR="$DATA_HOME/tidal/backups/$(date +%Y%m%d-%H%M%S)"

echo "Tidal installer"
echo "Repository: $REPO_DIR"
echo "Target:     $QS_DIR"
echo

for cmd in rsync matugen; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Missing dependency: $cmd"
        echo "Install the missing dependency and run this script again."
        exit 1
    fi
done

if [[ "$REPO_DIR" == "$QS_DIR" ]]; then
    echo "You're running this installer from the live Quickshell config."
    echo "Clone the Tidal repository elsewhere before installing it."
    exit 1
fi

if [[ -e "$QS_DIR" ]]; then
    mkdir -p "$BACKUP_DIR"
    cp -a "$QS_DIR" "$BACKUP_DIR/quickshell"
    echo "Existing Quickshell config backed up to:"
    echo "  $BACKUP_DIR/quickshell"
fi

mkdir -p "$QS_DIR" "$MATUGEN_DIR/templates" "$CACHE_HOME/matugen"

# Copy the repository contents, excluding Git metadata.
rsync -a --exclude='.git/' "$REPO_DIR/" "$QS_DIR/"

# Create a portable Colors.qml with the current user's cache path.
sed "s|/home/rickey/.cache/matugen/colors.json|$CACHE_HOME/matugen/colors.json|g" \
    "$REPO_DIR/config/Colors.qml" > "$QS_DIR/config/Colors.qml"

# Install Tidal's Matugen template from the repository.
if [[ -f "$REPO_DIR/matugen/templates/colors.json" ]]; then
    install -m 0644 \
        "$REPO_DIR/matugen/templates/colors.json" \
        "$MATUGEN_DIR/templates/colors.json"
else
    echo "ERROR: Missing repository file:"
    echo "  matugen/templates/colors.json"
    echo "Create that file before running the installer."
    exit 1
fi

echo
echo "Tidal files copied successfully."
echo
echo "Next: configure Matugen to use:"
echo "  Input:  $MATUGEN_DIR/templates/colors.json"
echo "  Output: $CACHE_HOME/matugen/colors.json"
echo
echo "Your existing Matugen config was not overwritten."
echo "Restart Quickshell after confirming the Matugen config."
