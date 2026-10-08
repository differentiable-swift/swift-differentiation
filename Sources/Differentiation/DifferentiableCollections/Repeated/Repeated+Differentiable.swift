import _Differentiation

extension Repeated: @retroactive Differentiable where Element: Differentiable {
    public typealias TangentVector = Repeated<Element.TangentVector>.DifferentiableView

    @inlinable
    public mutating func move(by offset: TangentVector) {
        if offset.base.isEmpty { return }
        precondition(
            self.count == offset.base.count,
            "Count mismatch: \(self.count) and \(offset.base.count)"
        )
        var movedValue = self.repeatedValue
        movedValue.move(by: offset.base.repeatedValue)
        self = repeatElement(movedValue, count: self.count)
    }
}

extension Repeated where Element: Differentiable {
    @derivative(of: subscript.get)
    @inlinable
    public func _vjpSubscriptGet(index: Int) -> (value: Element, pullback: (Element.TangentVector) -> TangentVector) {
        let count = self.count
        return (
            value: self[index],
            pullback: { v in
                TangentVector(base: repeatElement(v, count: count))
            }
        )
    }
}
