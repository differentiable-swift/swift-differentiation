#if canImport(_Differentiation)

import _Differentiation

/// For min(): "Returns: The lesser of `x` and `y`. If `x` is equal to `y`, returns `x`."
/// https://github.com/apple/swift/blob/main/stdlib/public/core/Algorithm.swift#L18
@inlinable
@derivative(of: min(_:_:))
public func _vjpMin<T: Comparable & Differentiable>(
    _ lhs: T,
    _ rhs: T
) -> (value: T, pullback: (T.TangentVector) -> (T.TangentVector, T.TangentVector)) {
    func pullback(_ tangentVector: T.TangentVector) -> (T.TangentVector, T.TangentVector) {
        guard lhs <= rhs else {
            return (.zero, tangentVector)
        }
        return (tangentVector, .zero)
    }
    return (value: min(lhs, rhs), pullback: pullback)
}

/// For max(): "Returns: The greater of `x` and `y`. If `x` is equal to `y`, returns `y`."
/// https://github.com/apple/swift/blob/main/stdlib/public/core/Algorithm.swift#L52
@inlinable
@derivative(of: max(_:_:))
public func _vjpMax<T: Comparable & Differentiable>(
    _ lhs: T,
    _ rhs: T
) -> (value: T, pullback: (T.TangentVector) -> (T.TangentVector, T.TangentVector)) {
    func pullback(_ tangentVector: T.TangentVector) -> (T.TangentVector, T.TangentVector) {
        guard lhs < rhs else {
            return (tangentVector, .zero)
        }
        return (.zero, tangentVector)
    }
    return (value: max(lhs, rhs), pullback: pullback)
}

/// To differentiate ``abs``
@inlinable
@derivative(of: abs(_:))
public func _vjpAbs<T: Comparable & SignedNumeric & Differentiable>(_ value: T)
    -> (value: T, pullback: (T.TangentVector) -> T.TangentVector)
{
    func pullback(_ tangentVector: T.TangentVector) -> T.TangentVector {
        guard value < 0 else {
            return tangentVector
        }
        return .zero - tangentVector
    }
    return (value: abs(value), pullback: pullback)
}

#endif
