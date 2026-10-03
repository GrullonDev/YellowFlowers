#!/usr/bin/env bash
# Sube el PATCH (y el build) automáticamente y genera el .ipa para App Store Connect.
#
# Uso:
#   scripts/release_ios.sh           # 1.1.4+2 -> 1.1.5+3 y compila
#   scripts/release_ios.sh minor     # sube MINOR en lugar de PATCH
#   scripts/release_ios.sh major     # sube MAJOR en lugar de PATCH
#
# Usa fvm si está instalado; si no, el flutter del PATH.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if command -v fvm >/dev/null 2>&1; then
  FLUTTER=(fvm flutter)
else
  FLUTTER=(flutter)
fi

"$ROOT/scripts/bump_version.sh" "${1:-patch}"

# Limpia archivos AppleDouble (._*) que macOS crea en discos externos.
find . -name '._*' -not -path './.git/*' -delete 2>/dev/null || true
find .git -name '._*' -delete 2>/dev/null || true

"${FLUTTER[@]}" precache --ios
"${FLUTTER[@]}" pub get
(cd ios && pod install)
"${FLUTTER[@]}" build ipa --release

VERSION="$(grep -E '^version:' pubspec.yaml | sed -E 's/^version:[[:space:]]*//')"
echo
echo "Listo: versión $VERSION"
echo "Sube build/ios/ipa/*.ipa con Transporter, o abre build/ios/archive/Runner.xcarchive en Xcode."
echo "No olvides hacer commit del cambio de versión:"
echo "  git commit -am \"chore: release $VERSION\""
