// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SessionPlus",
    platforms: [
        .macOS(.v12),
        .macCatalyst(.v15),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SessionPlus",
            targets: [
                "SessionPlus",
                "SessionPlusEmulation",
            ]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/richardpiazza/AsyncPlus.git", .upToNextMajor(from: "0.3.2")),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SessionPlus",
            dependencies: [
                .product(name: "AsyncPlus", package: "AsyncPlus"),
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .target(
            name: "SessionPlusEmulation",
            dependencies: [
                "SessionPlus",
            ]
        ),
        .testTarget(
            name: "SessionPlusTests",
            dependencies: [
                "SessionPlus",
                "SessionPlusEmulation",
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
