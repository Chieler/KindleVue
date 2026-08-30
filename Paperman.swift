import Cocoa

// paperman: menu bar app. Warm/matte alpha overlay + grain over every screen.

let defaults = UserDefaults.standard
let kIntensity = "paperman.intensity"
let kWarmth = "paperman.warmth"
let kGrain = "paperman.grain"
let kEnabled = "paperman.enabled"

func registerDefaults() {
    defaults.register(defaults: [kIntensity: 0.5, kWarmth: 0.5, kGrain: 0.4, kEnabled: true])
}

func grainImage(size: Int) -> NSImage {
    let img = NSImage(size: NSSize(width: size, height: size))
    img.lockFocus()
    for y in 0..<size {
        for x in 0..<size {
            NSColor(white: CGFloat.random(in: 0...1), alpha: 1).setFill()
            NSRect(x: x, y: y, width: 1, height: 1).fill()
        }
    }
    img.unlockFocus()
    return img
}

class OverlayWindow: NSWindow {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

class SliderMenuItemView: NSView {
    let slider: NSSlider
    init(title: String, value: Double, target: AnyObject, action: Selector) {
        slider = NSSlider(value: value, minValue: 0, maxValue: 1, target: target, action: action)
        super.init(frame: NSRect(x: 0, y: 0, width: 220, height: 44))
        let label = NSTextField(labelWithString: title)
        label.font = NSFont.menuFont(ofSize: 11)
        label.frame = NSRect(x: 18, y: 24, width: 180, height: 16)
        slider.frame = NSRect(x: 18, y: 4, width: 184, height: 20)
        addSubview(label)
        addSubview(slider)
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var windows: [OverlayWindow] = []
    var grainLayers: [CALayer] = []
    let grainTile = grainImage(size: 128)

    var intensity: Double { defaults.double(forKey: kIntensity) }
    var warmth: Double { defaults.double(forKey: kWarmth) }
    var grain: Double { defaults.double(forKey: kGrain) }
    var enabled: Bool { defaults.bool(forKey: kEnabled) }

    func applicationDidFinishLaunching(_ notification: Notification) {
        registerDefaults()
        NSApp.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.title = "📄"

        let menu = NSMenu()

        let toggle = NSMenuItem(title: "Enabled", action: #selector(toggleEnabled), keyEquivalent: "")
        toggle.target = self
        toggle.state = enabled ? .on : .off
        menu.addItem(toggle)
        menu.addItem(.separator())

        let intensityItem = NSMenuItem()
        intensityItem.view = SliderMenuItemView(title: "Intensity", value: intensity, target: self, action: #selector(intensityChanged(_:)))
        menu.addItem(intensityItem)

        let warmthItem = NSMenuItem()
        warmthItem.view = SliderMenuItemView(title: "Warmth", value: warmth, target: self, action: #selector(warmthChanged(_:)))
        menu.addItem(warmthItem)

        let grainItem = NSMenuItem()
        grainItem.view = SliderMenuItemView(title: "Grain", value: grain, target: self, action: #selector(grainChanged(_:)))
        menu.addItem(grainItem)

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu

        NotificationCenter.default.addObserver(self, selector: #selector(rebuildWindows), name: NSApplication.didChangeScreenParametersNotification, object: nil)

        rebuildWindows()
    }

    @objc func toggleEnabled() {
        defaults.set(!enabled, forKey: kEnabled)
        statusItem.menu?.item(at: 0)?.state = enabled ? .on : .off
        applyValues()
    }

    @objc func intensityChanged(_ sender: NSSlider) {
        defaults.set(sender.doubleValue, forKey: kIntensity)
        applyValues()
    }

    @objc func warmthChanged(_ sender: NSSlider) {
        defaults.set(sender.doubleValue, forKey: kWarmth)
        applyValues()
    }

    @objc func grainChanged(_ sender: NSSlider) {
        defaults.set(sender.doubleValue, forKey: kGrain)
        applyValues()
    }

    func tintColor() -> NSColor {
        let w = CGFloat(warmth)
        let base: CGFloat = 0.85
        return NSColor(red: base + w * 0.05, green: base - w * 0.03, blue: base - w * 0.25, alpha: 1)
    }

    @objc func rebuildWindows() {
        for w in windows { w.orderOut(nil) }
        windows.removeAll()
        grainLayers.removeAll()

        for screen in NSScreen.screens {
            let w = OverlayWindow(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false)
            w.isOpaque = false
            w.ignoresMouseEvents = true
            w.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
            w.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
            w.hasShadow = false

            let grainLayer = CALayer()
            grainLayer.frame = CGRect(origin: .zero, size: screen.frame.size)
            grainLayer.backgroundColor = NSColor(patternImage: grainTile).cgColor

            let content = NSView(frame: screen.frame)
            content.wantsLayer = true
            content.layer?.addSublayer(grainLayer)
            w.contentView = content

            windows.append(w)
            grainLayers.append(grainLayer)
        }
        applyValues()
    }

    func applyValues() {
        let alpha = CGFloat(intensity) * 0.3
        let color = tintColor()
        let grainOpacity = Float(grain) * 0.08
        let on = enabled

        for w in windows {
            w.backgroundColor = color.withAlphaComponent(alpha)
            if on { w.orderFrontRegardless() } else { w.orderOut(nil) }
        }
        for layer in grainLayers {
            layer.opacity = on ? grainOpacity : 0
        }
    }
}

registerDefaults()
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
