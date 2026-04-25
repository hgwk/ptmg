import Cocoa
import os

private let logger = Logger(subsystem: "com.ptmg", category: "MenuBarController")

enum SortOption: String, CaseIterable {
    case port = "Port Number"
    case process = "Process Name"
}

/// Manages the menu bar UI, port scanning, and user interactions.
/// All operations are confined to the main actor for AppKit thread safety.
@MainActor
final class MenuBarController: NSObject, NSMenuDelegate, NSSearchFieldDelegate {
    private let statusItem: NSStatusItem
    private var ports: [PortInfo] = []
    private var refreshTimer: Timer?
    private var currentSort: SortOption = .port
    private var searchText: String = ""
    private let changeDetector = PortChangeDetector()
    private var isFirstScan = true
    private var isScanStale = false
    private var cachedScanInterval: TimeInterval = 5.0
    private lazy var menuBuilder = MenuBuilder(target: self)
    private let settings = SettingsManager.shared
    private lazy var searchPopover = createSearchPopover()

    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem
        super.init()
        refreshPorts()
        startAutoRefresh()
        observeSystemEvents()
    }

    private let lowPowerMinInterval: TimeInterval = 30.0

    private func effectiveScanInterval() -> TimeInterval {
        let newInterval: TimeInterval
        if ProcessInfo.processInfo.isLowPowerModeEnabled {
            newInterval = max(settings.scanInterval, lowPowerMinInterval)
        } else {
            newInterval = settings.scanInterval
        }
        if newInterval != cachedScanInterval {
            cachedScanInterval = newInterval
            logger.info("Scan interval updated to \(newInterval)s")
        }
        return cachedScanInterval
    }

    private func startAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: effectiveScanInterval(), repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshPorts()
            }
        }
    }

    private func restartAutoRefresh() {
        refreshTimer?.invalidate()
        startAutoRefresh()
        buildMenu()
    }

    /// Scans for listening ports and updates the menu if changes are detected.
    /// Skips UI updates when no changes occur to avoid menu flicker.
    @objc func refreshPorts() {
        let newPorts = PortScanner.scanListeningPorts()
        let scanFailed = newPorts.isEmpty && !ports.isEmpty

        if scanFailed {
            isScanStale = true
            buildMenu()
            updateStatusIcon()
            return
        }

        isScanStale = false

        if isFirstScan {
            changeDetector.initialize(with: newPorts)
            isFirstScan = false
            ports = newPorts
            buildMenu()
            updateStatusIcon()
        } else {
            let changes = changeDetector.detectChanges(current: newPorts)
            if !changes.isEmpty {
                ports = newPorts
                buildMenu()
                updateStatusIcon()
            }
        }
    }

    private func filteredAndSortedPorts() -> [PortInfo] {
        let filtered: [PortInfo]
        if searchText.isEmpty {
            filtered = ports
        } else {
            filtered = ports.filter { port in
                "\(port.port)".contains(searchText) ||
                port.processName.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch currentSort {
        case .port:
            return filtered.sorted { $0.port < $1.port }
        case .process:
            return filtered.sorted { $0.processName < $1.processName }
        }
    }

    private func buildMenu() {
        menuBuilder.buildMenu(
            statusItem: statusItem,
            portsCount: ports.count,
            filteredPorts: filteredAndSortedPorts(),
            searchText: searchText,
            currentSort: currentSort,
            isScanStale: isScanStale
        )
        statusItem.menu?.delegate = self
    }

    func menuWillOpen(_ menu: NSMenu) {
        refreshPorts()
    }

    @objc func changeSortOption(_ sender: NSMenuItem) {
        guard let option = sender.representedObject as? SortOption else { return }
        currentSort = option
        buildMenu()
    }

    @objc func showSearchDialog() {
        guard let button = statusItem.button else { return }
        searchPopover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        let searchField = (searchPopover.contentViewController?.view as? NSStackView)?
            .arrangedSubviews.first as? NSSearchField
        if let searchField = searchField {
            searchField.stringValue = searchText
            searchField.selectText(nil)
            searchField.window?.makeFirstResponder(searchField)
        }
    }

    private func createSearchPopover() -> NSPopover {
        let popover = NSPopover()
        popover.behavior = .transient

        let searchField = NSSearchField()
        searchField.placeholderString = "Port or process name..."
        searchField.delegate = self
        searchField.target = self
        searchField.action = #selector(searchFieldSubmitted)

        let stackView = NSStackView(views: [searchField])
        stackView.orientation = .horizontal
        stackView.edgeInsets = NSEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        let viewController = NSViewController()
        viewController.view = stackView
        popover.contentViewController = viewController
        return popover
    }

    @objc private func searchFieldSubmitted() {
        searchPopover.close()
        buildMenu()
    }

    func controlTextDidChange(_ obj: Notification) {
        guard let searchField = obj.object as? NSSearchField else { return }
        searchText = searchField.stringValue
    }

    /// Handles port item selection. Verifies PID validity and process identity
    /// before presenting the kill confirmation dialog to prevent accidental termination.
    @objc func killProcess(_ sender: NSMenuItem) {
        guard let pid = sender.representedObject as? Int else { return }
        let portInfo = ports.first { $0.pid == pid }
        let processName = portInfo?.processName ?? "Unknown"

        guard ProcessKiller.isProcessRunning(pid: pid) else {
            AlertManager.showKillResult(success: false, pid: pid, signal: "SIGKILL", error: .notRunning)
            refreshPorts()
            return
        }

        if let currentName = ProcessKiller.processName(pid: pid),
           currentName != processName {
            logger.warning("PID \(pid) reused: expected '\(processName)', found '\(currentName)'. Aborting kill.")
            AlertManager.showKillResult(success: false, pid: pid, signal: "SIGKILL", error: .processNotFound)
            refreshPorts()
            return
        }

        if AlertManager.confirmKillProcess(pid: pid, processName: processName) {
            let (success, error) = ProcessKiller.killProcessWithResult(pid: pid)
            AlertManager.showKillResult(success: success, pid: pid, signal: "SIGKILL", error: error)
            refreshPorts()
        }
    }

    @objc func toggleLaunchAtLogin() {
        if #available(macOS 13.0, *) {
            settings.launchAtLogin = !settings.launchAtLogin
            buildMenu()
        }
    }

    @objc func quit() {
        refreshTimer?.invalidate()
        NSApp.terminate(nil)
    }

    private func updateStatusIcon() {
        guard let button = statusItem.button else { return }

        let symbolName: String
        if isScanStale {
            symbolName = "network.badge.exclamationmark"
        } else if ports.isEmpty {
            symbolName = "network.slash"
        } else {
            symbolName = "network"
        }

        button.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Port Manager")
        button.image?.isTemplate = true
    }

    private func observeSystemEvents() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(powerStateChanged),
            name: NSNotification.Name.NSProcessInfoPowerStateDidChange,
            object: nil
        )
    }

    @objc private func powerStateChanged() {
        restartAutoRefresh()
    }

    deinit {
        refreshTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}
