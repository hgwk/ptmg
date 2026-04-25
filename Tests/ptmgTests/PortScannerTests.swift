import XCTest
@testable import PortManager

final class PortScannerTests: XCTestCase {
    func testParseAddressIPv4() {
        let result = parseAddress("127.0.0.1:3000")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.bindAddress, "127.0.0.1")
        XCTAssertEqual(result?.port, 3000)
    }

    func testParseAddressWildcard() {
        let result = parseAddress("*:8080")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.bindAddress, "*")
        XCTAssertEqual(result?.port, 8080)
    }

    func testParseAddressIPv6() {
        let result = parseAddress("[::1]:5432")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.bindAddress, "[::1]")
        XCTAssertEqual(result?.port, 5432)
    }

    func testParseAddressNoColon() {
        let result = parseAddress("invalid")
        XCTAssertNil(result)
    }

    func testParseAddressEmptyPort() {
        let result = parseAddress("127.0.0.1:")
        XCTAssertNil(result)
    }

    func testParseAddressInvalidPort() {
        let result = parseAddress("127.0.0.1:abc")
        XCTAssertNil(result)
    }

    func testParseAddressPortOutOfRange() {
        let result = parseAddress("127.0.0.1:99999")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.port, 99999)
    }

    func testDedupSamePortDifferentProtocol() {
        let tcp = PortInfo(port: 3000, pid: 100, processName: "node", protocolType: "TCP")
        let udp = PortInfo(port: 3000, pid: 100, processName: "node", protocolType: "UDP")
        XCTAssertNotEqual(tcp, udp)
    }

    private func parseAddress(_ address: String) -> (bindAddress: String, port: Int)? {
        guard let lastColon = address.lastIndex(of: ":") else { return nil }
        let portStr = String(address[address.index(after: lastColon)...])
        guard let port = Int(portStr) else { return nil }
        let bindAddress = String(address[..<lastColon])
        return (bindAddress.isEmpty ? "*" : bindAddress, port)
    }
}
