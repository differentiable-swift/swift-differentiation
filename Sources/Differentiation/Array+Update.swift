#if canImport(_Differentiation)

import _Differentiation

#endif

public extension Array {
    /// A Differentiable alternative to `Array.subscript.modify`.
    /// Differentiation does not yet support `Array.subscript.modify` because it is a coroutine.
    #if canImport(_Differentiation)
    @differentiable(reverse where Element: Differentiable)
    #endif
    @inlinable
    mutating func update(at index: Int, with newValue: Element) {
        self[index] = newValue
    }
}

#if canImport(_Differentiation)

extension Array where Element: Differentiable {
    /// This function defines a derivative for AutoDiff to use when update() is called. It's not meant to be called directly in most
    /// situations.
    ///
    /// - Parameters:
    ///     - index: The index to update the value at.
    ///     - newValue: The value to write.
    /// - Returns: The object, plus the pullback.
    @derivative(of: update(at:with:))
    @inlinable
    public mutating func _vjpUpdate(
        at index: Int,
        with newValue: Element
    ) -> (value: Void, pullback: (inout TangentVector) -> (Element.TangentVector)) {
        update(at: index, with: newValue)
        let forwardCount = self.count
        return ((), { tangentVector in
            // manual zero tangent initialization
            if tangentVector.base.count < forwardCount {
                tangentVector.base = .init(repeating: .zero, count: forwardCount)
            }
            let dElement = tangentVector[index]
            tangentVector.base[index] = .zero
            return dElement
        })
    }
}

#endif

