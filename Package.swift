// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "barswitch",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .target(
            name: "BarSwitchCore",
            path: "Sources/BarSwitchCore"
        ),
        .executableTarget(
            name: "barswitch",
            dependencies: ["BarSwitchCore"],
            path: "Sources/BarSwitch"
        ),
        .testTarget(
            name: "BarSwitchTests",
            dependencies: ["BarSwitchCore"],
            path: "Tests/BarSwitchTests"
        )
    ]
)
