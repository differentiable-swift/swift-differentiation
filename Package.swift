// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-differentiation",
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
