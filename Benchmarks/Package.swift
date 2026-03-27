// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "PackageBenchmarks", targets: ["PackageBenchmarks"])
    ],
    dependencies: [
        .package(path: ".."),
        .package(url: "https://github.com/apple/swift-collections-benchmark", from: "0.0.4"),
        .package(url: "https://github.com/ordo-one/package-benchmark", from: "1.31.0"),
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
            name: "PackageBenchmarks",
            dependencies: [
                .product(name: "Differentiation", package: "swift-differentiation"),
                .product(name: "Benchmark", package: "package-benchmark"),
            ],
            path: "Benchmarks/PackageBenchmarks",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark")
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
