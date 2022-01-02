// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MetalViewUI",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "MetalViewUI",
            targets: ["MetalViewUI"]
        ),
    ],
    targets: [
        .target(
            name: "MetalViewUI",
            dependencies: []
        ),
    ],
    swiftLanguageVersions: [.v5]
)
