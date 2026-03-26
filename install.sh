#!/bin/bash
# install.sh — Build SimpleWhoisGeo and install to /Applications
set -e

APP_NAME="SimpleWhoisGeo"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_PATH="/Applications/${APP_NAME}.app"
TEMP_APP="${REPO_DIR}/.build/${APP_NAME}.app"

echo "🛑 Quitting ${APP_NAME} if running..."
osascript -e "quit app \"${APP_NAME}\"" 2>/dev/null || true

echo "🔨 Building ${APP_NAME}..."
cd "$REPO_DIR"
swift build -c release

BINARY_SRC="${REPO_DIR}/.build/release/${APP_NAME}"

if [ ! -f "$BINARY_SRC" ]; then
    echo "❌ Build failed — binary not found"
    exit 1
fi

echo "📦 Assembling ${APP_NAME}.app..."
rm -rf "$TEMP_APP"
mkdir -p "${TEMP_APP}/Contents/MacOS"
mkdir -p "${TEMP_APP}/Contents/Resources"

cp "$BINARY_SRC" "${TEMP_APP}/Contents/MacOS/${APP_NAME}"
chmod +x "${TEMP_APP}/Contents/MacOS/${APP_NAME}"

cat > "${TEMP_APP}/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>SimpleWhoisGeo</string>
    <key>CFBundleIdentifier</key>
    <string>com.baldwinsung.SimpleWhoisGeo</string>
    <key>CFBundleName</key>
    <string>SimpleWhoisGeo</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

echo "📲 Installing to /Applications..."
sudo ditto "$TEMP_APP" "$INSTALL_PATH"

echo ""
echo "✅ Installed: ${INSTALL_PATH}"
echo ""
echo "▶️  Launching..."
open "$INSTALL_PATH"
