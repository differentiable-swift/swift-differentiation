#if canImport(_Differentiation)

import _Differentiation

extension Array where Element: Differentiable {
    // TODO: Make this work more generally
    @derivative(of: Array.subscript.get)
    @inlinable
    public func _vjpSubscriptRangeGet(bounds: Range<Int>) -> (
        value: ArraySlice<Element>,
        pullback: (ArraySlice<Element>.TangentVector) -> Array<Element>.TangentVector
    ) {
        let forwardCount = self.count
        return (
            value: self[bounds],
            pullback: { v in
                var result = Array<Element>.TangentVector(repeating: .zero, count: forwardCount)
                result.replaceSubrange(bounds, with: v)
                return result
            }
        )
    }
}

#endif
