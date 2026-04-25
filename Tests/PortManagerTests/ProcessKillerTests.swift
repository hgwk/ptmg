import XCTest
@testable import PortManager

final class ProcessKillerTests: XCTestCase {
    func testInvalidPIDZero() {
        let result = ProcessKiller.killProcess(pid: 0)
        XCTAssertEqual(result, .failure(.invalidPid))
    }

    func testInvalidPIDNegative() {
        let result = ProcessKiller.killProcess(pid: -1)
        XCTAssertEqual(result, .failure(.invalidPid))
    }

    func testInvalidPIDTooLarge() {
        let result = ProcessKiller.killProcess(pid: 1_000_000)
        XCTAssertEqual(result, .failure(.invalidPid))
    }

    func testValidPIDRange() {
        let result = ProcessKiller.killProcess(pid: 1)
        XCTAssertNotEqual(result, .failure(.invalidPid))
    }

    func testKillResultTupleSuccess() {
        let (success, error) = ProcessKiller.killProcessWithResult(pid: 0)
        XCTAssertFalse(success)
        XCTAssertNotNil(error)
    }
}
