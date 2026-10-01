#!/bin/bash
# Submits the signed Papershade DMG to Apple, staples its ticket, and verifies it.
# Run ./build.sh first. One-time setup is documented in README.md.
set -euo pipefail
cd "$(dirname "$0")"

DMG="Papershade.dmg"
NOTARY_PROFILE="${NOTARY_PROFILE:-Papershade-notary}"

if [[ ! -f "$DMG" ]]; then
    echo "Missing $DMG. Run ./build.sh first." >&2
    exit 1
fi

xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "$DMG"
xcrun stapler validate "$DMG"

echo "Notarized and stapled $DMG"
