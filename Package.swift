// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Puppy",
    platforms: [
        .macOS(.v10_12), .iOS(.v10), .tvOS(.v10), .watchOS(.v3),
    ],
    products: [
        .library(
            name: "Puppy",
            targets: ["Puppy"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
    ],
    targets: [
        .systemLibrary(name: "CPuppy"),
        .target(
            name: "Puppy",
            dependencies: [.target(name: "CPuppy"), .product(name: "Logging", package: "swift-log")]
        ),
        .testTarget(
            name: "PuppyTests",
            dependencies: ["Puppy"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
