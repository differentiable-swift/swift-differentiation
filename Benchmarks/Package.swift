// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(path: ".."),
        .package(url: "https://github.com/apple/swift-collections-benchmark", from: "0.0.4"),
    ],
    targets: [
        .executableTarget(
            name: "Benchmarks",
            dependencies: [
                .product(name: "Differentiation", package: "swift-differentiation"),
                .product(name: "CollectionsBenchmark", package: "swift-collections-benchmark"),
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
