#!/usr/bin/env bash
# Switch the active OpenCode agent profile (cloud | homelab).
#
# Usage:
#   ./scripts/opencode-profile.sh cloud
#   ./scripts/opencode-profile.sh homelab
#   ./scripts/opencode-profile.sh          # show current

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$HOME/.config/opencode/oh-my-openagent.json"
PROFILES_DIR="$ROOT/opencode/profiles"

list_profiles() {
  for f in "$PROFILES_DIR"/*.json; do
    [[ -f "$f" ]] && basename "$f" .json
  done
}

current_profile() {
  if [[ -L "$DEST" ]]; then
    local target
    target="$(readlink "$DEST")"
    basename "$target" .json
  elif [[ -f "$DEST" ]]; then
    echo "(file, not a symlink)"
  else
    echo "(not installed)"
  fi
}

if [[ $# -lt 1 ]]; then
  echo "Active profile: $(current_profile)"
  echo "Available:"
  list_profiles | sed 's/^/  - /'
  exit 0
fi

PROFILE="$1"
SRC="$PROFILES_DIR/${PROFILE}.json"

if [[ ! -f "$SRC" ]]; then
  echo "Unknown profile: $PROFILE" >&2
  echo "Available:" >&2
  list_profiles | sed 's/^/  - /' >&2
  exit 1
fi

mkdir -p "$(dirname "$DEST")"
if [[ -e "$DEST" && ! -L "$DEST" ]]; then
  mv "$DEST" "${DEST}.backup.$(date +%Y%m%d%H%M%S)"
fi
ln -sfn "$SRC" "$DEST"
echo "Linked $DEST -> $SRC"
echo "Active profile: $PROFILE"
