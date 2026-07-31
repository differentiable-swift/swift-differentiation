import _Differentiation

// accessors for the Dictionary type.
// These are a workaround as we cant define derivatives for `subscript._modify` yet

extension Dictionary where Value: Differentiable {
    @inlinable
    public subscript(ad key: Key) -> Value? {
        // This uses the derivative from the non `ad:` prefixed subscript to not have to switch between using and not using it.
        @differentiable(reverse)
        get {
            self[key]
        }

        // TODO: this is a workaround while we're unable to define a direct derivative for `subscript._modify`
        @differentiable(reverse)
        set {
            self[key] = newValue
        }
    }

    /// This function defines a derivative for AutoDiff to use when update() is called. It's not meant to be called directly in most
    /// situations.
    ///
    /// - Parameters:
    ///     - key: The key to update the value at.
    ///     - newValue: The value to write.
    /// - Returns: The object, plus the pullback.
    @derivative(of: subscript(ad:).set)
    @inlinable
    public mutating func _vjpSubscriptSet(
        newValue: Value?,
        ad key: Key
    ) -> (value: Void, pullback: (inout TangentVector) -> (Value?.TangentVector)) {
        self[key] = newValue

        return ((), { tangentVector in
            // The write overwrites the value at `key`, so the base's incoming adjoint at
            // `key` flows out to `newValue`, and the base's pre-write adjoint at `key` is
            // removed. All other keys pass through untouched. A missing key is definitionally
            // zero in `Dictionary.TangentVector`, so this stays sparse.
            let dElement = tangentVector[key]
            tangentVector[key] = nil
            return Optional<Value>.TangentVector(dElement)
        })
    }
}
