#if canImport(_Differentiation)

import _Differentiation

#endif

public extension Dictionary {
    /// A Differentiable alternative to `Dictionary.subscript.modify`
    /// Differentiation does not yet support `Dictionary.subscript.modify` because it is a coroutine.
    #if canImport(_Differentiation)
    @differentiable(reverse where Value: Differentiable)
    #endif
    @inlinable
    mutating func update(at key: Key, with newValue: Value) {
        self[key] = newValue
    }
}

#if canImport(_Differentiation)

extension Dictionary where Value: Differentiable {
    /// This function defines a derivative for AutoDiff to use when update() is called. It's not meant to be called directly in most
    /// situations.
    ///
    /// - Parameters:
    ///     - key: The key to update the value at.
    ///     - newValue: The value to write.
    /// - Returns: The object, plus the pullback.
    @derivative(of: update(at:with:))
    @inlinable
    public mutating func _vjpUpdate(
        at key: Key,
        with newValue: Value
    ) -> (value: Void, pullback: (inout TangentVector) -> (Value.TangentVector)) {
        update(at: key, with: newValue)

        let forwardCount = count
        let forwardKeys = keys // may be heavy to capture all of these, not sure how to do without them though

        return ((), { tangentVector in
            // manual zero tangent initialization
            if tangentVector.count < forwardCount { // TODO: is this the correct check keys could still differ
                tangentVector = Self.TangentVector() // TODO: should we be replacing this or merging
                for key in forwardKeys {
                    tangentVector[key] = .zero
                }
            }

            if let dElement = tangentVector[key] {
                tangentVector[key] = .zero
                return dElement
            }
            else { // should this fail?
                tangentVector[key] = .zero
                return .zero
            }
        })
    }
}

#endif
