#if canImport(_Differentiation)

import _Differentiation

extension ArraySlice: @retroactive Differentiable where Element: Differentiable {
    public typealias TangentVector = ArraySlice<Element.TangentVector>.DifferentiableView

    @inlinable
    public mutating func move(by offset: TangentVector) {
        if offset.base.isEmpty {
            return
        }
        precondition(
            self.count == offset.base.count,
            """
            Count mismatch: \(self.count) ('self') and \(offset.base.count) \
            ('direction')
            """
        )
        for i in offset.base.indices {
            self[i].move(by: offset.base[i])
        }
    }
}

#endif
