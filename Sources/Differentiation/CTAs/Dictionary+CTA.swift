import _Differentiation

/// Adds a differentiable subscript to `Dictionary` using the `cta:` argument label to avoid
/// clashing with the built-in subscript. The getter is `mutating` so the pullback accumulates
/// directly into the existing tangent vector instead of allocating a fresh single-entry
/// dictionary per access (as the stock `subscript(_:)` derivative in
/// `Dictionary+Differentiation.swift` does).
extension Dictionary where Value: Differentiable {
    @inlinable
    public subscript(cta key: Key) -> Value? {
        @differentiable(reverse)
        mutating get {
            self[key]
        }

        // TODO: this is a workaround while we're unable to define a direct derivative for `subscript._modify`
        @differentiable(reverse)
        set {
            self[key] = newValue
        }
    }

    @inlinable
    @derivative(of: subscript(cta:))
    public mutating func _vjpSubscriptCTAGet(cta key: Key)
        -> (value: Value?, pullback: (Optional<Value>.TangentVector, inout TangentVector) -> Void)
    {
        return (
            value: self[key],
            pullback: { dValue, tangentVector in
                // Sparse in-place accumulation: only the accessed key is touched, and repeated
                // reads of the same key add together rather than overwriting.
                if let dValue = dValue.value {
                    tangentVector[key, default: .zero] += dValue
                }
            }
        )
    }

    @inlinable
    @derivative(of: subscript(cta:).set)
    public mutating func _vjpSubscriptCTASet(newValue: Value?, cta key: Key)
        -> (value: Void, pullback: (inout TangentVector) -> Optional<Value>.TangentVector)
    {
        self[key] = newValue
        return (
            value: (),
            pullback: { tangentVector in
                let dElement = tangentVector[key] ?? .zero
                tangentVector[key] = .zero
                return Optional<Value>.TangentVector(dElement)
            }
        )
    }
}
