#!/bin/sh

# ci_post_clone.sh — hook post-clone de Xcode Cloud
#
# Xcode Cloud clona el repo y ejecuta este script ANTES del Archive. Prepara
# todo lo que Xcode necesita para compilar un proyecto Flutter:
#   1. Instala Flutter (la versión de .fvmrc, o FLUTTER_VERSION si se define)
#   2. Ejecuta `flutter pub get` (genera Generated.xcconfig y .symlinks)
#   3. Ejecuta `pod install` para integrar los plugins
#   4. Usa el número de build de Xcode Cloud para que nunca se repita
#
# Variables de entorno opcionales en el workflow de Xcode Cloud:
#   FLUTTER_VERSION  — tag exacto de Flutter (ej. "3.47.1"). Por defecto, el de .fvmrc.
#   FLUTTER_CHANNEL  — canal a usar si no hay versión (default: stable)
#
# Referencia: https://developer.apple.com/documentation/xcode/writing-custom-build-scripts

set -e
set -u
set -o pipefail 2>/dev/null || true

log() { echo "[ci_post_clone] $*"; }
fail() { echo "[ci_post_clone] ERROR: $*" >&2; exit 1; }

# REPO_ROOT está dos niveles arriba de ios/ci_scripts/.
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
log "Project root: $REPO_ROOT"

# ── 1. Resolver la versión de Flutter ─────────────────────────────────────────
if [ -z "${FLUTTER_VERSION:-}" ] && [ -f "$REPO_ROOT/.fvmrc" ]; then
  FLUTTER_VERSION="$(sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$REPO_ROOT/.fvmrc" | head -1)"
fi
FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"
FLUTTER_BRANCH="${FLUTTER_VERSION:-$FLUTTER_CHANNEL}"
FLUTTER_HOME="$HOME/flutter"
FLUTTER="$FLUTTER_HOME/bin/flutter"
log "Flutter solicitado: $FLUTTER_BRANCH"

# ── 2. Instalar Flutter ───────────────────────────────────────────────────────
if [ ! -x "$FLUTTER" ]; then
  log "Clonando Flutter ($FLUTTER_BRANCH)…"
  git clone --depth 1 --branch "$FLUTTER_BRANCH" \
    https://github.com/flutter/flutter.git "$FLUTTER_HOME" \
    || fail "No se pudo clonar Flutter en la rama/tag '$FLUTTER_BRANCH'."
else
  log "Flutter ya está en $FLUTTER_HOME — se omite la clonación."
fi

export PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH"
flutter --version || fail "El binario de flutter no funciona."

log "flutter precache --ios…"
flutter precache --ios

# El proyecto usa CocoaPods. Si Swift Package Manager queda activo, Xcode Cloud
# exige un Package.resolved y el Archive falla con "a resolved file is required
# when automatic dependency resolution is disabled".
log "Desactivando Swift Package Manager (se usa CocoaPods)…"
flutter config --no-enable-swift-package-manager

# ── 3. Dependencias Dart ──────────────────────────────────────────────────────
log "flutter pub get…"
cd "$REPO_ROOT"
flutter pub get

# ── 4. Dependencias CocoaPods ─────────────────────────────────────────────────
log "Asegurando CocoaPods…"
gem install cocoapods --user-install --no-document >/dev/null 2>&1 || true
GEM_USER_DIR="$(ruby -e 'puts Gem.user_dir' 2>/dev/null || echo "$HOME/.gem")"
export GEM_HOME="$GEM_USER_DIR"
export PATH="$GEM_USER_DIR/bin:$PATH"

cd "$REPO_ROOT/ios"
log "pod install --repo-update…"
pod install --repo-update || fail "pod install falló."

# ── 5. Número de build único para App Store Connect ───────────────────────────
# Info.plist toma CFBundleVersion de $(FLUTTER_BUILD_NUMBER), que por defecto es
# el "+N" de pubspec.yaml. Si ese número ya se subió, App Store Connect rechaza
# el build. CI_BUILD_NUMBER de Xcode Cloud siempre crece.
if [ -n "${CI_BUILD_NUMBER:-}" ]; then
  log "Usando CI_BUILD_NUMBER=$CI_BUILD_NUMBER como número de build…"
  cd "$REPO_ROOT"
  flutter build ios --config-only --release --no-codesign \
    --build-number="$CI_BUILD_NUMBER" || fail "flutter build ios --config-only falló."
fi

log "Listo: Flutter y Pods preparados para el Archive."
