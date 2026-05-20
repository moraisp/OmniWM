#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="/Applications/OmniWM.app"
CLI_LINK="/opt/homebrew/bin/omniwmctl"

"$ROOT_DIR/Scripts/package-dev-app.sh" debug

osascript -e 'tell application "OmniWM" to quit' >/dev/null 2>&1 || true
for _ in {1..20}; do
  if ! pgrep -x OmniWM >/dev/null; then
    break
  fi
  sleep 0.25
done

if [ -d "$APP_DIR" ]; then
  rm -rf "$APP_DIR/Contents"
  ditto "$ROOT_DIR/dist/OmniWM.app/Contents" "$APP_DIR/Contents"
else
  ditto "$ROOT_DIR/dist/OmniWM.app" "$APP_DIR"
fi
ln -sf "$APP_DIR/Contents/MacOS/omniwmctl" "$CLI_LINK"

open "$APP_DIR"
echo "Installed and opened $APP_DIR"
