// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SessionPlus",
    platforms: [
        .macOS(.v13),
        .macCatalyst(.v16),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1), // .v2 ~ iOS 18
    ],
    products: [
        .library(
            name: "SessionPlus",
            targets: [
                "SessionPlus",
                "SessionPlusEmulation",
            ],
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/richardpiazza/AsyncPlus.git", .upToNextMajor(from: "0.3.2")),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.2"),
    ],
    targets: [
        .target(
            name: "SessionPlus",
            dependencies: [
                .product(name: "AsyncPlus", package: "AsyncPlus"),
                .product(name: "Logging", package: "swift-log"),
            ],
        ),
        .target(
            name: "SessionPlusEmulation",
            dependencies: [
                "SessionPlus",
            ],
        ),
        .testTarget(
            name: "SessionPlusTests",
            dependencies: [
                "SessionPlus",
                "SessionPlusEmulation",
            ],
        ),
    ],
    swiftLanguageModes: [
        .v5,
    ],
)

for target in package.targets {
    var settings = target.swiftSettings ?? []
    settings.append(contentsOf: [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("StrictConcurrency=complete"),
    ])
    target.swiftSettings = settings
}
