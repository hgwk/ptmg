import Foundation

enum PortCategory {
    case development    // 3000-9000
    case database       // 5432, 27017, 6379, 3306
    case production     // 80, 443, 8080
    case system         // < 1024 (other)
    case other

    var icon: String {
        switch self {
        case .development: return "💻"
        case .database: return "🗄️"
        case .production: return "🌐"
        case .system: return "⚙️"
        case .other: return "📡"
        }
    }

    var description: String {
        switch self {
        case .development: return "Dev"
        case .database: return "DB"
        case .production: return "Prod"
        case .system: return "Sys"
        case .other: return "Other"
        }
    }
}

struct PortInfo: Identifiable, Hashable {
    let id = UUID()
    let port: Int
    let pid: Int
    let processName: String
    let protocolType: String? // TCP/UDP - Instance A will populate
    let bindAddress: String? // 127.0.0.1, 0.0.0.0, etc - Instance A will populate

    var category: PortCategory {
        switch port {
        case 3000...9000:
            return .development
        case 5432, 27017, 6379, 3306:
            return .database
        case 80, 443, 8080:
            return .production
        case 0..<1024:
            return .system
        default:
            return .other
        }
    }

    var displayText: String {
        var text = ":\(port)  \(processName)  (\(pid))"
        if let proto = protocolType {
            text += "  [\(proto)]"
        }
        return text
    }

    // For backward compatibility
    init(port: Int, pid: Int, processName: String, protocolType: String? = nil, bindAddress: String? = nil) {
        self.port = port
        self.pid = pid
        self.processName = processName
        self.protocolType = protocolType
        self.bindAddress = bindAddress
    }

    // Hashable conformance: exclude UUID from hash/equality
    func hash(into hasher: inout Hasher) {
        hasher.combine(port)
        hasher.combine(pid)
        hasher.combine(processName)
        hasher.combine(protocolType)
        hasher.combine(bindAddress)
    }

    static func == (lhs: PortInfo, rhs: PortInfo) -> Bool {
        lhs.port == rhs.port &&
        lhs.pid == rhs.pid &&
        lhs.processName == rhs.processName &&
        lhs.protocolType == rhs.protocolType &&
        lhs.bindAddress == rhs.bindAddress
    }
}

extension PortInfo: CustomStringConvertible {
    var description: String {
        return displayText
    }
}

extension PortInfo: CustomDebugStringConvertible {
    var debugDescription: String {
        let proto = protocolType ?? "?"
        let addr = bindAddress ?? "*"
        return "PortInfo(port: \(port), pid: \(pid), process: \(processName), proto: \(proto), addr: \(addr))"
    }
}
