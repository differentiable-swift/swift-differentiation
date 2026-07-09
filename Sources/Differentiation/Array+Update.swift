import _Differentiation

extension Array {
    /// A Differentiable alternative to `Array.subscript.modify`.
    /// Differentiation does not yet support `Array.subscript.modify` because it is a coroutine.
    @differentiable(reverse where Element: Differentiable)
    @inlinable
    @available(*, deprecated, message: "Use subscript.set(newValue:cta:) instead")
    public mutating func update(at index: Int, with newValue: Element) {
        self[index] = newValue
    }
}

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
    @available(*, deprecated)
    public mutating func _vjpUpdate(
        at index: Int,
        with newValue: Element
    ) -> (value: Void, pullback: (inout TangentVector) -> (Element.TangentVector)) {
        update(at: index, with: newValue)
        let forwardCount = self.count
        return ((), { tangentVector in
            // manual zero tangent initialization
            if tangentVector.base.count < forwardCount {
                // this overwrites previous accumulation if we update a tangent of the wrong size
                tangentVector.base = .init(repeating: .zero, count: forwardCount)
            }
            let dElement = tangentVector[index]
            tangentVector.base[index] = .zero
            return dElement
        })
    }
}
