
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

echo "Tidal installer"
echo "Target: $QS_DIR"
echo

for cmd in rsync python3; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Missing dependency: $cmd"
        exit 1
    fi
done

if [[ "$(realpath "$REPO_DIR")" == "$(realpath -m "$QS_DIR")" ]]; then
    echo "Please clone Tidal into a separate directory before installing."
    exit 1
fi

if [[ ! -f "$REPO_DIR/shell.qml" ||
      ! -f "$REPO_DIR/config/Colors.qml" ||
      ! -f "$REPO_DIR/matugen/templates/colors.json" ]]; then
    echo "The repository is missing required Tidal files."
    exit 1
fi

mkdir -p "$BACKUP_DIR"

# Back up existing files before changing anything.
if [[ -d "$QS_DIR" ]]; then
    cp -a "$QS_DIR" "$BACKUP_DIR/quickshell"
fi

if [[ -f "$MATUGEN_CONFIG" ]]; then
    mkdir -p "$BACKUP_DIR/matugen"
    cp -a "$MATUGEN_CONFIG" "$BACKUP_DIR/matugen/config.toml"
fi

if [[ -f "$TEMPLATE" ]]; then
    mkdir -p "$BACKUP_DIR/matugen/templates"
    cp -a "$TEMPLATE" "$BACKUP_DIR/matugen/templates/colors.json"
fi

mkdir -p "$QS_DIR" "$MATUGEN_DIR/templates" "$CACHE_HOME/matugen"

# Copy shell files while leaving unrelated files untouched.
rsync -a \
    --exclude='.git/' \
    --exclude='README.md' \
    --exclude='LICENSE' \
    --exclude='install.sh' \
    --exclude='matugen/' \
    "$REPO_DIR/" "$QS_DIR/"

# Set the current user's cache path in the installed color loader.
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

install -m 0644 "$REPO_DIR/matugen/templates/colors.json" "$TEMPLATE"

# Add/update a dedicated Tidal template section without replacing other
# Matugen settings or templates.
python3 - "$MATUGEN_CONFIG" "$TEMPLATE" "$COLOR_OUTPUT" <<'PY'
import pathlib
import re
import sys

config_path = pathlib.Path(sys.argv[1])
template_path = sys.argv[2]
output_path = sys.argv[3]

if config_path.exists():
    content = config_path.read_text()
else:
    content = ""

# Remove only a previous [templates.tidal] section, if present.
lines = content.splitlines()
kept = []
skip = False

for line in lines:
    if re.match(r'^\s*\[.*\]\s*(?:#.*)?$', line):
        skip = line.strip().split("#", 1)[0].strip() == "[templates.tidal]"
    if not skip:
        kept.append(line)

content = "\n".join(kept).rstrip()

# Keep any existing config, including [config] and other templates.
section = (
    "\n\n[templates.tidal]\n"
    f'input_path = "{template_path}"\n'
    f'output_path = "{output_path}"\n'
)

config_path.parent.mkdir(parents=True, exist_ok=True)
config_path.write_text(content + section)
PY

echo
echo "Tidal files installed."
echo "Matugen template: $TEMPLATE"
echo "Generated colors: $COLOR_OUTPUT"
echo "Backup location: $BACKUP_DIR"
echo

if command -v matugen >/dev/null 2>&1; then
    echo "Matugen is installed."
    echo "Generate colors by running your usual Matugen wallpaper command."
else
    echo "WARNING: Matugen is not installed."
    echo "Install Matugen to enable dynamic colors."
fi

echo "Restart Quickshell to load Tidal."
