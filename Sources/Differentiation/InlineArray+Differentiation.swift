#if swift(>=6.2)

import _Differentiation

@available(macOS 26, iOS 26, *)
extension InlineArray: @retroactive Differentiable where Element: Differentiable {
    public typealias TangentVector = InlineArray<count, Element.TangentVector>

    @inlinable
    public mutating func move(by offset: TangentVector) {
        for i in self.indices {
            self[i].move(by: offset[i])
        }
    }

    #if compiler(>=6.3)
    // This vjp is gated to 6.3+ as it would crash the compiler before 6.3
    @derivative(of: init)
    @_alwaysEmitIntoClient
    public static func _vjpInit(repeating value: Element) -> (value: Self, pullback: (TangentVector) -> Element.TangentVector) {
        (
            value: Self(repeating: value),
            pullback: { v in
                var result: Element.TangentVector = .zero
                for i in v.indices {
                    result += v[i]
                }
                return result
            }
        )
    }
    #endif
}

@available(macOS 26, iOS 26, *)
extension InlineArray: @retroactive AdditiveArithmetic where Element: AdditiveArithmetic {
    @inlinable
    public static var zero: InlineArray<count, Element> {
        .init(repeating: .zero)
    }

    @inlinable
    public static func + (lhs: InlineArray<count, Element>, rhs: InlineArray<count, Element>) -> InlineArray<count, Element> {
        InlineArray<count, Element> { lhs[$0] + rhs[$0] }
    }

    @inlinable
    public static func - (lhs: InlineArray<count, Element>, rhs: InlineArray<count, Element>) -> InlineArray<count, Element> {
        InlineArray<count, Element> { lhs[$0] - rhs[$0] }
    }
}

@available(macOS 26, iOS 26, *)
extension InlineArray where Element: Differentiable & AdditiveArithmetic {
    @derivative(of: +)
    @inlinable
    public static func _vjpAdd(
        lhs: InlineArray<count, Element>,
        rhs: InlineArray<count, Element>
    ) -> (
        value: InlineArray<count, Element>,
        pullback: (InlineArray<count, Element.TangentVector>) -> (
            InlineArray<count, Element.TangentVector>,
            InlineArray<count, Element.TangentVector>
        )
    ) {
        (
            value: lhs + rhs,
            pullback: { v in
                (v, v)
            }
        )
    }

    @derivative(of: -)
    @inlinable
    public static func _vjpSubtract(
        lhs: InlineArray<count, Element>,
        rhs: InlineArray<count, Element>
    ) -> (
        value: InlineArray<count, Element>,
        pullback: (InlineArray<count, Element.TangentVector>) -> (
            InlineArray<count, Element.TangentVector>,
            InlineArray<count, Element.TangentVector>
        )
    ) {
        (
            value: lhs - rhs,
            pullback: { v in
                (v, .zero - v)
            }
        )
    }
}

// Temporary conformance to `Equatable` as this will eventually land in the stdlib
@available(macOS 26, iOS 26, *)
extension InlineArray: @retroactive Equatable where Element: Equatable {
    @inlinable
    public static func == (lhs: InlineArray<count, Element>, rhs: InlineArray<count, Element>) -> Bool {
        for i in lhs.indices {
            if lhs[i] != rhs[i] { return false }
        }
        return true
    }
}

#endif
