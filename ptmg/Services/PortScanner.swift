import Foundation
import os

private let logger = Logger(subsystem: "com.ptmg", category: "PortScanner")

final class PortScanner {
    private static let lsofMinimumColumnCount = 9
    private static let lsofProcessNameIndex = 0
    private static let lsofPIDIndex = 1
    private static let lsofAddressIndex = 8
    private static let validPortRange = 1...65535
    private static let validPIDRange = 1...999999

    static func scanListeningPorts() -> [PortInfo] {
        let tcpPorts = scanPorts(protocolType: "TCP")
        let udpPorts = scanPorts(protocolType: "UDP")

        var deduped: [String: PortInfo] = [:]
        for port in tcpPorts {
            let key = "\(port.port)|\(port.pid)|\(port.processName)|\(port.protocolType ?? "")"
            deduped[key] = port
        }
        for port in udpPorts {
            let key = "\(port.port)|\(port.pid)|\(port.processName)|\(port.protocolType ?? "")"
            deduped[key] = port
        }
        return Array(deduped.values).sorted { $0.port < $1.port }
    }

    static func scanListeningPortsAsync(completion: @escaping ([PortInfo]) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            let results = scanListeningPorts()
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }

    private static func scanPorts(protocolType: String) -> [PortInfo] {
        let arguments: [String]
        if protocolType == "TCP" {
            arguments = ["-iTCP", "-sTCP:LISTEN", "-n", "-P"]
        } else {
            arguments = ["-iUDP", "-n", "-P"]
        }

        switch ProcessExecutor.execute(executablePath: "/usr/sbin/lsof", arguments: arguments) {
        case .success(let output):
            return parseLsofOutput(output, protocolType: protocolType)
        case .failure(let error):
            logger.error("Error scanning \(protocolType) ports: \(error.localizedDescription)")
            return []
        }
    }

    private static func parseLsofOutput(_ output: String, protocolType: String) -> [PortInfo] {
        let lines = output.components(separatedBy: .newlines)
        var ports: [PortInfo] = []

        for line in lines.dropFirst() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            let parts = trimmed.split(separator: " ", omittingEmptySubsequences: true)
            guard parts.count >= lsofMinimumColumnCount else { continue }

            let processName = String(parts[lsofProcessNameIndex]).trimmingCharacters(in: .whitespaces)
            guard !processName.isEmpty else { continue }

            guard let pid = Int(parts[lsofPIDIndex]), validPIDRange.contains(pid) else { continue }

            let addressInfo = String(parts[lsofAddressIndex])
            guard let (bindAddress, port) = parseAddress(addressInfo) else { continue }
            guard validPortRange.contains(port) else { continue }

            let portInfo = PortInfo(
                port: port,
                pid: pid,
                processName: processName,
                protocolType: protocolType,
                bindAddress: bindAddress
            )
            ports.append(portInfo)
        }

        return ports
    }

    private static func parseAddress(_ addressInfo: String) -> (bindAddress: String, port: Int)? {
        guard let lastColonIndex = addressInfo.lastIndex(of: ":") else { return nil }

        let portStr = String(addressInfo[addressInfo.index(after: lastColonIndex)...])
        guard let port = Int(portStr) else { return nil }

        let bindAddress = String(addressInfo[..<lastColonIndex])
        return (bindAddress.isEmpty ? "*" : bindAddress, port)
    }
}


