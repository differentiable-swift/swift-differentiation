// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [.macOS("26.0")],
    dependencies: [
        .package(path: ".."),
        .package(url: "https://github.com/apple/swift-collections-benchmark", from: "0.0.4"),
        .package(url: "https://github.com/ordo-one/package-benchmark", from: "1.4.0"),
    ],
    targets: [
        .executableTarget(
            name: "Benchmarks",
            dependencies: [
                .product(name: "Differentiation", package: "swift-differentiation"),
                .product(name: "CollectionsBenchmark", package: "swift-collections-benchmark"),
            ]
        ),
        .target(
            name: "DifferentiableOperators",
            dependencies: [
                .product(name: "Differentiation", package: "swift-differentiation"),
            ]
        ),
        .executableTarget(
            name: "FusedZipWithBenchmarks",
            dependencies: [
                .product(name: "Benchmark", package: "package-benchmark"),
                .product(name: "Differentiation", package: "swift-differentiation"),
                "DifferentiableOperators",
            ],
            path: "Benchmarks/FusedZipWithBenchmarks",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ]
        ),
        .testTarget(
            name: "BenchmarkTests",
            dependencies: [
                "Benchmarks",
                "DifferentiableOperators",
            ]
        ),
    ]
)
