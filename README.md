# swift-differentiation

This repository is a collection of useful extensions to Swift Differentiation, the experimental Swift language feature.
The contents of this repository extend the current implementation of Differentiable Swift to give the user access to more differentiable methods than currently provided in the Swift standard library. It also contains some workarounds for some methods that currently are not differentiable due to missing support in the language itself.
Some of these extensions we would like to eventually upstream into the Swift standard library and for these methods this package serves as a place to incubate and battle test these methods. 
Other extensions are meant to be phased out as the language feature itself fills the gap that these methods currently bridge (for example `Array.update(at:with:)`).

The ultimate goal of this repository is for the library portion to no longer exist since all implementations are either upstreamed to [Swift](https://github.com/swiftlang/swift) or the provided workarounds are no longer needed since there's more direct language support making them obsolete. 
We would like this repository to become a collection of Examples and documentation on the language feature however. So that people can more easily get started using Differentiable Swift! 

## Overview
Currently this package provides the following functionality:
- Differentiable support for the `Dictionary` type.
- Extensions to the `Array` type to be able to make writes to a given index differentiable (`update(at:with:)`) since using the subscript setter is currently not supported due to missing coroutine support.
- `Collection` conformances for the `Array.DifferentiableView` type to make it easier to work with directly.
- Some missing derivatives of standard library Swift functions like, `min(_:_:)`, `max(_:_:)`, `abs(_:)`, `atan2(_:_:)`, `Sequence.min()` and `Sequence.max()`
- Provides a `differentiableMap(_:)` function for the Optional type. 

## Differentiable Swift
The goal of the Differentiable Swift language feature is to provide first-class, language-integrated support for differentiable programming, making Swift the first general-purpose, statically typed programming language to have automatic differentiation built in. Originally developed as part of the [Swift for TensorFlow](https://github.com/tensorflow/swift) project, teams at [PassiveLogic](https://passivelogic.com) and elsewhere are currently working on it. Differentiable Swift is purely a language feature and isn't tied to any specific machine learning framework or platform.

## Getting Started
Differentiable Swift is present as an experimental language feature in Swift toolchains. Due to the incompleteness of its implementation, for best results we recommend using the newest release Swift toolchain from [swift.org](https://www.swift.org/download/). Or if you want to be on the bleeding edge to download one of the newest nightly toolchains. These tend to be more unstable however in terms of crashing. 

In order to enable Differentiable Swift no special compiler flags are needed, but you do need to place the following:
```swift
import _Differentiation
```
in any file where differentiation will be used. The compiler will warn you about this if you do forget to add the above and try to use any differentiable Swift capabilities.

When using this package and it's methods you only need to add the following:
```swift 
import Differentiation
```
Since the package also exports the `_Differentiation` module. 
Make sure to add the package to you dependencies however:
```swift
dependencies: [
  .package(url: "https://github.com/differentiable-swift/swift-differentiation", from: "0.0.1")
]
```
And then adding the product to any target that needs access to the library:
```swift
.product(name: "Differentiation", package: "swift-differentiation"),
```

## Contributing
If you're missing functionality or something is broken please file an issue! If you find something Differentiable Swift related that's not working but isn't directly related to this library please report it in an issue in our [swift-differentiation-testing](https://github.com/differentiable-swift/swift-differentiation-testing) repo. Here we try to provide an easy way for people to report and track incorrect behaviour of the Differentiable Swift language feature. If you have code that reproduces your issue please add it to the issue so that we can more easily debug or help with the problem you're running into. 

### Code Formatting
This package makes use of [SwiftFormat](https://github.com/nicklockwood/SwiftFormat?tab=readme-ov-file#command-line-tool), which you can install
from [homebrew](https://brew.sh/). 

To apply formatting rules to all files, which you should do before submitting a PR, run from the root of the repository:

```sh
swiftformat .
```
Formatting is validated with the `--strict` flag on every PR

## Differentiable Swift resources
If you want to learn more about differentiable Swift, there are a variety of resources out there. The API has changed over time,
so some older documentation may provide great background on the feature but not fully reflect code as it is written today.

- [Differentiable programming for gradient-based machine learning](https://forums.swift.org/t/differentiable-programming-for-gradient-based-machine-learning/42147)
- The Intro to Differentiable Swift series:
  - [Part 0: Why Automatic Differentiation is Awesome](https://medium.com/passivelogic/intro-to-differentiable-swift-part-0-why-automatic-differentiation-is-awesome-a522128ca9e3)
  - [Part 1: Gradient Descent](https://medium.com/passivelogic/intro-to-differentiable-swift-part-1-gradient-descent-181a06aaa596)
  - [Part 2: Differentiable Swift](https://medium.com/passivelogic/intro-to-differentiable-swift-part-2-differentiable-swift-25a99b97087f)
  - [Part 3: Differentiable API Introduction](https://medium.com/passivelogic/intro-to-differentiable-swift-part-3-differentiable-api-introduction-2d8d747e0ac8)
  - [Part 4: Differentiable Swift API Details](https://medium.com/passivelogic/intro-to-differentiable-swift-part-4-differentiable-swift-api-details-b6368c2dae5)
- [Differentiable Programming Manifesto](https://github.com/apple/swift/blob/main/docs/DifferentiableProgramming.md) (note: slightly out of date)
- The Swift for TensorFlow project explored the use of differentiable Swift paired with machine learning frameworks:
  - [Overview of Swift for TensorFlow](https://www.tensorflow.org/swift/guide/overview)
  - [Main Swift for TensorFlow GitHub repository](https://github.com/tensorflow/swift)
  - [Swift for TensorFlow machine learning APIs](https://github.com/tensorflow/swift-apis)
  - [Machine learning models and libraries](https://github.com/tensorflow/swift-models)
 

## License
This library is released under the Apache 2.0 license. See [LICENSE](https://github.com/differentiable-swift/swift-differentiation/blob/main/LICENSE) for details.
