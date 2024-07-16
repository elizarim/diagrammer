// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "higapp",
    targets: [
        .target(name: "CirclePacking"),
        .testTarget(name: "CirclePackingTests", dependencies: ["CirclePacking"]),
        .executableTarget(name: "App", dependencies: ["CirclePacking"]),
    ]
)
