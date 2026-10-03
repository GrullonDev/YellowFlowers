#!/usr/bin/env bash
# Incrementa la versión de pubspec.yaml (MAJOR.MINOR.PATCH+BUILD).
#
# Uso:
#   scripts/bump_version.sh          # patch: 1.1.4+2 -> 1.1.5+3 (por defecto)
#   scripts/bump_version.sh minor    # 1.1.5+3 -> 1.2.0+4
#   scripts/bump_version.sh major    # 1.2.0+4 -> 2.0.0+5
#   scripts/bump_version.sh build    # solo build: 1.1.4+2 -> 1.1.4+3
#
# El número de build siempre sube, porque App Store Connect y Google Play
# rechazan un build con un número que ya se subió.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBSPEC="$ROOT/pubspec.yaml"
PART="${1:-patch}"

CURRENT="$(grep -E '^version:' "$PUBSPEC" | head -1 | sed -E 's/^version:[[:space:]]*//')"
if [[ ! "$CURRENT" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)(\+([0-9]+))?$ ]]; then
  echo "No se pudo leer la versión de pubspec.yaml: '$CURRENT'" >&2
  exit 1
fi
MAJOR="${BASH_REMATCH[1]}"
MINOR="${BASH_REMATCH[2]}"
PATCH="${BASH_REMATCH[3]}"
BUILD="${BASH_REMATCH[5]:-0}"

case "$PART" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
  build) ;;
  *) echo "Parte desconocida: '$PART' (usa major, minor, patch o build)" >&2; exit 1 ;;
esac
BUILD=$((BUILD + 1))

NEW="$MAJOR.$MINOR.$PATCH+$BUILD"
# awk en lugar de sed -i para funcionar igual en macOS y Linux.
TMP="$(mktemp)"
awk -v v="$NEW" '!done && /^version:/ { print "version: " v; done=1; next } { print }' "$PUBSPEC" > "$TMP"
cat "$TMP" > "$PUBSPEC"  # conserva los permisos del archivo
rm -f "$TMP"

echo "Versión: $CURRENT -> $NEW"
