import Cocoa

private enum AlertButton {
    static let first = NSApplication.ModalResponse.alertFirstButtonReturn
}

final class AlertManager {
    static func confirmKillProcess(pid: Int, processName: String = "process") -> Bool {
        let alert = NSAlert()
        alert.messageText = "Kill Process?"
        alert.informativeText = "Are you sure you want to kill '\(processName)' (PID: \(pid))?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Kill")
        alert.addButton(withTitle: "Cancel")

        return alert.runModal() == AlertButton.first
    }

    static func showKillResult(success: Bool, pid: Int, signal: String, error: KillError? = nil) {
        let performer = NSHapticFeedbackManager.defaultPerformer
        let alert = NSAlert()
        if success {
            performer.perform(.generic, performanceTime: .default)
            alert.messageText = "Success"
            alert.informativeText = "\(signal) sent to process \(pid)"
            alert.alertStyle = .informational
        } else {
            performer.perform(.alignment, performanceTime: .default)
            alert.messageText = "Failed"
            let errorMessage = error?.localizedDescription ?? "Unknown error"
            alert.informativeText = "Failed to send \(signal) to process \(pid).\n\(errorMessage)"
            alert.alertStyle = .critical
        }
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
