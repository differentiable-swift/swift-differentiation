// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [.macOS("26.0")],
    dependencies: [
        .package(path: ".."),
        .package(url: "https://github.com/apple/swift-collections-benchmark", from: "0.0.4"),
        .package(url: "https://github.com/ordo-one/benchmark", from: "1.36.2"),
    ],
    targets: [
        .executableTarget(
            name: "Benchmarks",
            dependencies: [
                .product(name: "Differentiation", package: "swift-differentiation"),
                .product(name: "CollectionsBenchmark", package: "swift-collections-benchmark"),
            ]
        ),
        .executableTarget(
            name: "DifferentiationBenchmarks",
            dependencies: [
                .product(name: "Differentiation", package: "swift-differentiation"),
                .product(name: "Benchmark", package: "benchmark"),
            ],
            path: "Benchmarks/DifferentiationBenchmarks",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "benchmark"),
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
