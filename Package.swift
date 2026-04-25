// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PortManager",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "PortManager", targets: ["PortManager"]),
        .executable(name: "pm", targets: ["PortManager"])
    ],
    targets: [
        .executableTarget(
            name: "PortManager",
            path: "PortManager"
        ),
        .testTarget(
            name: "PortManagerTests",
            dependencies: ["PortManager"],
            path: "Tests/PortManagerTests"
        )
    ]
)
