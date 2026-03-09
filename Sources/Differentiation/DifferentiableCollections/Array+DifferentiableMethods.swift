#if canImport(_Differentiation)

import _Differentiation

extension Array where Element: Differentiable {
    @derivative(of: init)
    @inlinable
    static func _vjpInit<C: Collection>(_ c: C) -> (
        value: Self,
        pullback: (Self.TangentVector) -> C.TangentVector
    ) where
        C: Differentiable,
        C.Element == Element,
        C.TangentVector: RangeReplaceableCollection,
        Element.TangentVector == C.TangentVector.Element
    {
        (
            value: .init(c),
            pullback: { v in
                C.TangentVector(v)
            }
        )
    }
}

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
