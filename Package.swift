// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DevTools",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(name: "bootstrap", targets: ["bootstrap"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/leaf-kit.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/kylef/PathKit.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "bootstrap",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "LeafKit", package: "leaf-kit"),
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
                "PathKit"
            ],
            resources: [.copy("templates")]
        )
    ]
)
