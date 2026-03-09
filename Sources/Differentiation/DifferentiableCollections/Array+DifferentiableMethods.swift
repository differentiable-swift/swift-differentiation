#if canImport(_Differentiation)

import _Differentiation

extension Array where Element: Differentiable {
    // TODO: Can we make this work for all RangeReplaceableCollections?
    @derivative(of: replaceSubrange)
    @inlinable
    public mutating func _vjpReplaceSubrange<C>(
        _ subrange: Range<Self.Index>,
        with newElements: C
    ) -> (
        value: (),
        pullback: (inout Self.TangentVector) -> C.TangentVector
    ) where C: Collection, C: Differentiable, Element == C.Element, C.TangentVector: RangeReplaceableCollection,
        C.TangentVector.Element == C.Element.TangentVector
    {
        self.replaceSubrange(subrange, with: newElements)
        return (
            value: (),
            pullback: { v in
                let dElement = v[subrange]
                for i in subrange {
                    v[i] = .zero
                }

                return C.TangentVector(dElement)
            }
        )
    }
}

#endif
