import Foundation

final class KeepAwakeController {
    private let executableURL: URL
    private let arguments: [String]
    private var process: Process?
    private(set) var errorMessage: String?
    var isActive: Bool { process?.isRunning == true }
    var processIdentifier: Int32? { process?.processIdentifier }

    init(executableURL: URL = URL(fileURLWithPath: "/usr/bin/caffeinate"),
         arguments: [String]? = nil) {
        self.executableURL = executableURL
        self.arguments = arguments ?? ["-di", "-w", String(ProcessInfo.processInfo.processIdentifier)]
    }

    func start() {
        guard !isActive else { return }
        errorMessage = nil
        let child = Process()
        child.executableURL = executableURL
        child.arguments = arguments
        child.standardOutput = FileHandle.nullDevice
        child.standardError = FileHandle.nullDevice
        do {
            try child.run()
            process = child
        } catch {
            process = nil
            errorMessage = "Could not start keep-awake: \(error.localizedDescription)"
        }
    }

    func stop() {
        if let child = process, child.isRunning {
            child.terminate()
            child.waitUntilExit()
        }
        process = nil
        errorMessage = nil
    }

    func refresh() {
        if let child = process, !child.isRunning {
            errorMessage = "Keep-awake ended unexpectedly (exit \(child.terminationStatus)). Try Start again."
            process = nil
        }
    }

    deinit { stop() }
}
