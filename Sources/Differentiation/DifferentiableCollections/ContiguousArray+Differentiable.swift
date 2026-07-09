import _Differentiation

extension ContiguousArray {
    /// A Differentiable alternative to `Array.subscript.modify`.
    /// Differentiation does not yet support `Array.subscript.modify` because it is a coroutine.
    /// https://github.com/swiftlang/swift/issues/55256
    @differentiable(reverse where Element: Differentiable)
    @inlinable
    @available(*, deprecated, message: "Use subscript.set(newValue:cta:) instead")
    public mutating func update(at index: Int, with newValue: Element) {
        self[index] = newValue
    }
}

extension ContiguousArray: @retroactive Differentiable where Element: Differentiable {
    public typealias TangentVector = ContiguousArray<Element.TangentVector>.DifferentiableView

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
        for i in self.indices {
            self[i].move(by: offset.base[i])
        }
    }
}

extension ContiguousArray where Element: Differentiable {
    @inlinable
    @derivative(of: subscript)
    func _vjpSubscript(index: Int) -> (
        value: Element,
        pullback: (Element.TangentVector) -> TangentVector
    ) {
        func pullback(_ v: Element.TangentVector) -> TangentVector {
            var dSelf = ContiguousArray<Element.TangentVector>(
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
        value: ContiguousArray<Element>,
        pullback: (TangentVector) -> Element.TangentVector
    ) {
        (
            value: Self(repeating: repeatedValue, count: count),
            pullback: { v in
                v.base.reduce(.zero, +)
            }
        )
    }

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
                tangentVector.base = .init(repeating: .zero, count: forwardCount)
            }
            let dElement = tangentVector[index]
            tangentVector.base[index] = .zero
            return dElement
        })
    }
}
