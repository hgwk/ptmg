import Foundation

enum PortChangeType {
    case added
    case removed
}

struct PortChange {
    let port: Int
    let pid: Int?
    let processName: String?
    let changeType: PortChangeType

    var description: String {
        switch changeType {
        case .added:
            if let process = processName {
                return "Port \(port) opened by \(process)"
            }
            return "Port \(port) opened"
        case .removed:
            if let process = processName {
                return "Port \(port) closed (was \(process))"
            }
            return "Port \(port) closed"
        }
    }
}

final class PortChangeDetector {
    private var previousPorts: Set<Int> = []
    private var previousPortInfo: [Int: PortInfo] = [:]

    func detectChanges(current: [PortInfo]) -> [PortChange] {
        let currentPortInfo = current.reduce(into: [:]) { $0[$1.port] = $1 }
        let currentPorts = Set(currentPortInfo.keys)
        var changes: [PortChange] = []

        let addedPorts = currentPorts.subtracting(previousPorts)
        for port in addedPorts {
            guard let info = currentPortInfo[port] else { continue }
            let change = PortChange(
                port: port,
                pid: info.pid,
                processName: info.processName,
                changeType: .added
            )
            changes.append(change)
        }

        let removedPorts = previousPorts.subtracting(currentPorts)
        for port in removedPorts {
            let info = previousPortInfo[port]
            let change = PortChange(
                port: port,
                pid: info?.pid,
                processName: info?.processName,
                changeType: .removed
            )
            changes.append(change)
        }

        updateState(current: current)
        return changes
    }

    private func updateState(current: [PortInfo]) {
        previousPorts = Set(current.map { $0.port })
        previousPortInfo = current.reduce(into: [:]) { dict, info in
            dict[info.port] = info
        }
    }

    func reset() {
        previousPorts.removeAll()
        previousPortInfo.removeAll()
    }

    func initialize(with ports: [PortInfo]) {
        updateState(current: ports)
    }
}
