import Differentiation

// The library's 4-ary valueWithPullback overload is internal, so this module carries its own,
// built on the standard library's 3-ary overload via the same pair-packing trick.

public struct ArgumentPair<A: Differentiable, B: Differentiable>: Differentiable {
    public var a: A
    public var b: B

    public init(a: A, b: B) {
        self.a = a
        self.b = b
    }
}

public func valueWithPullback4<T, U, V, W, R>(
    at t: T, _ u: U, _ v: V, _ w: W,
    of f: @differentiable(reverse) (T, U, V, W) -> R
) -> (
    value: R,
    pullback: (R.TangentVector)
        -> (T.TangentVector, U.TangentVector, V.TangentVector, W.TangentVector)
) {
    let (value, pullback) = valueWithPullback(at: t, u, ArgumentPair(a: v, b: w)) { t, u, pair in
        f(t, u, pair.a, pair.b)
    }

    return (
        value: value,
        pullback: { d in
            let results = pullback(d)
            return (results.0, results.1, results.2.a, results.2.b)
        }
    )
}
