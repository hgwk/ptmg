import XCTest
@testable import PortManager

final class ExportServiceTests: XCTestCase {
    func testGenerateTSV() {
        let ports = [
            PortInfo(port: 3000, pid: 100, processName: "node", protocolType: "TCP", bindAddress: "127.0.0.1"),
            PortInfo(port: 5432, pid: 200, processName: "postgres", protocolType: "TCP", bindAddress: "*")
        ]
        let tsv = ExportService.generateTSV(from: ports)
        let lines = tsv.components(separatedBy: .newlines)

        XCTAssertEqual(lines[0], "Port\tPID\tProcess\tProtocol\tBind Address\tCategory")
        XCTAssertTrue(lines[1].contains("3000"))
        XCTAssertTrue(lines[1].contains("node"))
        XCTAssertTrue(lines[2].contains("5432"))
        XCTAssertTrue(lines[2].contains("postgres"))
    }

    func testGenerateJSON() throws {
        let ports = [
            PortInfo(port: 3000, pid: 100, processName: "node", protocolType: "TCP")
        ]
        let data = try ExportService.generateJSON(from: ports)
        let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        XCTAssertEqual(json?.count, 1)
        XCTAssertEqual(json?.first?["port"] as? Int, 3000)
    }

    func testEmptyTSV() {
        let tsv = ExportService.generateTSV(from: [])
        XCTAssertEqual(tsv, "Port\tPID\tProcess\tProtocol\tBind Address\tCategory")
    }

    func testEmptyJSON() throws {
        let data = try ExportService.generateJSON(from: [])
        let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        XCTAssertTrue(json?.isEmpty ?? false)
    }
}
