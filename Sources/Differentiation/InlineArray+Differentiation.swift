#if canImport(_Differentiation)

#if swift(>=6.2)

import _Differentiation

@available(macOS 26, *)
extension InlineArray: @retroactive Differentiable where Element: Differentiable {
    public typealias TangentVector = InlineArray<count, Element.TangentVector>

    @inlinable
    public mutating func move(by offset: TangentVector) {
        for i in self.indices {
            self[i].move(by: offset[i])
        }
    }

    // not available yet due to a compiler issue. This is in main as of 2025/05/25. Part of Swift 6.3
    /*
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
     */

    @inlinable
    public func read(_ i: Index) -> Element {
        self[i]
    }

    @derivative(of: read)
    @inlinable
    public func _vjpRead(_ i: Index) -> (value: Element, pullback: (Element.TangentVector) -> TangentVector) {
        (
            value: self[i],
            pullback: { v in
                var array = InlineArray<count, Element.TangentVector>(repeating: .zero)
                array[i] = v
                return array
            }
        )
    }

    @inlinable
    public mutating func update(at i: Index, with value: Element) {
        self[i] = value
    }

    @derivative(of: update)
    @inlinable
    public mutating func _vjpUpdate(
        at i: Index,
        with value: Element
    ) -> (value: Void, pullback: (inout TangentVector) -> Element.TangentVector) {
        self[i] = value
        return (
            value: (),
            pullback: { (v: inout TangentVector) in
                let dElement = v[i]
                v[i] = Element.TangentVector.zero
                return dElement
            }
        )
    }
}

@available(macOS 26, *)
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

@available(macOS 26, *)
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
@available(macOS 26, *)
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

#endif
