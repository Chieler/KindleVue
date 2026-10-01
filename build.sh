#!/bin/bash
# Builds Papershade.app and packages it into Papershade.dmg. Run: ./build.sh
set -euo pipefail
cd "$(dirname "$0")"

APP="Papershade.app"
DMG="Papershade.dmg"
SIGNING_IDENTITY="${SIGNING_IDENTITY:-Developer ID Application: Chieler Li (2DS36Z35HX)}"
MODULE_CACHE_PATH="${SWIFT_MODULE_CACHE_PATH:-${TMPDIR:-/tmp}/papershade-swift-module-cache}"
rm -rf "$APP" "$DMG"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
mkdir -p "$MODULE_CACHE_PATH"

swiftc -O -module-cache-path "$MODULE_CACHE_PATH" KindleVue.swift -o "$APP/Contents/MacOS/Papershade"
cp AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
cp StatusIcon.png "$APP/Contents/Resources/StatusIcon.png"
cp StatusIcon@2x.png "$APP/Contents/Resources/StatusIcon@2x.png"

cat > "$APP/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Papershade</string>
    <key>CFBundleDisplayName</key>
    <string>Papershade</string>
    <key>CFBundleIdentifier</key>
    <string>com.papershade.app</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>Papershade</string>
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

# A Developer ID signature, hardened runtime, and secure timestamp are required
# before Apple will notarize an app distributed outside the Mac App Store.
/usr/bin/codesign --force --sign "$SIGNING_IDENTITY" --options runtime --timestamp "$APP"
/usr/bin/codesign --verify --deep --strict --verbose=2 "$APP"

STAGING=$(mktemp -d)
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"
hdiutil create -volname "Papershade" -srcfolder "$STAGING" -ov -format UDZO "$DMG" -quiet
rm -rf "$STAGING"
/usr/bin/codesign --force --sign "$SIGNING_IDENTITY" --timestamp "$DMG"

echo "Built signed $APP and $DMG"
echo "Next: ./notarize.sh"
