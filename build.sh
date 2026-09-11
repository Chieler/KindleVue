#!/bin/bash
# Builds KindleVue.app and packages it into KindleVue.dmg. Run: ./build.sh
set -euo pipefail
cd "$(dirname "$0")"

APP="KindleVue.app"
DMG="KindleVue.dmg"
rm -rf "$APP" "$DMG"
mkdir -p "$APP/Contents/MacOS"

swiftc -O KindleVue.swift -o "$APP/Contents/MacOS/KindleVue"

cat > "$APP/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>KindleVue</string>
    <key>CFBundleDisplayName</key>
    <string>KindleVue</string>
    <key>CFBundleIdentifier</key>
    <string>com.kindlevue.app</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>KindleVue</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>11.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

/usr/bin/codesign --force --deep --sign - "$APP" 2>/dev/null || true

STAGING=$(mktemp -d)
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"
hdiutil create -volname "KindleVue" -srcfolder "$STAGING" -ov -format UDZO "$DMG" -quiet
rm -rf "$STAGING"

echo "Built $APP and $DMG"
