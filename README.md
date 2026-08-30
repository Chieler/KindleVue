# Paperman

A macOS menu bar app that overlays a warm, matte tint and film grain across every screen — makes your display feel less like a backlit panel, more like paper.

## Install

Requires macOS with Xcode command line tools (`swiftc`).

```
swiftc -O Paperman.swift -o paperman
./paperman
```

Look for the 📄 icon in the menu bar.

## Controls

Click the menu bar icon for:

- **Enabled** — toggle the overlay on/off
- **Intensity** — how strong the tint is
- **Warmth** — how warm/amber the tint is
- **Grain** — film grain opacity

Settings persist across launches (`UserDefaults`).

## How it works

Draws a borderless, click-through, always-on-top window over each screen (`NSScreen.screens`), tinted with a warm color at low alpha, plus a tiled grain texture layer. Rebuilds automatically on screen configuration changes (external monitor plugged in, resolution change, etc).

## License

MIT
