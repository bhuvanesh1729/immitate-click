import Foundation
import Darwin

struct Failure: Error, CustomStringConvertible { let description: String }
func expect(_ condition: @autoclosure () throws -> Bool, _ message: String) throws {
    if try !condition() { throw Failure(description: message) }
}
func waitUntil(_ condition: () -> Bool) -> Bool {
    let deadline = Date().addingTimeInterval(3)
    while Date() < deadline {
        if condition() { return true }
        Thread.sleep(forTimeInterval: 0.03)
    }
    return condition()
}
func assertions() throws -> String {
    let command = Process()
    command.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
    command.arguments = ["-g", "assertions"]
    let output = Pipe()
    command.standardOutput = output
    try command.run()
    let data = output.fileHandleForReading.readDataToEndOfFile()
    command.waitUntilExit()
    try expect(command.terminationStatus == 0, "pmset read failed")
    return String(decoding: data, as: UTF8.self)
}

if CommandLine.arguments.contains("--parent-exit-child") {
    let controller = KeepAwakeController()
    controller.start()
    guard let pid = controller.processIdentifier else { exit(2) }
    guard waitUntil({
        guard let output = try? assertions() else { return false }
        let owned = output.split(separator: "\n").filter { $0.contains("pid \(pid)") }
        return owned.contains { $0.contains("PreventUserIdleDisplaySleep") }
            && owned.contains { $0.contains("PreventUserIdleSystemSleep") }
    }) else {
        controller.stop()
        exit(3)
    }
    print(pid)
    fflush(stdout)
    // Simulate abrupt parent death: no Swift deinitializers or app quit callback.
    _exit(0)
}

var failures = 0
func test(_ name: String, _ body: () throws -> Void) {
    do { try body(); print("PASS: \(name)") }
    catch { failures += 1; print("FAIL: \(name): \(error)") }
}

test("Start creates one child; repeated Start preserves it; Stop twice releases it") {
    let controller = KeepAwakeController()
    defer { controller.stop() }
    controller.start()
    try expect(controller.isActive, "Start did not activate")
    let pid = controller.processIdentifier
    try expect(pid != nil, "Start did not create child")
    controller.start()
    try expect(controller.processIdentifier == pid, "Repeated Start created another child")
    var owned: [String] = []
    let observed = waitUntil {
        guard let actual = try? assertions() else { return false }
        owned = actual.split(separator: "\n").filter { $0.contains("pid \(pid!)") }.map(String.init)
        return owned.contains { $0.contains("PreventUserIdleDisplaySleep") }
            && owned.contains { $0.contains("PreventUserIdleSystemSleep") }
    }
    try expect(observed, "Timed out waiting for owned assertions: \(owned)")
    try expect(owned.contains { $0.contains("PreventUserIdleDisplaySleep") }, "Missing display idle assertion")
    try expect(owned.contains { $0.contains("PreventUserIdleSystemSleep") }, "Missing system idle assertion")
    print("EVIDENCE: " + owned.joined(separator: "\n"))
    controller.stop()
    controller.stop()
    try expect(!controller.isActive && controller.processIdentifier == nil, "Stop left active state")
    try expect(kill(pid!, 0) != 0 && errno == ESRCH, "Stop left child alive")
    try expect(!(try assertions()).contains("pid \(pid!)"), "Stop left owned assertions")
}

test("Missing executable reports error and remains inactive") {
    let controller = KeepAwakeController(executableURL: URL(fileURLWithPath: "/nonexistent/immitate-click-test"))
    controller.start()
    try expect(!controller.isActive, "Failed launch reports active")
    try expect(controller.errorMessage != nil, "Failed launch hides error")
    controller.stop()
    try expect(controller.errorMessage == nil, "Stop did not reset error")
}

test("Unexpected child exit becomes inactive with an error") {
    let controller = KeepAwakeController(executableURL: URL(fileURLWithPath: "/usr/bin/false"), arguments: [])
    controller.start()
    try expect(waitUntil { !controller.isActive }, "Child did not exit")
    controller.refresh()
    try expect(controller.errorMessage != nil, "Unexpected exit hides error")
    try expect(controller.processIdentifier == nil, "Exited child still owned")
}

test("Controller release cleans up an active child") {
    var controller: KeepAwakeController? = KeepAwakeController()
    controller!.start()
    guard let pid = controller!.processIdentifier else { throw Failure(description: "Missing child") }
    controller = nil
    try expect(kill(pid, 0) != 0 && errno == ESRCH, "Release left child alive")
}

test("Abrupt parent exit releases caffeinate child and assertions") {
    let command = Process()
    command.executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
    command.arguments = ["--parent-exit-child"]
    let pipe = Pipe()
    command.standardOutput = pipe
    try command.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    command.waitUntilExit()
    let text = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
    guard let pid = Int32(text) else { throw Failure(description: "Missing child PID: \(text)") }
    defer { if kill(pid, 0) == 0 { kill(pid, SIGTERM) } }
    try expect(command.terminationStatus == 0, "Parent test process failed")
    try expect(waitUntil { kill(pid, 0) != 0 && errno == ESRCH }, "Parent-exit left child alive")
    try expect(!(try assertions()).contains("pid \(pid)"), "Parent-exit left assertions")
}

print("\(5 - failures)/5 tests passed")
exit(failures == 0 ? 0 : 1)
