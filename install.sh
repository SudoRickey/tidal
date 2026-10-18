
#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

QS_DIR="$CONFIG_HOME/quickshell"
MATUGEN_DIR="$CONFIG_HOME/matugen"
MATUGEN_CONFIG="$MATUGEN_DIR/config.toml"
TEMPLATE="$MATUGEN_DIR/templates/colors.json"
COLOR_OUTPUT="$CACHE_HOME/matugen/colors.json"
BACKUP_DIR="$DATA_HOME/tidal/backups/$(date +%Y%m%d-%H%M%S)"

echo "================================"
echo "        Tidal Installer"
echo "================================"
echo
echo "Source: $REPO_DIR"
echo "Target: $QS_DIR"
echo

# Required tools
for cmd in rsync python3 grep; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: Required command not found: $cmd"
        exit 1
    fi
done

# Check repository files before changing anything.
for file in shell.qml config/Colors.qml matugen/templates/colors.json; do
    if [[ ! -f "$REPO_DIR/$file" ]]; then
        echo "ERROR: Missing required file: $file"
        exit 1
    fi
done

# Avoid copying a directory onto itself.
if [[ "$(realpath "$REPO_DIR")" == "$(realpath -m "$QS_DIR")" ]]; then
    echo "ERROR: Clone Tidal into a separate directory before installing."
    echo "Example:"
    echo "  git clone https://github.com/SudoRickey/tidal.git ~/Tidal"
    echo "  cd ~/Tidal"
    echo "  ./install.sh"
    exit 1
fi

# Back up existing configurations before modifying them.
mkdir -p "$BACKUP_DIR"

if [[ -d "$QS_DIR" ]]; then
    cp -a "$QS_DIR" "$BACKUP_DIR/quickshell"
    echo "Backed up existing Quickshell config."
fi

if [[ -f "$MATUGEN_CONFIG" ]]; then
    mkdir -p "$BACKUP_DIR/matugen"
    cp -a "$MATUGEN_CONFIG" "$BACKUP_DIR/matugen/config.toml"
    echo "Backed up existing Matugen config."
fi

if [[ -f "$TEMPLATE" ]]; then
    mkdir -p "$BACKUP_DIR/matugen/templates"
    cp -a "$TEMPLATE" "$BACKUP_DIR/matugen/templates/colors.json"
    echo "Backed up existing Matugen template."
fi

# Create required directories.
mkdir -p "$QS_DIR" "$MATUGEN_DIR/templates" "$CACHE_HOME/matugen"

# Copy Tidal shell files.
# Existing files with the same names are updated; unrelated files remain.
rsync -a \
    --exclude='.git/' \
    --exclude='README.md' \
    --exclude='LICENSE' \
    --exclude='install.sh' \
    --exclude='matugen/' \
    "$REPO_DIR/" "$QS_DIR/"

# Use the current user's cache path in Colors.qml.
python3 - "$QS_DIR/config/Colors.qml" "$COLOR_OUTPUT" <<'PY'
import pathlib
import sys

qml_path = pathlib.Path(sys.argv[1])
output_path = sys.argv[2]

content = qml_path.read_text()
content = content.replace(
    "/home/rickey/.cache/matugen/colors.json",
    output_path
)

qml_path.write_text(content)
PY

# Install Tidal's Matugen template.
install -m 0644 "$REPO_DIR/matugen/templates/colors.json" "$TEMPLATE"

# Configure Matugen without blindly rewriting an existing config.
if [[ ! -f "$MATUGEN_CONFIG" ]]; then
    cat > "$MATUGEN_CONFIG" <<EOF
[config]
reload_apps = false

[templates.quickshell]
input_path = "$TEMPLATE"
output_path = "$COLOR_OUTPUT"
EOF
    echo "Created Matugen config."
elif ! grep -q '^\[templates\.quickshell\]' "$MATUGEN_CONFIG"; then
    cat >> "$MATUGEN_CONFIG" <<EOF

[templates.quickshell]
input_path = "$TEMPLATE"
output_path = "$COLOR_OUTPUT"
EOF
    echo "Added [templates.quickshell] to Matugen config."
else
    echo
    echo "Existing [templates.quickshell] section found."
    echo "Your Matugen config was preserved."
    echo "Make sure it uses these paths:"
    echo "  input_path = \"$TEMPLATE\""
    echo "  output_path = \"$COLOR_OUTPUT\""
fi

echo
echo "================================"
echo "       Installation done"
echo "================================"
echo
echo "Quickshell files: $QS_DIR"
echo "Matugen template: $TEMPLATE"
echo "Color output:     $COLOR_OUTPUT"
echo "Backup:           $BACKUP_DIR"
echo

if command -v matugen >/dev/null 2>&1; then
    echo "Matugen detected: $(matugen --version)"
else
    echo "WARNING: Matugen is not installed."
    echo "Install Matugen to enable dynamic colors."
fi

echo
echo "Restart Quickshell to load Tidal."
