import Foundation

/// Controls SketchyBar visibility by shelling out to the `sketchybar` CLI.
public final class SketchyBarController: BarController {
    public init() {}

    public func hide() {
        // Instant hide — macOS menu bar is already sliding in
        run(arguments: ["--bar", "hidden=on", "y_offset=0"])
    }

    public func show() {
        // Unhide off-screen, then animate sliding down
        run(arguments: ["--bar", "hidden=off", "y_offset=-50"])
        runAsync(arguments: ["--animate", "sin", "12", "--bar", "y_offset=0"])
    }

    private func run(arguments: [String]) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["sketchybar"] + arguments
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            // sketchybar may not be running — fail silently
        }
    }

    private func runAsync(arguments: [String]) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["sketchybar"] + arguments
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            // Don't wait — sketchybar handles animation asynchronously
        } catch {
            // sketchybar may not be running — fail silently
        }
    }
}
