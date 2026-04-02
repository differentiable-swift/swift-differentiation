// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-differentiation",
    platforms: [
        .macOS("26.0"),
        .iOS("26.0"),
    ],
    products: [
        .library(
            name: "Differentiation",
            targets: ["Differentiation"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/differentiable-swift/swift-differentiation-stdlib.git", from: .tagBasedOnCompilerVersion
        ),
    ],
    targets: [
        .target(
            name: "Differentiation",
            dependencies: [
                .product(name: "_Differentiation", package: "swift-differentiation-stdlib", condition: .when(platforms: [.macOS, .iOS])),
            ]
        ),
        .testTarget(
            name: "DifferentiationTests",
            dependencies: ["Differentiation"]
        ),
    ]
)

extension Version {
    static var tagBasedOnCompilerVersion: Version {
        #if compiler(<6.3)
        "602.0.0"
        #elseif compiler(<6.4)
        "603.0.0"
        #endif
    }
}
