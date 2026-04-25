import Foundation

enum ProcessExecutionError: Error, LocalizedError {
    case executionFailed(String)
    case invalidOutput
    case commandNotFound
    case timeout

    var errorDescription: String? {
        switch self {
        case .executionFailed(let reason):
            return "Command execution failed: \(reason)"
        case .invalidOutput:
            return "Failed to parse command output"
        case .commandNotFound:
            return "Command not found"
        case .timeout:
            return "Command timed out"
        }
    }
}

struct ProcessExecutor {
    private static let defaultTimeout: TimeInterval = 10.0

    nonisolated static func execute(
        executablePath: String,
        arguments: [String],
        timeout: TimeInterval = defaultTimeout
    ) -> Result<String, ProcessExecutionError> {
        let task = Process()

        guard FileManager.default.fileExists(atPath: executablePath) else {
            return .failure(.commandNotFound)
        }

        task.executableURL = URL(fileURLWithPath: executablePath)
        task.arguments = arguments

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe

        do {
            try task.run()

            let semaphore = DispatchSemaphore(value: 0)
            var didTimeout = false

            DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                if task.isRunning {
                    didTimeout = true
                    task.terminate()
                }
                semaphore.signal()
            }

            task.waitUntilExit()
            semaphore.signal()
            semaphore.wait()

            if didTimeout {
                return .failure(.timeout)
            }

            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            outputPipe.fileHandleForReading.closeFile()
            errorPipe.fileHandleForReading.closeFile()

            guard let output = String(data: outputData, encoding: .utf8) else {
                return .failure(.invalidOutput)
            }

            if task.terminationStatus == 0 {
                return .success(output)
            } else {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                return .failure(.executionFailed(errorMessage))
            }
        } catch {
            return .failure(.executionFailed(error.localizedDescription))
        }
    }

    nonisolated static func executeLines(
        executablePath: String,
        arguments: [String],
        timeout: TimeInterval = defaultTimeout
    ) -> Result<[String], ProcessExecutionError> {
        switch execute(executablePath: executablePath, arguments: arguments, timeout: timeout) {
        case .success(let output):
            let lines = output.components(separatedBy: .newlines)
            return .success(lines)
        case .failure(let error):
            return .failure(error)
        }
    }
}
