import Foundation

/// Controls SketchyBar visibility by shelling out to the `sketchybar` CLI.
public final class SketchyBarController: BarController {
    private let sketchybarPath: String
    private let yOffset: CGFloat?

    public init(yOffset: CGFloat? = nil) {
        self.yOffset = yOffset
        if FileManager.default.fileExists(atPath: "/opt/homebrew/bin/sketchybar") {
            sketchybarPath = "/opt/homebrew/bin/sketchybar"
        } else if FileManager.default.fileExists(atPath: "/usr/local/bin/sketchybar") {
            sketchybarPath = "/usr/local/bin/sketchybar"
        } else {
            sketchybarPath = "sketchybar"
        }
    }

    public func hide() {
        // Instant hide — macOS menu bar is already sliding in
        let offset = Int(yOffset ?? 0)
        run(arguments: ["--bar", "hidden=on", "y_offset=\(offset)"])
    }

    public func show() {
        let target = Int(yOffset ?? 0)
        // Unhide off-screen, then animate sliding down
        let offScreen = target - 50
        run(arguments: ["--bar", "hidden=off", "y_offset=\(offScreen)"])
        runAsync(arguments: ["--animate", "sin", "12", "--bar", "y_offset=\(target)"])
    }

    private func run(arguments: [String]) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: sketchybarPath)
        process.arguments = arguments
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
        process.executableURL = URL(fileURLWithPath: sketchybarPath)
        process.arguments = arguments
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
