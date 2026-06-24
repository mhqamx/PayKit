// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PayKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "PayKit",
            targets: ["PayKit"]
        )
    ],
    targets: [
        .target(
            name: "PayKit",
            path: "Sources/PayKit",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "PayKitTests",
            dependencies: ["PayKit"],
            path: "Tests/PayKitTests"
        )
    ]
)
