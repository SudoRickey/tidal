
#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

QS_DIR="$CONFIG_HOME/quickshell"
MATUGEN_DIR="$CONFIG_HOME/matugen"
MATUGEN_CONFIG="$MATUGEN_DIR/config.toml"
TEMPLATE="$MATUGEN_DIR/templates/tidal-colors.json"
COLOR_OUTPUT="$CACHE_HOME/matugen/colors.json"
BACKUP_DIR="$DATA_HOME/tidal/backups/$(date +%Y%m%d-%H%M%S)"

echo "================================"
echo "         Tidal Installer"
echo "================================"
echo
echo "Source: $REPO_DIR"
echo "Target: $QS_DIR"
echo

# Check required commands.
for cmd in rsync python3; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: Required command not found: $cmd"
        exit 1
    fi
done

# Check required repository files.
for file in shell.qml config/Colors.qml matugen/templates/colors.json; do
    if [[ ! -f "$REPO_DIR/$file" ]]; then
        echo "ERROR: Missing required file: $file"
        exit 1
    fi
done

# Refuse to install directly from the live target directory.
if [[ "$(realpath "$REPO_DIR")" == "$(realpath -m "$QS_DIR")" ]]; then
    echo "ERROR: Clone Tidal outside your live Quickshell config."
    echo
    echo "Example:"
    echo "  git clone https://github.com/SudoRickey/tidal.git ~/Tidal"
    echo "  cd ~/Tidal"
    echo "  ./install.sh"
    exit 1
fi

# Check the color template before modifying anything.
python3 - "$REPO_DIR/matugen/templates/colors.json" <<'PY'
import json
import pathlib
import sys

json.loads(pathlib.Path(sys.argv[1]).read_text())
PY

# Don't overwrite anything until the user agrees.
if [[ -d "$QS_DIR" || -f "$MATUGEN_CONFIG" || -f "$TEMPLATE" ]]; then
    echo "Existing configuration detected."
    echo "A backup will be created before installation."
    echo "Files with matching names may be overwritten."
    echo
    read -r -p "Continue with installation? [y/N] " answer
    case "$answer" in
        y|Y|yes|YES) ;;
        *)
            echo "Installation cancelled."
            exit 0
            ;;
    esac
fi

# Back up existing files before modifying them.
mkdir -p "$BACKUP_DIR"

if [[ -d "$QS_DIR" ]]; then
    cp -a "$QS_DIR" "$BACKUP_DIR/quickshell"
    echo "Backed up Quickshell config."
fi

if [[ -f "$MATUGEN_CONFIG" ]]; then
    mkdir -p "$BACKUP_DIR/matugen"
    cp -a "$MATUGEN_CONFIG" "$BACKUP_DIR/matugen-config.toml"
    echo "Backed up Matugen config."
fi

if [[ -f "$TEMPLATE" ]]; then
    mkdir -p "$BACKUP_DIR/matugen"
    cp -a "$TEMPLATE" "$BACKUP_DIR/matugen/tidal-colors.json"
    echo "Backed up Tidal Matugen template."
fi

# Create destination directories.
mkdir -p "$QS_DIR" "$MATUGEN_DIR/templates" "$CACHE_HOME/matugen"

# Copy Tidal's shell files without copying Git metadata or installer docs.
# Existing files with matching names are updated; unrelated files remain.
rsync -a \
    --exclude='.git/' \
    --exclude='README.md' \
    --exclude='LICENSE' \
    --exclude='install.sh' \
    --exclude='matugen/' \
    "$REPO_DIR/" "$QS_DIR/"

# Adapt Colors.qml to the current user's cache path.
python3 - "$QS_DIR/config/Colors.qml" "$COLOR_OUTPUT" <<'PY'
import json
import pathlib
import re
import sys

qml_path = pathlib.Path(sys.argv[1])
output_path = sys.argv[2]
content = qml_path.read_text()

pattern = r'(?m)^(\s*path:\s*)".*/matugen/colors\.json"(\s*)$'
updated, count = re.subn(
    pattern,
    lambda match: match.group(1) + json.dumps(output_path) + match.group(2),
    content,
    count=1,
)

if count != 1:
    raise SystemExit(
        "ERROR: Could not find the Matugen colors.json path in Colors.qml. "
        "No path was changed."
    )

qml_path.write_text(updated)
PY

# Install Tidal's own template without replacing another template.
install -m 0644 \
    "$REPO_DIR/matugen/templates/colors.json" \
    "$TEMPLATE"

# Add or update only the dedicated [templates.tidal] TOML section.
# Other Matugen sections, including [templates.quickshell], are preserved.
python3 - "$MATUGEN_CONFIG" "$TEMPLATE" "$COLOR_OUTPUT" <<'PY'
import json
import pathlib
import re
import sys
import tomllib

config_path = pathlib.Path(sys.argv[1])
template_path = sys.argv[2]
output_path = sys.argv[3]

if config_path.exists():
    original = config_path.read_text()
else:
    original = "[config]\nreload_apps = false\n"

# Remove the previous Tidal section, if present, to make reruns safe.
lines = original.splitlines()
kept = []
in_tidal_section = False

for line in lines:
    stripped = line.strip()

    if re.match(r"^\[.*\]\s*(#.*)?$", stripped):
        header = stripped.split("#", 1)[0].strip()
        in_tidal_section = header == "[templates.tidal]"
        if in_tidal_section:
            continue

    if not in_tidal_section:
        kept.append(line)

base = "\n".join(kept).rstrip()

section = (
    "\n\n[templates.tidal]\n"
    f"input_path = {json.dumps(template_path)}\n"
    f"output_path = {json.dumps(output_path)}\n"
)

updated = (base + section).lstrip("\n") + "\n"

# Validate the completed TOML before writing it.
tomllib.loads(updated)
config_path.write_text(updated)
PY

echo
echo "================================"
echo "       Installation done"
echo "================================"
echo
echo "Quickshell files: $QS_DIR"
echo "Matugen config:   $MATUGEN_CONFIG"
echo "Matugen template: $TEMPLATE"
echo "Color output:     $COLOR_OUTPUT"
echo "Backup:           $BACKUP_DIR"
echo

if command -v matugen >/dev/null 2>&1; then
    echo "Matugen detected: $(matugen --version)"
    echo "Run Matugen with your preferred wallpaper to generate colors."
else
    echo "WARNING: Matugen is not installed."
    echo "Install Matugen to enable dynamic colors."
fi

echo
echo "Restart Quickshell after reviewing the configuration."
