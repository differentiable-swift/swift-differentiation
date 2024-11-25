#if canImport(_Differentiation)

import _Differentiation

public extension Array where Element: Differentiable {
    // Note: a compiler bug (SR-15530: https://bugs.swift.org/browse/SR-15530)
    // causes the vjpUpdate functions to be associated with the wrong
    // base functions unless you exactly align the function signatures in the
    // @derivative(of:) attribute and make sure the @inlinable attribute is the
    // same.

    /// This function defines a derivative for AutoDiff to use when update() is called. It's not meant to be called directly in most
    /// situations.
    ///
    /// - Parameters:
    ///     - index: The index to update the value at.
    ///     - newValue: The value to write.
    /// - Returns: The object, plus the pullback.
    @inlinable
    @derivative(of: update(at:with:))
    mutating func vjpUpdate(
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

public extension Array {
    /// A functional version of `Array.subscript.modify`.
    /// Differentiation does yet not support `Array.subscript.modify` because
    /// it is a coroutine.
    @inlinable
    #if canImport(_Differentiation)
    @differentiable(reverse where Element: Differentiable)
    #endif
    mutating func update(at index: Int, with newValue: Element) {
        self[index] = newValue
    }
}
