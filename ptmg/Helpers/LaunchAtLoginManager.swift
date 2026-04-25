import Foundation
import ServiceManagement
import os

private let logger = Logger(subsystem: "com.ptmg", category: "LaunchAtLogin")

@available(macOS 13.0, *)
final class LaunchAtLoginManager {
    static let shared = LaunchAtLoginManager()

    private init() {}

    var isEnabled: Bool {
        get {
            SMAppService.mainApp.status == .enabled
        }
        set {
            do {
                if newValue {
                    if SMAppService.mainApp.status == .enabled {
                        try? SMAppService.mainApp.unregister()
                    }
                    try SMAppService.mainApp.register()
                    logger.info("Launch at login enabled")
                } else {
                    try SMAppService.mainApp.unregister()
                    logger.info("Launch at login disabled")
                }
            } catch {
                logger.error("Failed to \(newValue ? "enable" : "disable") launch at login: \(error.localizedDescription)")
            }
        }
    }

}
