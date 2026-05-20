#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${1:-debug}"
CONFIG_DIR="$(tr '[:lower:]' '[:upper:]' <<< "${CONFIG:0:1}")${CONFIG:1}"
APP_DIR="$ROOT_DIR/dist/OmniWM.app"
TMP_DIR="$ROOT_DIR/.tmp/OmniWM-dev-app"
ENTITLEMENTS="$ROOT_DIR/OmniWM.entitlements"
GHOSTTY_LIBRARY_DIR="$("$ROOT_DIR/Scripts/ghostty-preflight.sh" print-library-dir)"
DEFAULT_SIGNING_IDENTITY="OmniWM Local Development"

if [[ -n "${OMNIWM_DEV_SIGN_IDENTITY:-}" ]]; then
  SIGNING_IDENTITY="$OMNIWM_DEV_SIGN_IDENTITY"
elif security find-identity -v -p codesigning | grep -Fq "$DEFAULT_SIGNING_IDENTITY"; then
  SIGNING_IDENTITY="$DEFAULT_SIGNING_IDENTITY"
else
  SIGNING_IDENTITY="-"
fi

build_arch() {
  local arch="$1"
  local triple="$2"

  echo "Building $CONFIG for $arch..."
  LIBRARY_PATH="$GHOSTTY_LIBRARY_DIR${LIBRARY_PATH:+:$LIBRARY_PATH}" \
    swift build -c "$CONFIG" --triple "$triple"
}

build_arch arm64 arm64-apple-macosx15.0
build_arch x86_64 x86_64-apple-macosx15.0

ARM_DIR="$ROOT_DIR/.build/arm64-apple-macosx/$CONFIG"
X64_DIR="$ROOT_DIR/.build/x86_64-apple-macosx/$CONFIG"

echo "Packaging universal app at $APP_DIR..."
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR/Contents/MacOS" "$TMP_DIR/Contents/Resources"

lipo -create "$ARM_DIR/OmniWM" "$X64_DIR/OmniWM" -output "$TMP_DIR/Contents/MacOS/OmniWM"
lipo -create "$ARM_DIR/omniwmctl" "$X64_DIR/omniwmctl" -output "$TMP_DIR/Contents/MacOS/omniwmctl"

cp "$ROOT_DIR/Info.plist" "$TMP_DIR/Contents/Info.plist"
cp "$ROOT_DIR/Resources/AppIcon.icns" "$TMP_DIR/Contents/Resources/AppIcon.icns"
cp -R "$ARM_DIR/OmniWM_OmniWM.bundle" "$TMP_DIR/Contents/Resources/"

if command -v plutil >/dev/null 2>&1; then
  plutil -lint "$TMP_DIR/Contents/Info.plist" >/dev/null
fi

lipo -info "$TMP_DIR/Contents/MacOS/OmniWM"
lipo -info "$TMP_DIR/Contents/MacOS/omniwmctl"

echo "Signing with identity: $SIGNING_IDENTITY"
if [[ "$SIGNING_IDENTITY" == "-" ]]; then
  codesign --force --sign "$SIGNING_IDENTITY" "$TMP_DIR/Contents/MacOS/omniwmctl" >/dev/null
  codesign --force --entitlements "$ENTITLEMENTS" --sign "$SIGNING_IDENTITY" "$TMP_DIR/Contents/MacOS/OmniWM" >/dev/null
  codesign --force --entitlements "$ENTITLEMENTS" --sign "$SIGNING_IDENTITY" "$TMP_DIR" >/dev/null
else
  codesign --force --deep --entitlements "$ENTITLEMENTS" --sign "$SIGNING_IDENTITY" "$TMP_DIR" >/dev/null
fi

rm -rf "$APP_DIR"
mkdir -p "$(dirname "$APP_DIR")"
mv "$TMP_DIR" "$APP_DIR"

codesign --verify --verbose "$APP_DIR"
echo "Done. Open $APP_DIR to run this build."
