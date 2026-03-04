#if canImport(_Differentiation)

import _Differentiation

extension ArraySlice where Element: Differentiable {
    public struct DifferentiableView {
        public var base: ArraySlice<Element>
        
        @inlinable
        public init(_ base: ArraySlice<Element>) {
            self.base = base
        }
        
        @inlinable
        public init(_ base: Array<Element>) {
            self.base = base[...]
        }
    }
}

extension ArraySlice.DifferentiableView: Equatable where Element: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.base == rhs.base
    }
}

extension ArraySlice.DifferentiableView: AdditiveArithmetic where Element: AdditiveArithmetic {
    @inlinable
    public static var zero: ArraySlice.DifferentiableView {
        .init([])
    }

    @inlinable
    public static func + (
        lhs: ArraySlice.DifferentiableView,
        rhs: ArraySlice.DifferentiableView
    ) -> ArraySlice.DifferentiableView {
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
        return ArraySlice.DifferentiableView(zip(lhs.base, rhs.base).map(+))
    }

    @inlinable
    public static func - (
        lhs: ArraySlice.DifferentiableView,
        rhs: ArraySlice.DifferentiableView
    ) -> ArraySlice.DifferentiableView {
        if lhs.base.count == 0 {
            return ArraySlice.DifferentiableView(rhs.base.map { .zero - $0 })
        }
        if rhs.base.count == 0 {
            return lhs
        }
        precondition(
            lhs.base.count == rhs.base.count,
            "Count mismatch: \(lhs.base.count) and \(rhs.base.count)"
        )
        return ArraySlice.DifferentiableView(zip(lhs.base, rhs.base).map(-))
    }
}

extension ArraySlice.DifferentiableView: Differentiable {
    public typealias TangentVector = ArraySlice<Element.TangentVector>.DifferentiableView
    
    @derivative(of: ArraySlice.DifferentiableView.init)
    @inlinable
    static func _vjpInit(_ base: ArraySlice<Element>) -> (
        value: ArraySlice.DifferentiableView,
        pullback: (TangentVector) -> TangentVector
    ) {
        (ArraySlice.DifferentiableView(base), { $0 })
    }
    
    @derivative(of: ArraySlice.DifferentiableView.init)
    @inlinable
    static func _vjpInit(_ base: Array<Element>) -> (
        value: ArraySlice.DifferentiableView,
        pullback: (TangentVector) -> Array<Element>.TangentVector
    ) {
        (ArraySlice.DifferentiableView(base), { .init($0) })
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

extension ArraySlice.DifferentiableView: CustomStringConvertible {
    public var description: String {
        base.description
    }
}

extension ArraySlice.DifferentiableView: ExpressibleByArrayLiteral {
    @inlinable
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

#endif
