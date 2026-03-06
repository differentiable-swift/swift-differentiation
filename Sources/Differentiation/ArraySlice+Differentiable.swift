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
        for (selfIndex, offsetIndex) in zip(self.indices, offset.base.indices) {
            self[selfIndex].move(by: offset.base[offsetIndex])
        }
    }
}

extension ArraySlice where Element: Differentiable {
    @inlinable
    @derivative(of: subscript)
    func _vjpSubscript(index: Int) -> (
        value: Element,
        pullback: (Element.TangentVector) -> TangentVector
    ) {
        func pullback(_ v: Element.TangentVector) -> TangentVector {
            var dSelf = Array<Element.TangentVector>(
                repeating: .zero,
                count: count
            )
            dSelf[index] = v
            return TangentVector(dSelf)
        }
        return (self[index], pullback)
    }

    @inlinable
    @derivative(of: init(repeating:count:))
    static func _vjpInit(repeating repeatedValue: Element, count: Int) -> (
        value: ArraySlice<Element>,
        pullback: (TangentVector) -> Element.TangentVector
    ) {
        (
            value: Self(repeating: repeatedValue, count: count),
            pullback: { v in
                v.base.reduce(.zero, +)
            }
        )
    }
}

#endif
