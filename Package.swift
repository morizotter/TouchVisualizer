// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TouchVisualizer",
    platforms: [.iOS(.v9)],
    products: [
        .library(
            name: "TouchVisualizer",
            targets: ["TouchVisualizer"]),
    ],
    targets: [
        .target(
            name: "TouchVisualizer",
            path: "TouchVisualizer",
            exclude: ["Info.plist"]
        )
    ]
)
