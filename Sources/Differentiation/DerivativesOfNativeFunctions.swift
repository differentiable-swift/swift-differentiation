#if canImport(_Differentiation)

import _Differentiation

/// For min(): "Returns: The lesser of `x` and `y`. If `x` is equal to `y`, returns `x`."
/// https://github.com/apple/swift/blob/main/stdlib/public/core/Algorithm.swift#L18
@inlinable
@derivative(of: min)
public func minVJP<T: Comparable & Differentiable>(
    _ lhs: T,
    _ rhs: T
) -> (value: T, pullback: (T.TangentVector) -> (T.TangentVector, T.TangentVector)) {
    func pullback(_ tangentVector: T.TangentVector) -> (T.TangentVector, T.TangentVector) {
        if lhs <= rhs {
            return (tangentVector, .zero)
        }
        else {
            return (.zero, tangentVector)
        }
    }
    return (value: min(lhs, rhs), pullback: pullback)
}

/// For max(): "Returns: The greater of `x` and `y`. If `x` is equal to `y`, returns `y`."
/// https://github.com/apple/swift/blob/main/stdlib/public/core/Algorithm.swift#L52
@inlinable
@derivative(of: max)
public func maxVJP<T: Comparable & Differentiable>(
    _ lhs: T,
    _ rhs: T
) -> (value: T, pullback: (T.TangentVector) -> (T.TangentVector, T.TangentVector)) {
    func pullback(_ tangentVector: T.TangentVector) -> (T.TangentVector, T.TangentVector) {
        if lhs < rhs {
            return (.zero, tangentVector)
        }
        else {
            return (tangentVector, .zero)
        }
    }
    return (value: max(lhs, rhs), pullback: pullback)
}

/// To differentiate ``abs``
@inlinable
@derivative(of: abs)
public func absVJP<T: Comparable & SignedNumeric & Differentiable>(_ value: T)
    -> (value: T, pullback: (T.TangentVector) -> T.TangentVector)
{
    func pullback(_ tangentVector: T.TangentVector) -> T.TangentVector {
        if value < 0 {
            return .zero - tangentVector
        }
        else {
            return tangentVector
        }
    }
    return (value: abs(value), pullback: pullback)
}

#endif
