import XCTest
@testable import ptmg

final class PortInfoTests: XCTestCase {
    func testDevelopmentCategory() {
        let port = PortInfo(port: 3000, pid: 100, processName: "node")
        XCTAssertEqual(port.category, .development)
    }

    func testDatabaseCategory() {
        let postgres = PortInfo(port: 5432, pid: 100, processName: "postgres")
        let mongo = PortInfo(port: 27017, pid: 100, processName: "mongod")
        let redis = PortInfo(port: 6379, pid: 100, processName: "redis-server")
        let mysql = PortInfo(port: 3306, pid: 100, processName: "mysqld")

        XCTAssertEqual(postgres.category, .database)
        XCTAssertEqual(mongo.category, .database)
        XCTAssertEqual(redis.category, .database)
        XCTAssertEqual(mysql.category, .database)
    }

    func testProductionCategory() {
        let http = PortInfo(port: 80, pid: 100, processName: "nginx")
        let https = PortInfo(port: 443, pid: 100, processName: "nginx")
        let alt = PortInfo(port: 8080, pid: 100, processName: "tomcat")

        XCTAssertEqual(http.category, .production)
        XCTAssertEqual(https.category, .production)
        XCTAssertEqual(alt.category, .production)
    }

    func testSystemCategory() {
        let ssh = PortInfo(port: 22, pid: 100, processName: "sshd")
        let dns = PortInfo(port: 53, pid: 100, processName: "named")

        XCTAssertEqual(ssh.category, .system)
        XCTAssertEqual(dns.category, .system)
    }

    func testOtherCategory() {
        let custom = PortInfo(port: 12345, pid: 100, processName: "custom")
        XCTAssertEqual(custom.category, .other)
    }

    func testEqualitySamePorts() {
        let a = PortInfo(port: 3000, pid: 100, processName: "node", protocolType: "TCP", bindAddress: "127.0.0.1")
        let b = PortInfo(port: 3000, pid: 100, processName: "node", protocolType: "TCP", bindAddress: "127.0.0.1")
        XCTAssertEqual(a, b)
    }

    func testInequalityDifferentPort() {
        let a = PortInfo(port: 3000, pid: 100, processName: "node")
        let b = PortInfo(port: 3001, pid: 100, processName: "node")
        XCTAssertNotEqual(a, b)
    }

    func testInequalityDifferentPID() {
        let a = PortInfo(port: 3000, pid: 100, processName: "node")
        let b = PortInfo(port: 3000, pid: 101, processName: "node")
        XCTAssertNotEqual(a, b)
    }

    func testInequalityDifferentProtocol() {
        let a = PortInfo(port: 3000, pid: 100, processName: "node", protocolType: "TCP")
        let b = PortInfo(port: 3000, pid: 100, processName: "node", protocolType: "UDP")
        XCTAssertNotEqual(a, b)
    }

    func testHashConsistency() {
        let a = PortInfo(port: 3000, pid: 100, processName: "node")
        let b = PortInfo(port: 3000, pid: 100, processName: "node")
        XCTAssertEqual(a.hashValue, b.hashValue)
    }

    func testDisplayText() {
        let port = PortInfo(port: 3000, pid: 100, processName: "node", protocolType: "TCP")
        XCTAssertTrue(port.displayText.contains(":3000"))
        XCTAssertTrue(port.displayText.contains("node"))
        XCTAssertTrue(port.displayText.contains("100"))
        XCTAssertTrue(port.displayText.contains("TCP"))
    }

    func testDebugDescription() {
        let port = PortInfo(port: 3000, pid: 100, processName: "node", protocolType: "TCP", bindAddress: "127.0.0.1")
        let desc = port.debugDescription
        XCTAssertTrue(desc.contains("3000"))
        XCTAssertTrue(desc.contains("100"))
        XCTAssertTrue(desc.contains("node"))
        XCTAssertTrue(desc.contains("TCP"))
        XCTAssertTrue(desc.contains("127.0.0.1"))
    }
}
