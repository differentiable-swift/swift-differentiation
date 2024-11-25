#if canImport(_Differentiation)

public extension Dictionary where Value: Differentiable {
    // make a manual update(at: with:) since https://bugs.swift.org/browse/TF-1277 affects dictionary as well, making @derivative(of:
    // subscript(_:).set) useless
    /// manual update function replacing `subscript(_:).set` since that cannot be made differentiable (might now be possible)
    @differentiable(reverse)
    mutating func set(_ key: Key, to newValue: Value) {
        self[key] = newValue
    }

    /// derivative of above set function. Ideally this would just be the derivative of `subscript(_:).set`
    @derivative(of: set)
    mutating func vjpUpdated(
        _ key: Key,
        to newValue: Value
    ) -> (value: Void, pullback: (inout TangentVector) -> (Value.TangentVector)) {
        set(key, to: newValue)

        let forwardCount = count
        let forwardKeys = keys // may be heavy to capture all of these, not sure how to do without them though

        return ((), { tangentVector in
            // manual zero tangent initialization
            if tangentVector.count < forwardCount {
                tangentVector = Self.TangentVector()
                forwardKeys.forEach { tangentVector[$0] = .zero }
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
