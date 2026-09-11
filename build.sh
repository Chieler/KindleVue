#!/bin/bash
# Builds KindleView.app — a double-clickable macOS app bundle. Run: ./build.sh
set -euo pipefail
cd "$(dirname "$0")"

APP="KindleView.app"
rm -rf "$APP" "$APP.zip"
mkdir -p "$APP/Contents/MacOS"

swiftc -O KindleView.swift -o "$APP/Contents/MacOS/KindleView"

cat > "$APP/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>KindleView</string>
    <key>CFBundleDisplayName</key>
    <string>KindleView</string>
    <key>CFBundleIdentifier</key>
    <string>com.kindleview.app</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>KindleView</string>
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

zip -qr "$APP.zip" "$APP"
echo "Built $APP and $APP.zip"
