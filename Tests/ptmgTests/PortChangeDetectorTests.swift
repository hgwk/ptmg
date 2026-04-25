import XCTest
@testable import ptmg

final class PortChangeDetectorTests: XCTestCase {
    func testNoChanges() {
        let detector = PortChangeDetector()
        let ports = [port(3000, 100, "node")]
        let changes = detector.detectChanges(current: ports)
        XCTAssertTrue(changes.isEmpty)
    }

    func testAddedPort() {
        let detector = PortChangeDetector()
        _ = detector.detectChanges(current: [port(3000, 100, "node")])
        let changes = detector.detectChanges(current: [port(3000, 100, "node"), port(3001, 101, "python")])
        let added = changes.filter { $0.changeType == .added }
        XCTAssertEqual(added.count, 1)
        XCTAssertEqual(added.first?.port, 3001)
    }

    func testRemovedPort() {
        let detector = PortChangeDetector()
        _ = detector.detectChanges(current: [port(3000, 100, "node"), port(3001, 101, "python")])
        let changes = detector.detectChanges(current: [port(3000, 100, "node")])
        let removed = changes.filter { $0.changeType == .removed }
        XCTAssertEqual(removed.count, 1)
        XCTAssertEqual(removed.first?.port, 3001)
    }

    func testChangedProcessNameNotDetected() {
        let detector = PortChangeDetector()
        _ = detector.detectChanges(current: [port(3000, 100, "node")])
        let changes = detector.detectChanges(current: [port(3000, 100, "python")])
        XCTAssertTrue(changes.isEmpty)
    }

    func testPIDReuseSamePortNotDetected() {
        let detector = PortChangeDetector()
        _ = detector.detectChanges(current: [port(3000, 100, "node")])
        let changes = detector.detectChanges(current: [port(3000, 101, "python")])
        XCTAssertTrue(changes.isEmpty)
    }

    private func port(_ port: Int, _ pid: Int, _ name: String) -> PortInfo {
        PortInfo(port: port, pid: pid, processName: name)
    }
}
