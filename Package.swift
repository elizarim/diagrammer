// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hig",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "hig", targets: ["App"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "AppIO", dependencies: ["CirclePacking"]),
        .target(name: "CirclePacking"),
        .testTarget(name: "CirclePackingTests", dependencies: ["CirclePacking"]),
        .executableTarget(
            name: "App",
            dependencies: [
                "AppIO",
                "CirclePacking",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
    ]
)
