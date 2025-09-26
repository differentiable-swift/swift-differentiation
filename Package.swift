// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-differentiation",
    platforms: [
        // we only support the latest versions of OSes as `@available(...)` is not yet supported for differentiation.
        .macOS("26"),
        .iOS("26"),
    ],
    products: [
        .library(
            name: "Differentiation",
            targets: ["Differentiation"]
        ),
    ],
    targets: [
        .target(name: "Differentiation"),
        .testTarget(
            name: "DifferentiationTests",
            dependencies: ["Differentiation"]
        ),
    ]
)
