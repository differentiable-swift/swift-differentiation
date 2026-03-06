#if canImport(_Differentiation)

extension ContiguousArray where Element: Differentiable {
    @frozen
    public struct DifferentiableView {
        public var base: ContiguousArray<Element>

        @inlinable
        public init(_ base: ContiguousArray<Element>) {
            self.base = base
        }
    }
}

extension ContiguousArray.DifferentiableView: Equatable where Element: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.base == rhs.base
    }
}

extension ContiguousArray.DifferentiableView: AdditiveArithmetic where Element: AdditiveArithmetic {
    @inlinable
    public static var zero: ContiguousArray.DifferentiableView {
        .init([])
    }

    @inlinable
    public static func + (
        lhs: ContiguousArray.DifferentiableView,
        rhs: ContiguousArray.DifferentiableView
    ) -> ContiguousArray.DifferentiableView {
        if lhs.base.count == 0 {
            return rhs
        }
        if rhs.base.count == 0 {
            return lhs
        }
        precondition(
            lhs.base.count == rhs.base.count,
            "Count mismatch: \(lhs.base.count) and \(rhs.base.count)"
        )
        return ContiguousArray.DifferentiableView(zip(lhs.base, rhs.base).map(+))
    }

    @inlinable
    public static func - (
        lhs: ContiguousArray.DifferentiableView,
        rhs: ContiguousArray.DifferentiableView
    ) -> ContiguousArray.DifferentiableView {
        if lhs.base.count == 0 {
            return ContiguousArray.DifferentiableView(rhs.base.map { .zero - $0 })
        }
        if rhs.base.count == 0 {
            return lhs
        }
        precondition(
            lhs.base.count == rhs.base.count,
            "Count mismatch: \(lhs.base.count) and \(rhs.base.count)"
        )
        return ContiguousArray.DifferentiableView(zip(lhs.base, rhs.base).map(-))
    }
}

extension ContiguousArray.DifferentiableView: Differentiable {
    public typealias TangentVector = ContiguousArray<Element.TangentVector>.DifferentiableView

    @derivative(of: ContiguousArray.DifferentiableView.init)
    @inlinable
    static func _vjpInit(_ base: ContiguousArray<Element>) -> (
        value: ContiguousArray.DifferentiableView,
        pullback: (TangentVector) -> TangentVector
    ) {
        (ContiguousArray.DifferentiableView(base), { $0 })
    }

    @inlinable
    public mutating func move(by offset: TangentVector) {
        if offset.base.isEmpty {
            return
        }
        precondition(
            base.count == offset.base.count, """
            Count mismatch: \(base.count) ('self') and \(offset.base.count) \
            ('direction')
            """
        )
        for i in offset.base.indices {
            base[i].move(by: offset.base[i])
        }
    }
}

extension ContiguousArray.DifferentiableView: CustomStringConvertible {
    public var description: String {
        base.description
    }
}

extension ContiguousArray.DifferentiableView: ExpressibleByArrayLiteral {
    @inlinable
    public init(arrayLiteral elements: Element...) {
        self.init(ContiguousArray(elements))
    }
}

#endif
