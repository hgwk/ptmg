import XCTest
@testable import ptmg

final class ProcessExecutorTests: XCTestCase {
    func testCommandNotFound() {
        let result = ProcessExecutor.execute(executablePath: "/nonexistent/binary", arguments: [])
        XCTAssertEqual(result, .failure(.commandNotFound))
    }

    func testEchoSuccess() {
        let result = ProcessExecutor.execute(executablePath: "/bin/echo", arguments: ["hello"])
        switch result {
        case .success(let output):
            XCTAssertTrue(output.contains("hello"))
        case .failure:
            XCTFail("Expected success")
        }
    }

    func testExecuteLines() {
        let result = ProcessExecutor.executeLines(executablePath: "/bin/echo", arguments: ["line1\nline2"])
        switch result {
        case .success(let lines):
            XCTAssertGreaterThanOrEqual(lines.count, 1)
        case .failure:
            XCTFail("Expected success")
        }
    }

    func testInvalidOutputEncoding() {
        let result = ProcessExecutor.execute(executablePath: "/usr/bin/printf", arguments: ["\\x80"])
        switch result {
        case .success:
            break
        case .failure(let error):
            XCTAssertTrue(error == .invalidOutput || error == .executionFailed(""))
        }
    }
}
