// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftGenPluginKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "SwiftGenPluginKit", targets: ["SwiftGenPluginKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.2")
    ],
    targets: [
        .target(
            name: "SwiftGenPluginKit",
            path: ".",
            sources: ["Sources/SwiftGenPluginKit"],
            swiftSettings: [
              .unsafeFlags(["-Xfrontend", "-strict-concurrency=minimal"])
            ],
            plugins: [
                .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")
            ]
        )
    ]
)
