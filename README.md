# Papershade

A macOS menu bar app that overlays a warm, matte tint and film grain across every screen — makes your display feel less like a backlit panel, more like paper.

## Download

No Xcode, no terminal, no build step needed.

1. **[Download Papershade.dmg](https://github.com/Chieler/KindleVue/raw/main/Papershade.dmg)**
2. Double-click the downloaded DMG.
3. Drag `Papershade.app` onto the `Applications` shortcut in the window that opens.
4. Open `Papershade` from Applications (Launchpad or Spotlight).
5. Look for the Papershade waves in the menu bar — that means it's running.

That’s it. The download is signed and notarized by Apple, so macOS should open it normally.

## Controls

Click the menu bar icon for:

- **Enabled** — toggle the overlay on/off
- **Intensity** — how strong the tint is
- **Warmth** — how warm/amber the tint is
- **Grain** — film grain opacity

Settings persist across launches (`UserDefaults`).

## How it works

Draws a borderless, click-through, always-on-top window over each screen (`NSScreen.screens`), tinted with a warm color at low alpha, plus a tiled grain texture layer. Rebuilds automatically on screen configuration changes (external monitor plugged in, resolution change, etc).

## Building from source

```
./build.sh
```

`build.sh` requires the `Developer ID Application: Chieler Li (2DS36Z35HX)` certificate in your login keychain. To use a different identity, set `SIGNING_IDENTITY` to its full Keychain name.

### Notarizing a release

Before the first release, create an app-specific password at [appleid.apple.com](https://appleid.apple.com/) and store it locally (this password is not added to the repository):

```
xcrun notarytool store-credentials Papershade-notary \
  --apple-id "YOUR_APPLE_ID" \
  --team-id "2DS36Z35HX" \
  --password "YOUR_APP_SPECIFIC_PASSWORD"
```

Then create a signed, notarized release:

```
./build.sh
./notarize.sh
```

Only upload `Papershade.dmg` after `notarize.sh` reports success. This requires Xcode command line tools.

## License

MIT
