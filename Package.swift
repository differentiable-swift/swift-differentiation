// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-differentiation",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "Differentiation",
            targets: ["Differentiation"]
        ),
    ],
    targets: [
        .target(
            name: "Differentiation",
            plugins: [
                "CodeGeneratorPlugin",
            ]
        ),
        .executableTarget(name: "CodeGeneratorExecutable"),
        .plugin(
            name: "CodeGeneratorPlugin",
            capability: .buildTool,
            dependencies: ["CodeGeneratorExecutable"]
        ),
        .testTarget(
            name: "DifferentiationTests",
            dependencies: ["Differentiation"]
        ),
    ]
)
