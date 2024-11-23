// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BTKit",
    defaultLocalization: "en",
    platforms: [.macOS(.v10_15), .iOS(.v14)],
    products: [
        .library(
            name: "BTKit",
            targets: ["BTKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "BTKit",
            dependencies: [],
            resources: [.process("Resources")]),
        .testTarget(
            name: "BTKitTests",
            dependencies: ["BTKit"])
    ]
)
