import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var menuBarController: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let newStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        self.statusItem = newStatusItem

        if let button = newStatusItem.button {
            button.image = NSImage(systemSymbolName: "network", accessibilityDescription: "Port Manager")
            button.image?.isTemplate = true
        }

        self.menuBarController = MenuBarController(statusItem: newStatusItem)
        NSApp.setActivationPolicy(.accessory)
    }
}

let arguments = CommandLine.arguments
let executableName = URL(fileURLWithPath: arguments[0]).lastPathComponent

if executableName == "pm" || arguments.count > 1 {
    CLI.run(arguments: arguments)
} else {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.run()
}
