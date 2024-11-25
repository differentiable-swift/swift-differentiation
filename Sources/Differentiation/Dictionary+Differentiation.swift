#if canImport(_Differentiation)

import _Differentiation

// copied and modified from
// https://github.com/borglab/SwiftFusion/blob/main/Sources/SwiftFusion/Core/Dictionary+Differentiable.swift
// and
// https://bugs.swift.org/browse/TF-1193

/// This file makes `Dictionary` differentiable.
///
/// Note: This will eventually be moved into the Swift standard library. Once it is in the
/// standard library, we can delete it from this repository.
/// Implements the `Differentiable` requirements.
extension Dictionary: Differentiable where Value: Differentiable {
    public typealias TangentVector = [Key: Value.TangentVector]
    public mutating func move(by direction: TangentVector) {
        for (componentKey, componentDirection) in direction {
            func fatalMissingComponent() -> Value {
                preconditionFailure("missing component \(componentKey) in moved Dictionary")
            }
            self[componentKey, default: fatalMissingComponent()].move(by: componentDirection)
        }
    }

    public var zeroTangentVectorInitializer: () -> TangentVector {
        let listOfKeys = keys // capturing only what's needed, not the entire self, in order to not waste memory
        func initializer() -> Self.TangentVector {
            return listOfKeys.reduce(into: [Key: Value.TangentVector]()) { $0[$1] = Value.TangentVector.zero }
        }
        return initializer
    }
}

/// Implements the `AdditiveArithmetic` requirements.
extension Dictionary: AdditiveArithmetic where Value: AdditiveArithmetic {
    public static func + (_ lhs: Self, _ rhs: Self) -> Self {
        lhs.merging(rhs, uniquingKeysWith: +)
    }

    public static func - (_ lhs: Self, _ rhs: Self) -> Self {
        lhs.merging(rhs.mapValues { .zero - $0 }, uniquingKeysWith: +)
    }

    public static var zero: Self { [:] }
}

// attempt to make builtin subscript differentiable:
// https://bugs.swift.org/browse/TF-1193
// https://github.com/apple/swift/pull/32614/
// https://github.com/borglab/SwiftFusion/blob/main/Sources/SwiftFusion/Core/Dictionary+Differentiable.swift

extension Dictionary where Value: Differentiable {
    // get
    // swiftformat:disable:next typeSugar
    // periphery:ignore
    @usableFromInline
    @derivative(of: subscript(_:))
    func vjpSubscriptGet(key: Key)
        -> (value: Value?, pullback: (Optional<Value>.TangentVector) -> Dictionary<Key, Value>.TangentVector)
    {
        // When adding two dictionaries, nil values are equivalent to zeroes, so there is no need to manually zero-out
        // every key's value. Instead, it is faster to create a dictionary with the single non-zero entry.
        return (self[key], { tangentVector in
            if let value = tangentVector.value {
                return [key: value]
            }
            else {
                return .zero
            }
        })
    }
}
#endif
