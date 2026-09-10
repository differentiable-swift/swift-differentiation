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
        .package(url: "https://github.com/differentiable-swift/swift-differentiation-stdlib.git", from: .tagBasedOnCompilerVersion),
    ],
    targets: [
        .target(
            name: "Differentiation",
            dependencies: [
                .product(name: "_Differentiation", package: "swift-differentiation-stdlib", condition: .when(platforms: [.macOS, .iOS])),
            ],
            swiftSettings: [
                // required for Swift 6.5 valueWithPullback overloads. Provides access to the `Builtin` module
                .enableExperimentalFeature("BuiltinModule"),
                // required for Swift 6.5 valueWithPullback overloads. Currently crashes in language mode .v6
                .swiftLanguageMode(.v5),
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
        "602.0.1"
        #elseif compiler(<6.3.1)
        "603.0.0"
        #elseif compiler(<6.4)
        "603.3.0"
        #elseif compiler(<6.5)
        "604.0.0-prerelease-3" // TODO: update to 604.0.0 once 6.4 is released
        #else
        "604.0.0-prerelease-3" // default to latest
        #endif
    }
}
