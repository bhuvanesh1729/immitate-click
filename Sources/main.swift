import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let controller = KeepAwakeController()
    private var window: NSWindow!
    private var timer: Timer?
    private let status = NSTextField(labelWithString: "Inactive")
    private let detail = NSTextField(wrappingLabelWithString: "Ready when you are.")
    private let startButton = NSButton(title: "Start", target: nil, action: nil)
    private let stopButton = NSButton(title: "Stop", target: nil, action: nil)

    func applicationDidFinishLaunching(_ notification: Notification) {
        let menu = NSMenu()
        let appItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Quit immitate click", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appItem.submenu = appMenu
        menu.addItem(appItem)
        NSApp.mainMenu = menu

        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 440, height: 300),
                          styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
        window.title = "immitate click"
        window.isReleasedWhenClosed = false
        window.center()

        let symbol = NSImageView(image: NSImage(systemSymbolName: "bolt.circle.fill", accessibilityDescription: "Keep awake")!)
        symbol.contentTintColor = .controlAccentColor
        symbol.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 36, weight: .regular)
        let title = NSTextField(labelWithString: "immitate click")
        title.font = .systemFont(ofSize: 24, weight: .semibold)
        status.font = .systemFont(ofSize: 15, weight: .semibold)
        detail.alignment = .center
        detail.font = .systemFont(ofSize: 12)
        detail.textColor = .secondaryLabelColor
        let description = NSTextField(wrappingLabelWithString: "Keep your Mac and display awake while active.\nAutomatic lock rules still apply.")
        description.alignment = .center
        description.textColor = .secondaryLabelColor
        description.font = .systemFont(ofSize: 13)

        startButton.target = self
        startButton.action = #selector(start)
        startButton.bezelStyle = .rounded
        startButton.keyEquivalent = "\r"
        stopButton.target = self
        stopButton.action = #selector(stop)
        stopButton.bezelStyle = .rounded
        let buttons = NSStackView(views: [startButton, stopButton])
        buttons.spacing = 12
        buttons.distribution = .fillEqually
        let stack = NSStackView(views: [symbol, title, description, status, detail, buttons])
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        window.contentView!.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: window.contentView!.trailingAnchor, constant: -28),
            stack.centerYAnchor.constraint(equalTo: window.contentView!.centerYAnchor),
            detail.widthAnchor.constraint(equalTo: stack.widthAnchor),
            buttons.widthAnchor.constraint(equalToConstant: 220)
        ])
        updateStatus()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.controller.refresh()
            self?.updateStatus()
        }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func start() {
        controller.start()
        updateStatus()
    }

    @objc private func stop() {
        controller.stop()
        updateStatus()
    }

    private func updateStatus() {
        status.stringValue = controller.isActive ? "Active" : "Inactive"
        status.textColor = controller.isActive ? .systemGreen : .secondaryLabelColor
        detail.stringValue = controller.errorMessage ?? (controller.isActive ? "Keep-awake is running. Stop or quit to end it." : "Ready when you are.")
        startButton.isEnabled = !controller.isActive
        stopButton.isEnabled = controller.isActive || controller.errorMessage != nil
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
        controller.stop()
    }
}

let application = NSApplication.shared
let delegate = AppDelegate()
application.setActivationPolicy(.regular)
application.delegate = delegate
application.run()
