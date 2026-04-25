import Foundation

enum CLIError: Error {
    case invalidPort
    case processNotFound
    case missingArgument(String)
}

struct CLI {
    static func run(arguments: [String]) {
        do {
            try execute(arguments: arguments)
        } catch CLIError.invalidPort {
            fputs("Error: Invalid port number\n", stderr)
            exit(1)
        } catch CLIError.processNotFound {
            fputs("Error: No process found on that port\n", stderr)
            exit(1)
        } catch CLIError.missingArgument(let flag) {
            fputs("Error: Missing argument for \(flag)\n", stderr)
            exit(1)
        } catch {
            fputs("Error: \(error)\n", stderr)
            exit(1)
        }
    }

    private static func execute(arguments: [String]) throws {
        let args = arguments.dropFirst()
        guard let flag = args.first else {
            printUsage()
            return
        }

        switch flag {
        case "--list", "-l":
            try listPorts()
        case "--watch", "-w":
            guard args.count >= 2 else { throw CLIError.missingArgument(flag) }
            guard let port = Int(args[args.index(args.startIndex, offsetBy: 1)]) else { throw CLIError.invalidPort }
            try watchPort(port)
        case "--kill", "-k":
            guard args.count >= 2 else { throw CLIError.missingArgument(flag) }
            guard let port = Int(args[1]) else { throw CLIError.invalidPort }
            try killPort(port)
        case "--help", "-h":
            printUsage()
        default:
            print("Unknown option: \(flag)")
            printUsage()
        }
    }

    private static func listPorts() throws {
        let ports = PortScanner.scanListeningPorts()
        if ports.isEmpty {
            print("No listening ports found.")
            return
        }

        let maxProcessLen = max(ports.map { $0.processName.count }.max() ?? 10, 7)
        let header = pad("PORT", 6) + pad("PID", 6) + pad("PROCESS", maxProcessLen) + pad("PROTO", 8) + "ADDRESS"
        print(header)
        print(String(repeating: "-", count: header.utf8.count))

        for port in ports {
            let proto = port.protocolType ?? "?"
            let addr = port.bindAddress ?? "*"
            let row = pad(String(port.port), 6) + pad(String(port.pid), 6) + pad(port.processName, maxProcessLen) + pad(proto, 8) + addr
            print(row)
        }
    }

    private static func pad(_ string: String, _ length: Int) -> String {
        let padded = string.padding(toLength: length, withPad: " ", startingAt: 0)
        return padded
    }

    private static let watchPollInterval: TimeInterval = 2.0

    private static func watchPort(_ targetPort: Int) throws {
        print("Watching port \(targetPort)... (Ctrl+C to stop)")

        var previousInfo: PortInfo? = nil

        while true {
            let ports = PortScanner.scanListeningPorts()
            let currentInfo = ports.first { $0.port == targetPort }

            if currentInfo?.pid != previousInfo?.pid ||
               currentInfo?.processName != previousInfo?.processName {

                if let info = currentInfo {
                    print("\(timestamp()) UP   : \(info.processName) (PID:\(info.pid)) on \(info.protocolType ?? "TCP")")
                } else if previousInfo != nil {
                    print("\(timestamp()) DOWN : Port \(targetPort) closed")
                }

                previousInfo = currentInfo
            }

            Thread.sleep(forTimeInterval: watchPollInterval)
        }
    }

    private static func killPort(_ targetPort: Int) throws {
        let ports = PortScanner.scanListeningPorts()
        guard let port = ports.first(where: { $0.port == targetPort }) else {
            throw CLIError.processNotFound
        }

        print("Killing \(port.processName) (PID:\(port.pid)) on port \(targetPort)...")
        let (success, error) = ProcessKiller.killProcessWithResult(pid: port.pid)

        if success {
            print("Killed.")
        } else {
            fputs("Failed: \(error?.localizedDescription ?? "Unknown error")\n", stderr)
            exit(1)
        }
    }

    private static func printUsage() {
        print("Usage: pm <command>")
        print("")
        print("Commands:")
        print("  -l, --list          List all listening ports")
        print("  -w, --watch <port>  Watch a specific port for changes")
        print("  -k, --kill <port>   Kill process on a specific port")
        print("  -h, --help          Show this help")
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    private static func timestamp() -> String {
        return timestampFormatter.string(from: Date())
    }
}
