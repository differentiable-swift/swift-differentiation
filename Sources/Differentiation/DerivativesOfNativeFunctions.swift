#if canImport(_Differentiation)

import _Differentiation

/// For min(): "Returns: The lesser of `x` and `y`. If `x` is equal to `y`, returns `x`."
/// https://github.com/apple/swift/blob/main/stdlib/public/core/Algorithm.swift#L18
@inlinable
@derivative(of: min(_:_:))
public func _vjpMin<T: Comparable & Differentiable>(_ x: T, _ y: T)
    -> (value: T, pullback: (T.TangentVector) -> (T.TangentVector, T.TangentVector))
{
    y < x ? (value: y, pullback: { v in (.zero, v) }) : (value: x, pullback: { v in (v, .zero) })
}

/// For max(): "Returns: The greater of `x` and `y`. If `x` is equal to `y`, returns `y`."
/// https://github.com/apple/swift/blob/main/stdlib/public/core/Algorithm.swift#L52
@inlinable
@derivative(of: max(_:_:))
public func _vjpMax<T: Comparable & Differentiable>(_ x: T, _ y: T)
    -> (value: T, pullback: (T.TangentVector) -> (T.TangentVector, T.TangentVector))
{
    y >= x ? (value: y, pullback: { v in (.zero, v) }) : (value: x, pullback: { v in (v, .zero) })
}

/// To differentiate ``abs``
/// https://github.com/swiftlang/swift/blob/main/stdlib/public/core/Integers.swift#L346
@inlinable
@derivative(of: abs(_:))
public func _vjpAbs<T: SignedNumeric & Comparable & Differentiable>(_ x: T)
    -> (value: T, pullback: (T.TangentVector) -> T.TangentVector)
{
    x < 0 ? (value: -x, pullback: { v in .zero - v }) : (value: x, pullback: { v in v })
}

#endif
