#!/usr/bin/env bash
set -euo pipefail

# ---- Config ----
PROJECT="Linklet.xcodeproj"        # or "MyApp.xcworkspace"
SCHEME="Release"
CONFIG="Release"
INSTALL_DIR="$HOME/Applications"
# ----------------

cd Linklet

BUILD_DIR="$(mktemp -d)"
trap 'rm -rf "$BUILD_DIR"' EXIT

# Pick the right flag based on project vs workspace
if [[ "$PROJECT" == *.xcworkspace ]]; then
  CONTAINER_FLAG=(-workspace "$PROJECT")
else
  CONTAINER_FLAG=(-project "$PROJECT")
fi

echo "Building $SCHEME ($CONFIG)..."
xcodebuild \
  "${CONTAINER_FLAG[@]}" \
  -scheme "$SCHEME" \
  -configuration "$CONFIG" \
  -derivedDataPath "$BUILD_DIR" \
  build

APP_PATH="$(find "$BUILD_DIR/Build/Products/$CONFIG" -maxdepth 1 -name '*.app' | head -n1)"
if [[ -z "$APP_PATH" ]]; then
  echo "Error: no .app found" >&2
  exit 1
fi
APP_NAME="$(basename "$APP_PATH")"

echo "Installing $APP_NAME to $INSTALL_DIR..."
rm -rf "${INSTALL_DIR:?}/$APP_NAME"
cp -R "$APP_PATH" "$INSTALL_DIR/"

echo "Done: $INSTALL_DIR/$APP_NAME"
