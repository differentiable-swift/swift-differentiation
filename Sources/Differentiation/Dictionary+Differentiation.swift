#if canImport(_Differentiation)

import _Differentiation

// copied and modified from
// https://github.com/borglab/SwiftFusion/blob/main/Sources/SwiftFusion/Core/Dictionary+Differentiable.swift
// and
// https://bugs.swift.org/browse/TF-1193

extension Dictionary: @retroactive Differentiable where Value: Differentiable {
    public typealias TangentVector = [Key: Value.TangentVector]

    @inlinable
    public mutating func move(by direction: TangentVector) {
        for (componentKey, componentDirection) in direction {
            func fatalMissingComponent() -> Value {
                preconditionFailure("missing component \(componentKey) in moved Dictionary")
            }
            self[componentKey, default: fatalMissingComponent()].move(by: componentDirection)
        }
    }
}

/// Implements the `AdditiveArithmetic` requirements.
extension Dictionary: @retroactive AdditiveArithmetic where Value: AdditiveArithmetic {
    @inlinable
    public static func + (_ lhs: Self, _ rhs: Self) -> Self {
        lhs.merging(rhs, uniquingKeysWith: +)
    }

    @inlinable
    public static func - (_ lhs: Self, _ rhs: Self) -> Self {
        lhs.merging(rhs.mapValues { .zero - $0 }, uniquingKeysWith: +)
    }

    @inlinable
    public static var zero: Self { [:] }
}

extension Dictionary where Value: Differentiable {
    /// Defines a derivative for `Dictionary`s subscript getter enabling calls like `var value = dictionary[key]` to be differentiable
    @inlinable
    @derivative(of: subscript(_:))
    public func _vjpSubscript(key: Key)
        -> (value: Value?, pullback: (Optional<Value>.TangentVector) -> Dictionary<Key, Value>.TangentVector)
    {
        // When adding two dictionaries, nil values are equivalent to zeroes, so there is no need to manually zero-out
        // every key's value. Instead, it is faster to create a dictionary with the single non-zero entry.
        (self[key], { tangentVector in
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
