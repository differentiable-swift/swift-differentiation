#if canImport(_Differentiation)
import _Differentiation

public struct Pair<A, B> {
    @usableFromInline
    var a: A
    @usableFromInline
    var b: B

    @inlinable
    init(_ a: A, _ b: B) {
        self.a = a
        self.b = b
    }
}

extension Pair: Differentiable where A: Differentiable, B: Differentiable {
    public typealias TangentVector = Pair<A.TangentVector, B.TangentVector>

    @inlinable
    public mutating func move(by offset: TangentVector) {
        a.move(by: offset.a)
        b.move(by: offset.b)
    }
}

extension Pair: Equatable where A: Equatable, B: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.a == rhs.a && lhs.b == rhs.b
    }
}

extension Pair: AdditiveArithmetic where A: AdditiveArithmetic, B: AdditiveArithmetic {
    @inlinable
    public var zero: Self {
        .init(.zero, .zero)
    }

    @inlinable
    public static func + (lhs: Self, rhs: Self) -> Self {
        .init(lhs.a + rhs.a, lhs.b + rhs.b)
    }

    @inlinable
    public static func - (lhs: Self, rhs: Self) -> Self {
        .init(lhs.a - rhs.a, lhs.b - rhs.b)
    }
}

// TODO: We should get rid of these overloads as soon as we have a variadic valueWithPullback implementation

@usableFromInline
func valueWithPullback<T, U, V, W, R>(
    at t: T, _ u: U, _ v: V, _ w: W, of f: @differentiable(reverse) (T, U, V, W) -> R
) -> (
    value: R,
    pullback: (R.TangentVector)
        -> (T.TangentVector, U.TangentVector, V.TangentVector, W.TangentVector)
) {
    let (value, pullback) = valueWithPullback(at: t, u, Pair(v, w)) { t, u, pair in
        f(t, u, pair.a, pair.b)
    }

    return (
        value: value,
        pullback: { v in
            let results = pullback(v)
            return (results.0, results.1, results.2.a, results.2.b)
        }
    )
}

@usableFromInline
func valueWithPullback<T, U, V, W, X, R>(
    at t: T, _ u: U, _ v: V, _ w: W, _ x: X, of f: @differentiable(reverse) (T, U, V, W, X) -> R
) -> (
    value: R,
    pullback: (R.TangentVector)
        -> (T.TangentVector, U.TangentVector, V.TangentVector, W.TangentVector, X.TangentVector)
) {
    let (value, pullback) = valueWithPullback(at: t, Pair(u, v), Pair(w, x)) { t, pair1, pair2 in
        f(t, pair1.a, pair1.b, pair2.a, pair2.b)
    }

    return (
        value: value,
        pullback: { v in
            let results = pullback(v)
            return (results.0, results.1.a, results.1.b, results.2.a, results.2.b)
        }
    )
}

@usableFromInline
func valueWithPullback<T, U, V, W, X, Y, R>(
    at t: T, _ u: U, _ v: V, _ w: W, _ x: X, _ y: Y, of f: @differentiable(reverse) (T, U, V, W, X, Y) -> R
) -> (
    value: R,
    pullback: (R.TangentVector)
        -> (T.TangentVector, U.TangentVector, V.TangentVector, W.TangentVector, X.TangentVector, Y.TangentVector)
) {
    let (value, pullback) = valueWithPullback(at: Pair(t, u), Pair(v, w), Pair(x, y)) { pair1, pair2, pair3 in
        f(pair1.a, pair1.b, pair2.a, pair2.b, pair3.a, pair3.b)
    }

    return (
        value: value,
        pullback: { v in
            let results = pullback(v)
            return (results.0.a, results.0.b, results.1.a, results.1.b, results.2.a, results.2.b)
        }
    )
}

@usableFromInline
func valueWithPullback<T, U, V, W, X, Y, Z, R>(
    at t: T, _ u: U, _ v: V, _ w: W, _ x: X, _ y: Y, _ z: Z, of f: @differentiable(reverse) (T, U, V, W, X, Y, Z) -> R
) -> (
    value: R,
    pullback: (R.TangentVector)
        -> (T.TangentVector, U.TangentVector, V.TangentVector, W.TangentVector, X.TangentVector, Y.TangentVector, Z.TangentVector)
) {
    let (value, pullback) = valueWithPullback(at: Pair(t, u), Pair(v, w), Pair(x, Pair(y, z))) { pair1, pair2, pair3 in
        f(pair1.a, pair1.b, pair2.a, pair2.b, pair3.a, pair3.b.a, pair3.b.b)
    }

    return (
        value: value,
        pullback: { v in
            let results = pullback(v)
            return (results.0.a, results.0.b, results.1.a, results.1.b, results.2.a, results.2.b.a, results.2.b.b)
        }
    )
}

@usableFromInline
func valueWithPullback<S, T, U, V, W, X, Y, Z, R>(
    at s: S, _ t: T, _ u: U, _ v: V, _ w: W, _ x: X, _ y: Y, _ z: Z, of f: @differentiable(reverse) (S, T, U, V, W, X, Y, Z) -> R
) -> (
    value: R,
    pullback: (R.TangentVector)
        -> (
            S.TangentVector,
            T.TangentVector,
            U.TangentVector,
            V.TangentVector,
            W.TangentVector,
            X.TangentVector,
            Y.TangentVector,
            Z.TangentVector
        )
) {
    let (value, pullback) = valueWithPullback(at: Pair(s, t), Pair(u, v), Pair(Pair(w, x), Pair(y, z))) { pair1, pair2, pair3 in
        f(pair1.a, pair1.b, pair2.a, pair2.b, pair3.a.a, pair3.a.b, pair3.b.a, pair3.b.b)
    }

    return (
        value: value,
        pullback: { v in
            let results = pullback(v)
            return (results.0.a, results.0.b, results.1.a, results.1.b, results.2.a.a, results.2.a.b, results.2.b.a, results.2.b.b)
        }
    )
}

@usableFromInline
func valueWithPullback<Q, S, T, U, V, W, X, Y, Z, R>(
    at q: Q, _ s: S, _ t: T, _ u: U, _ v: V, _ w: W, _ x: X, _ y: Y, _ z: Z, of f: @differentiable(reverse) (Q, S, T, U, V, W, X, Y, Z) -> R
) -> (
    value: R,
    pullback: (R.TangentVector)
        -> (
            Q.TangentVector,
            S.TangentVector,
            T.TangentVector,
            U.TangentVector,
            V.TangentVector,
            W.TangentVector,
            X.TangentVector,
            Y.TangentVector,
            Z.TangentVector
        )
) {
    let (value, pullback) = valueWithPullback(at: Pair(q, s), Pair(t, Pair(u, v)), Pair(Pair(w, x), Pair(y, z))) { pair1, pair2, pair3 in
        f(pair1.a, pair1.b, pair2.a, pair2.b.a, pair2.b.b, pair3.a.a, pair3.a.b, pair3.b.a, pair3.b.b)
    }

    return (
        value: value,
        pullback: { v in
            let results = pullback(v)
            return (
                results.0.a,
                results.0.b,
                results.1.a,
                results.1.b.a,
                results.1.b.b,
                results.2.a.a,
                results.2.a.b,
                results.2.b.a,
                results.2.b.b
            )
        }
    )
}

@usableFromInline
func valueWithPullback<P, Q, S, T, U, V, W, X, Y, Z, R>(
    at p: P, _ q: Q, _ s: S, _ t: T, _ u: U, _ v: V, _ w: W, _ x: X, _ y: Y, _ z: Z, of f: @differentiable(reverse) (
        P,
        Q,
        S,
        T,
        U,
        V,
        W,
        X,
        Y,
        Z
    ) -> R
) -> (
    value: R,
    pullback: (R.TangentVector)
        -> (
            P.TangentVector,
            Q.TangentVector,
            S.TangentVector,
            T.TangentVector,
            U.TangentVector,
            V.TangentVector,
            W.TangentVector,
            X.TangentVector,
            Y.TangentVector,
            Z.TangentVector
        )
) {
    let (value, pullback) = valueWithPullback(at: Pair(p, q), Pair(Pair(s, t), Pair(u, v)), Pair(
        Pair(w, x),
        Pair(y, z)
    )) { pair1, pair2, pair3 in
        f(pair1.a, pair1.b, pair2.a.a, pair2.a.b, pair2.b.a, pair2.b.b, pair3.a.a, pair3.a.b, pair3.b.a, pair3.b.b)
    }

    return (
        value: value,
        pullback: { v in
            let results = pullback(v)
            return (
                results.0.a,
                results.0.b,
                results.1.a.a,
                results.1.a.b,
                results.1.b.a,
                results.1.b.b,
                results.2.a.a,
                results.2.a.b,
                results.2.b.a,
                results.2.b.b
            )
        }
    )
}

@usableFromInline
func valueWithPullback<O, P, Q, S, T, U, V, W, X, Y, Z, R>(
    at o: O, _ p: P, _ q: Q, _ s: S, _ t: T, _ u: U, _ v: V, _ w: W, _ x: X, _ y: Y, _ z: Z, of f: @differentiable(reverse) (
        O,
        P,
        Q,
        S,
        T,
        U,
        V,
        W,
        X,
        Y,
        Z
    ) -> R
) -> (
    value: R,
    pullback: (R.TangentVector)
        -> (
            O.TangentVector,
            P.TangentVector,
            Q.TangentVector,
            S.TangentVector,
            T.TangentVector,
            U.TangentVector,
            V.TangentVector,
            W.TangentVector,
            X.TangentVector,
            Y.TangentVector,
            Z.TangentVector
        )
) {
    let (value, pullback) = valueWithPullback(at: Pair(o, Pair(p, q)), Pair(Pair(s, t), Pair(u, v)), Pair(
        Pair(w, x),
        Pair(y, z)
    )) { pair1, pair2, pair3 in
        f(pair1.a, pair1.b.a, pair1.b.b, pair2.a.a, pair2.a.b, pair2.b.a, pair2.b.b, pair3.a.a, pair3.a.b, pair3.b.a, pair3.b.b)
    }

    return (
        value: value,
        pullback: { v in
            let results = pullback(v)
            return (
                results.0.a,
                results.0.b.a,
                results.0.b.b,
                results.1.a.a,
                results.1.a.b,
                results.1.b.a,
                results.1.b.b,
                results.2.a.a,
                results.2.a.b,
                results.2.b.a,
                results.2.b.b
            )
        }
    )
}

@usableFromInline
func valueWithPullback<N, O, P, Q, S, T, U, V, W, X, Y, Z, R>(
    at n: N, _ o: O, _ p: P, _ q: Q, _ s: S, _ t: T, _ u: U, _ v: V, _ w: W, _ x: X, _ y: Y, _ z: Z, of f: @differentiable(reverse) (
        N,
        O,
        P,
        Q,
        S,
        T,
        U,
        V,
        W,
        X,
        Y,
        Z
    ) -> R
) -> (
    value: R,
    pullback: (R.TangentVector)
        -> (
            N.TangentVector,
            O.TangentVector,
            P.TangentVector,
            Q.TangentVector,
            S.TangentVector,
            T.TangentVector,
            U.TangentVector,
            V.TangentVector,
            W.TangentVector,
            X.TangentVector,
            Y.TangentVector,
            Z.TangentVector
        )
) {
    let (value, pullback) = valueWithPullback(at: Pair(Pair(n, o), Pair(p, q)), Pair(Pair(s, t), Pair(u, v)), Pair(
        Pair(w, x),
        Pair(y, z)
    )) { pair1, pair2, pair3 in
        f(
            pair1.a.a,
            pair1.a.b,
            pair1.b.a,
            pair1.b.b,
            pair2.a.a,
            pair2.a.b,
            pair2.b.a,
            pair2.b.b,
            pair3.a.a,
            pair3.a.b,
            pair3.b.a,
            pair3.b.b
        )
    }

    return (
        value: value,
        pullback: { v in
            let results = pullback(v)
            return (
                results.0.a.a,
                results.0.a.b,
                results.0.b.a,
                results.0.b.b,
                results.1.a.a,
                results.1.a.b,
                results.1.b.a,
                results.1.b.b,
                results.2.a.a,
                results.2.a.b,
                results.2.b.a,
                results.2.b.b
            )
        }
    )
}

@usableFromInline
func valueWithPullback<M, N, O, P, Q, S, T, U, V, W, X, Y, Z, R>(
    at m: M, _ n: N, _ o: O, _ p: P, _ q: Q, _ s: S, _ t: T, _ u: U, _ v: V, _ w: W, _ x: X, _ y: Y, _ z: Z,
    of f: @differentiable(reverse) (
        M,
        N,
        O,
        P,
        Q,
        S,
        T,
        U,
        V,
        W,
        X,
        Y,
        Z
    ) -> R
) -> (
    value: R,
    pullback: (R.TangentVector)
        -> (
            M.TangentVector,
            N.TangentVector,
            O.TangentVector,
            P.TangentVector,
            Q.TangentVector,
            S.TangentVector,
            T.TangentVector,
            U.TangentVector,
            V.TangentVector,
            W.TangentVector,
            X.TangentVector,
            Y.TangentVector,
            Z.TangentVector
        )
) {
    let (value, pullback) = valueWithPullback(
        at: Pair(Pair(Pair(m, n), o), Pair(p, q)),
        Pair(Pair(s, t), Pair(u, v)),
        Pair(Pair(w, x), Pair(y, z))
    ) { pair1, pair2, pair3 in
        f(
            pair1.a.a.a,
            pair1.a.a.b,
            pair1.a.b,
            pair1.b.a,
            pair1.b.b,
            pair2.a.a,
            pair2.a.b,
            pair2.b.a,
            pair2.b.b,
            pair3.a.a,
            pair3.a.b,
            pair3.b.a,
            pair3.b.b
        )
    }

    return (
        value: value,
        pullback: { v in
            let results = pullback(v)
            return (
                results.0.a.a.a,
                results.0.a.a.b,
                results.0.a.b,
                results.0.b.a,
                results.0.b.b,
                results.1.a.a,
                results.1.a.b,
                results.1.b.a,
                results.1.b.b,
                results.2.a.a,
                results.2.a.b,
                results.2.b.a,
                results.2.b.b
            )
        }
    )
}

@usableFromInline
func valueWithPullback<L, M, N, O, P, Q, S, T, U, V, W, X, Y, Z, R>(
    at l: L, _ m: M, _ n: N, _ o: O, _ p: P, _ q: Q, _ s: S, _ t: T, _ u: U, _ v: V, _ w: W, _ x: X, _ y: Y, _ z: Z,
    of f: @differentiable(reverse) (
        L,
        M,
        N,
        O,
        P,
        Q,
        S,
        T,
        U,
        V,
        W,
        X,
        Y,
        Z
    ) -> R
) -> (
    value: R,
    pullback: (R.TangentVector)
        -> (
            L.TangentVector,
            M.TangentVector,
            N.TangentVector,
            O.TangentVector,
            P.TangentVector,
            Q.TangentVector,
            S.TangentVector,
            T.TangentVector,
            U.TangentVector,
            V.TangentVector,
            W.TangentVector,
            X.TangentVector,
            Y.TangentVector,
            Z.TangentVector
        )
) {
    let (value, pullback) = valueWithPullback(
        at: Pair(Pair(Pair(l, m), Pair(n, o)), Pair(p, q)),
        Pair(Pair(s, t), Pair(u, v)),
        Pair(Pair(w, x), Pair(y, z))
    ) { pair1, pair2, pair3 in
        f(
            pair1.a.a.a,
            pair1.a.a.b,
            pair1.a.b.a,
            pair1.a.b.b,
            pair1.b.a,
            pair1.b.b,
            pair2.a.a,
            pair2.a.b,
            pair2.b.a,
            pair2.b.b,
            pair3.a.a,
            pair3.a.b,
            pair3.b.a,
            pair3.b.b
        )
    }

    return (
        value: value,
        pullback: { v in
            let results = pullback(v)
            return (
                results.0.a.a.a,
                results.0.a.a.b,
                results.0.a.b.a,
                results.0.a.b.b,
                results.0.b.a,
                results.0.b.b,
                results.1.a.a,
                results.1.a.b,
                results.1.b.a,
                results.1.b.b,
                results.2.a.a,
                results.2.a.b,
                results.2.b.a,
                results.2.b.b
            )
        }
    )
}

#endif
