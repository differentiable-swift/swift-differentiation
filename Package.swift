// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-differentiation",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
    ],
    products: [
        .library(
            name: "Differentiation",
            targets: ["Differentiation"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections-benchmark", from: "0.0.4"),
    ],
    targets: [
        .target(name: "Differentiation"),
        .testTarget(
            name: "DifferentiationTests",
            dependencies: ["Differentiation"]
        ),
        .executableTarget(
            name: "Benchmarks",
            dependencies: [
                "Differentiation",
                .product(name: "CollectionsBenchmark", package: "swift-collections-benchmark"),
            ],
            swiftSettings: [
//                .unsafeFlags([
//                    "-Rpass-missed=specialize",
//                    "-O",
//                    "-g",
//                ])
            ]
        ),
        .testTarget(
            name: "BenchmarkTests",
            dependencies: [
                "Benchmarks",
            ]
        ),
    ]
)
