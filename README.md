# KindleVue

A macOS menu bar app that overlays a warm, matte tint and film grain across every screen — makes your display feel less like a backlit panel, more like paper.

## Download

No Xcode, no terminal, no build step needed.

1. [Download KindleVue.dmg](https://github.com/Chieler/KindleVue/raw/main/KindleVue.dmg)
2. Double-click the downloaded dmg to mount it.
3. Drag `KindleVue.app` onto the `Applications` shortcut in the window that opens.
4. Open `KindleVue` from Applications (Launchpad or Spotlight). macOS will warn it's from an unidentified developer (the app is ad-hoc signed, not notarized) — right-click the app → **Open** → **Open** again to confirm. You only need to do this once.
5. Look for the 📄 icon in the menu bar — that means it's running.

If step 4's warning doesn't show an "Open" option, run this once in Terminal, then try again:

```
xattr -dr com.apple.quarantine /Applications/KindleVue.app
```

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
open KindleVue.app
```

Requires Xcode command line tools. Only needed if you want to build it yourself instead of using the download above.

## License

MIT
