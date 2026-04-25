import Foundation

struct ExportablePortInfo: Codable {
    let port: Int
    let pid: Int
    let process: String
    let protocolType: String?
    let bindAddress: String?
    let category: String

    init(from portInfo: PortInfo) {
        self.port = portInfo.port
        self.pid = portInfo.pid
        self.process = portInfo.processName
        self.protocolType = portInfo.protocolType
        self.bindAddress = portInfo.bindAddress
        self.category = portInfo.category.description
    }
}

final class ExportService {
    static func generateJSON(from ports: [PortInfo]) throws -> Data {
        let exportable = ports.map { ExportablePortInfo(from: $0) }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(exportable)
    }

    static func generateTSV(from ports: [PortInfo]) -> String {
        var lines: [String] = []

        let header = "Port\tPID\tProcess\tProtocol\tBind Address\tCategory"
        lines.append(header)

        lines.append(contentsOf: ports.map { port in
            [String(port.port), String(port.pid), port.processName,
             port.protocolType ?? "", port.bindAddress ?? "",
             port.category.description]
            .joined(separator: "\t")
        })

        return lines.joined(separator: "\n")
    }

    static func writeToFile(data: Data, path: URL) throws {
        try data.write(to: path, options: .atomic)
    }

    static func writeToFile(string: String, path: URL) throws {
        try string.write(to: path, atomically: true, encoding: .utf8)
    }
}
