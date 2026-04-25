// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ptmg",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "ptmg", targets: ["ptmg"])
    ],
    targets: [
        .executableTarget(
            name: "ptmg",
            path: "ptmg"
        ),
        .testTarget(
            name: "ptmgTests",
            dependencies: ["ptmg"],
            path: "Tests/ptmgTests"
        )
    ]
)
