import Foundation

enum DefaultsKey: String {
    case favoritePorts = "FavoritePorts"
    case scanInterval = "scanInterval"
    case notificationSetting = "notificationSetting"
    case launchAtLogin = "launchAtLogin"
}

final class SettingsManager {
    static let shared = SettingsManager()

    static let availableScanIntervals: [TimeInterval] = [1.0, 5.0, 10.0, 30.0]
    static let categoryDisplayOrder: [PortCategory] = [.development, .database, .production, .system, .other]

    private let defaults = UserDefaults.standard

    private init() {}

    var scanInterval: TimeInterval {
        get {
            let saved = defaults.double(forKey: DefaultsKey.scanInterval.rawValue)
            return saved > 0 ? saved : 5.0
        }
        set {
            defaults.set(newValue, forKey: DefaultsKey.scanInterval.rawValue)
        }
    }

    var launchAtLogin: Bool {
        get {
            defaults.bool(forKey: DefaultsKey.launchAtLogin.rawValue)
        }
        set {
            defaults.set(newValue, forKey: DefaultsKey.launchAtLogin.rawValue)
            if #available(macOS 13.0, *) {
                LaunchAtLoginManager.shared.isEnabled = newValue
            }
        }
    }
}
