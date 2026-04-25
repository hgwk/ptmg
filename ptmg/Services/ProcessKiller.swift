import Foundation

enum Signal: String {
    case term = "-TERM"
    case kill = "-9"

    var displayName: String {
        switch self {
        case .term: return "SIGTERM"
        case .kill: return "SIGKILL"
        }
    }
}

enum KillError: Error, LocalizedError {
    case permissionDenied
    case processNotFound
    case invalidPid
    case notRunning
    case commandFailed(String)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Permission denied. Try running with elevated privileges."
        case .processNotFound:
            return "Process not found. It may have already terminated."
        case .invalidPid:
            return "Invalid process ID."
        case .notRunning:
            return "Process is not running."
        case .commandFailed(let reason):
            return "Command failed: \(reason)"
        }
    }
}

typealias KillResult = Result<Void, KillError>

final class ProcessKiller {
    static func isProcessRunning(pid: Int) -> Bool {
        guard pid > 0 else { return false }
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/kill")
        task.arguments = ["-0", "\(pid)"]
        task.standardOutput = Pipe()
        task.standardError = Pipe()
        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }

    static func processName(pid: Int) -> String? {
        guard pid > 0 else { return nil }
        switch ProcessExecutor.execute(executablePath: "/bin/ps", arguments: ["-p", "\(pid)", "-o", "comm="]) {
        case .success(let output):
            let name = output.trimmingCharacters(in: .whitespacesAndNewlines)
            return name.isEmpty ? nil : name
        case .failure:
            return nil
        }
    }

    static func killProcess(pid: Int, signal: Signal = .kill) -> KillResult {
        guard pid > 0, pid <= 999999 else {
            return .failure(.invalidPid)
        }

        if !isProcessRunning(pid: pid) {
            return .failure(.notRunning)
        }

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/kill")
        task.arguments = [signal.rawValue, "\(pid)"]

        let errorPipe = Pipe()
        task.standardError = errorPipe

        do {
            try task.run()
            task.waitUntilExit()

            if task.terminationStatus == 0 {
                return .success(())
            }

            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            errorPipe.fileHandleForReading.closeFile()
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"

            if errorMessage.contains("No such process") {
                return .failure(.processNotFound)
            } else if errorMessage.contains("Operation not permitted") {
                return .failure(.permissionDenied)
            } else {
                return .failure(.commandFailed(errorMessage))
            }
        } catch {
            return .failure(.commandFailed(error.localizedDescription))
        }
    }

    static func killProcessWithResult(pid: Int, signal: Signal = .kill) -> (success: Bool, error: KillError?) {
        switch killProcess(pid: pid, signal: signal) {
        case .success:
            return (true, nil)
        case .failure(let error):
            return (false, error)
        }
    }
}
