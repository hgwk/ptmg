import Cocoa

final class MenuBuilder {
    private weak var target: MenuBarController?

    init(target: MenuBarController) {
        self.target = target
    }

    func buildMenu(
        statusItem: NSStatusItem,
        portsCount: Int,
        filteredPorts: [PortInfo],
        searchText: String,
        currentSort: SortOption,
        isScanStale: Bool = false
    ) {
        let menu = NSMenu()

        addHeader(to: menu, portsCount: portsCount, isScanStale: isScanStale)
        addSearchSection(to: menu, searchText: searchText)
        addSortSection(to: menu, currentSort: currentSort)
        menu.addItem(NSMenuItem.separator())
        addPortsList(to: menu, filteredPorts: filteredPorts)
        menu.addItem(NSMenuItem.separator())
        addRefresh(to: menu)
        menu.addItem(NSMenuItem.separator())
        addLaunchAtLogin(to: menu)
        addQuit(to: menu)

        statusItem.menu = menu
    }

    private func addHeader(to menu: NSMenu, portsCount: Int, isScanStale: Bool) {
        let countText = portsCount > 0 ? " (\(portsCount))" : ""
        let title = isScanStale ? "Port Manager\(countText) ⚠️" : "Port Manager\(countText)"
        let titleItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)

        if isScanStale {
            let staleItem = NSMenuItem(title: "Scan failed — showing cached data", action: nil, keyEquivalent: "")
            staleItem.isEnabled = false
            menu.addItem(staleItem)
        }

        menu.addItem(NSMenuItem.separator())
    }

    private func addSearchSection(to menu: NSMenu, searchText: String) {
        let searchTitle = searchText.isEmpty ? "Search..." : "Search: \"\(searchText)\""
        let searchItem = NSMenuItem(
            title: searchTitle,
            action: #selector(MenuBarController.showSearchDialog),
            keyEquivalent: "f"
        )
        searchItem.target = target
        menu.addItem(searchItem)
    }

    private func addSortSection(to menu: NSMenu, currentSort: SortOption) {
        let sortMenu = NSMenu()
        for option in [SortOption.port, .process] {
            let item = NSMenuItem(
                title: option.rawValue,
                action: #selector(MenuBarController.changeSortOption(_:)),
                keyEquivalent: ""
            )
            item.target = target
            item.representedObject = option
            item.state = (option == currentSort) ? .on : .off
            sortMenu.addItem(item)
        }
        let sortItem = NSMenuItem(title: "Sort By", action: nil, keyEquivalent: "")
        sortItem.submenu = sortMenu
        menu.addItem(sortItem)
    }

    private func addPortsList(to menu: NSMenu, filteredPorts: [PortInfo]) {
        if filteredPorts.isEmpty {
            let noPortsItem = NSMenuItem(title: "No active ports", action: nil, keyEquivalent: "")
            noPortsItem.isEnabled = false
            menu.addItem(noPortsItem)
            return
        }

        for port in filteredPorts {
            let portItem = NSMenuItem(
                title: port.displayText,
                action: #selector(MenuBarController.killProcess(_:)),
                keyEquivalent: ""
            )
            portItem.target = target
            portItem.representedObject = port.pid
            menu.addItem(portItem)
        }
    }

    private func addRefresh(to menu: NSMenu) {
        let refreshItem = NSMenuItem(
            title: "Refresh",
            action: #selector(MenuBarController.refreshPorts),
            keyEquivalent: "r"
        )
        refreshItem.target = target
        menu.addItem(refreshItem)
    }

    private func addLaunchAtLogin(to menu: NSMenu) {
        if #available(macOS 13.0, *) {
            let isEnabled = LaunchAtLoginManager.shared.isEnabled
            let title = isEnabled ? "Launch at Login ✓" : "Launch at Login"
            let item = NSMenuItem(
                title: title,
                action: #selector(MenuBarController.toggleLaunchAtLogin),
                keyEquivalent: ""
            )
            item.target = target
            menu.addItem(item)
        }
    }

    private func addQuit(to menu: NSMenu) {
        let quitItem = NSMenuItem(title: "Quit", action: #selector(MenuBarController.quit), keyEquivalent: "q")
        quitItem.target = target
        menu.addItem(quitItem)
    }
}
