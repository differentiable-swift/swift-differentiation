import _Differentiation

extension SIMD16 where Scalar == Float {
    @_transparent
    public static func + (a: Self, b: Self) -> Self {
        var result = Self()
        for i in result.indices { result[i] = a[i] + b[i] }
        return result
    }

    @_transparent
    @derivative(of: +)
    public static func _vjpPlus(a: Self, b: Self) -> (
        value: Self,
        pullback: (Self.TangentVector) -> (Self.TangentVector, Self.TangentVector)
    ) {
        (
            value: a + b,
            pullback: { v in
                (v, v)
            }
        )
    }

    @_transparent
    public static func - (a: Self, b: Self) -> Self {
        var result = Self()
        for i in result.indices { result[i] = a[i] - b[i] }
        return result
    }

    @_transparent
    @derivative(of: -)
    public static func _vjpMin(a: Self, b: Self) -> (
        value: Self,
        pullback: (Self.TangentVector) -> (Self.TangentVector, Self.TangentVector)
    ) {
        (
            value: a - b,
            pullback: { v in
                (v, -v)
            }
        )
    }

    @_transparent
    public static func * (a: Self, b: Self) -> Self {
        var result = Self()
        for i in result.indices { result[i] = a[i] * b[i] }
        return result
    }

    @inlinable
    @derivative(of: *)
    static func _vjpMultiply(a: Self, b: Self) -> (
        value: Self,
        pullback: (TangentVector) -> (TangentVector, TangentVector)
    ) {
        (a * b, { v in
            (v * b, v * a)
        })
    }

    @_transparent
    public static func / (a: Self, b: Self) -> Self {
        var result = Self()
        for i in result.indices { result[i] = a[i] / b[i] }
        return result
    }

    @inlinable
    @derivative(of: /)
    static func _vjpDivide(lhs: Self, rhs: Self) -> (
        value: Self,
        pullback: (TangentVector) -> (TangentVector, TangentVector)
    ) {
        (lhs / rhs, { v in
            (v / rhs, -lhs / (rhs * rhs) * v)
        })
    }

    @_transparent
    public func addingProduct(_ a: Self, _ b: Self) -> Self {
        var result = Self()
        for i in result.indices { result[i] = self[i].addingProduct(a[i], b[i]) }
        return result
    }

    @derivative(of: addingProduct)
    @_transparent
    public func _vjpAddingProduct(
        _ lhs: Self, _ rhs: Self
    ) -> (value: Self, pullback: (Self) -> (Self, Self, Self)) {
        (addingProduct(lhs, rhs), { v in (v, v * rhs, v * lhs) })
    }

    @_transparent
    public func squareRoot() -> Self {
        var result = Self()
        for i in result.indices { result[i] = self[i].squareRoot() }
        return result
    }

    @_transparent
    public func _vjpSquareRoot() -> (value: Self, pullback: (TangentVector) -> TangentVector) {
        let y = self.squareRoot()
        return (y, { v in v / (2 * y) })
    }

    /// The sum of the scalars in the vector.
    @_alwaysEmitIntoClient
    public func sum() -> Scalar {
        // Implementation note: this eventually be defined to lower to either
        // llvm.experimental.vector.reduce.fadd or an explicit tree-sum. Open-
        // coding the tree sum is problematic, we probably need to define a
        // Swift Builtin to support it.
        //
        // Use -0 so that LLVM can optimize away initial value + self[0].
        var result = -Scalar.zero
        for i in indices {
            result += self[i]
        }
        return result
    }

    @inlinable
    @_alwaysEmitIntoClient
    @derivative(of: sum)
    func _vjpSum() -> (
        value: Scalar,
        pullback: (Scalar.TangentVector) -> TangentVector
    ) {
        (sum(), { v in Self(repeating: Scalar(v)) })
    }

    @_transparent
    public static prefix func - (a: Self) -> Self {
        0 - a
    }

    @inlinable
    @derivative(of: -)
    static func _vjpNegate(a: Self) -> (
        value: Self,
        pullback: (TangentVector) -> (TangentVector)
    ) {
        (-a, { v in
            -v
        })
    }

    @_transparent
    public static func + (a: Scalar, b: Self) -> Self {
        Self(repeating: a) + b
    }

    @inlinable
    @derivative(of: +)
    static func _vjpAdd(a: Scalar, b: Self) -> (
        value: Self,
        pullback: (TangentVector) -> (Scalar.TangentVector, TangentVector)
    ) {
        (a + b, { v in
            (v.sum(), v)
        })
    }

    @_transparent
    public static func - (a: Scalar, b: Self) -> Self {
        Self(repeating: a) - b
    }

    @inlinable
    @derivative(of: -)
    static func _vjpSubtract(a: Scalar, b: Self) -> (
        value: Self,
        pullback: (TangentVector) -> (Scalar.TangentVector, TangentVector)
    ) {
        (a - b, { v in
            (v.sum(), -v)
        })
    }

    @_transparent
    public static func * (a: Scalar, b: Self) -> Self {
        Self(repeating: a) * b
    }

    @inlinable
    @derivative(of: *)
    static func _vjpMultiply(lhs: Scalar, rhs: Self) -> (
        value: Self,
        pullback: (TangentVector) -> (Scalar.TangentVector, TangentVector)
    ) {
        (lhs * rhs, { v in
            ((v * rhs).sum(), v * lhs)
        })
    }

    @_transparent
    public static func / (a: Scalar, b: Self) -> Self {
        Self(repeating: a) / b
    }

    @inlinable
    @derivative(of: /)
    static func _vjpDivide(lhs: Scalar, rhs: Self) -> (
        value: Self,
        pullback: (TangentVector) -> (Scalar.TangentVector, TangentVector)
    ) {
        (lhs / rhs, { v in
            ((v / rhs).sum(), -lhs / (rhs * rhs) * v)
        })
    }

    @_transparent
    public static func + (a: Self, b: Scalar) -> Self {
        a + Self(repeating: b)
    }

    @inlinable
    @derivative(of: +)
    static func _vjpAdd(lhs: Self, rhs: Scalar) -> (
        value: Self,
        pullback: (TangentVector) -> (TangentVector, Scalar.TangentVector)
    ) {
        (lhs + rhs, { v in
            (v, v.sum())
        })
    }

    @_transparent
    public static func - (a: Self, b: Scalar) -> Self {
        a - Self(repeating: b)
    }

    @inlinable
    @derivative(of: -)
    static func _vjpSubtract(lhs: Self, rhs: Scalar) -> (
        value: Self,
        pullback: (TangentVector) -> (TangentVector, Scalar.TangentVector)
    ) {
        (lhs - rhs, { v in
            (v, -v.sum())
        })
    }

    @_transparent
    public static func * (a: Self, b: Scalar) -> Self {
        a * Self(repeating: b)
    }

    @inlinable
    @derivative(of: *)
    static func _vjpMultiply(lhs: Self, rhs: Scalar) -> (
        value: Self,
        pullback: (TangentVector) -> (TangentVector, Scalar.TangentVector)
    ) {
        (lhs * rhs, { v in
            (v * rhs, (v * lhs).sum())
        })
    }

    @_transparent
    public static func / (a: Self, b: Scalar) -> Self {
        a / Self(repeating: b)
    }

    @inlinable
    @derivative(of: /)
    static func _vjpDivide(lhs: Self, rhs: Scalar) -> (
        value: Self,
        pullback: (TangentVector) -> (TangentVector, Scalar.TangentVector)
    ) {
        (lhs / rhs, { v in
            (v / rhs, (-lhs / (rhs * rhs) * v).sum())
        })
    }

    @differentiable(reverse)
    @_transparent
    public static func += (a: inout Self, b: Self) {
        a = a + b
    }

    @differentiable(reverse)
    @_transparent
    public static func -= (a: inout Self, b: Self) {
        a = a - b
    }

    @differentiable(reverse)
    @_transparent
    public static func *= (a: inout Self, b: Self) {
        a = a * b
    }

    @differentiable(reverse)
    @_transparent
    public static func /= (a: inout Self, b: Self) {
        a = a / b
    }

    @differentiable(reverse)
    @_transparent
    public static func += (a: inout Self, b: Scalar) {
        a = a + b
    }

    @differentiable(reverse)
    @_transparent
    public static func -= (a: inout Self, b: Scalar) {
        a = a - b
    }

    @differentiable(reverse)
    @_transparent
    public static func *= (a: inout Self, b: Scalar) {
        a = a * b
    }

    @differentiable(reverse)
    @_transparent
    public static func /= (a: inout Self, b: Scalar) {
        a = a / b
    }
}
