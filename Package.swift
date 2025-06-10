// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Puppy",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .visionOS(.v1),
    ],
    products: [
        .library(name: "Puppy", targets: ["Puppy"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", .upToNextMinor(from: "1.6.3")),
    ],
    targets: [
        .target(
            name: "CPuppy",
            path: "Sources/CPuppy",
            exclude: ["CMakeLists.txt"]
        ),
        .target(
            name: "Puppy",
            dependencies: [.product(name: "Logging", package: "swift-log")],
            path: "Sources/Puppy",
            exclude: ["CMakeLists.txt"]
        ),
        .testTarget(
            name: "PuppyTests",
            dependencies: ["Puppy"],
            path: "Tests/PuppyTests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)

if let puppy = package.targets.first(where: { $0.name == "Puppy" }) {
    puppy.dependencies.append(
        .target(name: "CPuppy", condition: .when(platforms: [.linux]))
    )
}
