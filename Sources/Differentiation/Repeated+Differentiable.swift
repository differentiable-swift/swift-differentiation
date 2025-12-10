#if canImport(_Differentiation)

import _Differentiation

@derivative(of: repeatElement)
@inlinable
public func _vjpRepeatElement<Element: Differentiable>(
    _ element: Element,
    count: Int
) -> (value: Repeated<Element>, pullback: (Repeated<Element>.TangentVector) -> (Element.TangentVector)) {
    (
        value: repeatElement(element, count: count),
        pullback: { v in
            v.base.repeatedValue
        }
    )
}

extension Repeated where Element: Differentiable {
    public struct DifferentiableView {
        @usableFromInline
        var base: Repeated<Element>

        @inlinable
        public init(base: Repeated<Element>) {
            self.base = base
        }
    }
}

extension Repeated.DifferentiableView: Differentiable where Element: Differentiable {
    public typealias TangentVector = Repeated<Element.TangentVector>.DifferentiableView

    @inlinable
    public mutating func move(by offset: TangentVector) {
        if offset.base.isEmpty { return }
        precondition(
            self.base.count == offset.base.count, """
            Count mismatch: \(self.base.count) ('self') and \(offset.base.count) \
            ('direction')
            """
        )
        var newRepeatedValue = self.base.repeatedValue
        newRepeatedValue.move(by: offset.base.repeatedValue)
        self.base = repeatElement(newRepeatedValue, count: self.base.count)
    }
}

extension Repeated.DifferentiableView: Equatable where Element: Differentiable & Equatable {
    @inlinable
    public static func == (
        lhs: Repeated.DifferentiableView,
        rhs: Repeated.DifferentiableView
    ) -> Bool {
        lhs.base.count == rhs.base.count && lhs.base.repeatedValue == rhs.base.repeatedValue
    }
}

extension Repeated.DifferentiableView: AdditiveArithmetic
    where Element: AdditiveArithmetic & Differentiable
{
    @inlinable
    public static var zero: Repeated.DifferentiableView {
        Repeated.DifferentiableView(base: repeatElement(.zero, count: 0))
    }

    @inlinable
    public static func + (
        lhs: Repeated.DifferentiableView,
        rhs: Repeated.DifferentiableView
    ) -> Repeated.DifferentiableView {
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
        return Repeated.DifferentiableView(base: repeatElement(lhs.base.repeatedValue + rhs.base.repeatedValue, count: lhs.base.count))
    }

    @inlinable
    public static func - (
        lhs: Repeated.DifferentiableView,
        rhs: Repeated.DifferentiableView
    ) -> Repeated.DifferentiableView {
        if lhs.base.count == 0 {
            return Repeated.DifferentiableView(base: repeatElement(.zero - rhs.base.repeatedValue, count: rhs.base.count))
        }
        if rhs.base.count == 0 {
            return lhs
        }
        precondition(
            lhs.base.count == rhs.base.count,
            "Count mismatch: \(lhs.base.count) and \(rhs.base.count)"
        )
        return Repeated.DifferentiableView(base: repeatElement(lhs.base.repeatedValue - rhs.base.repeatedValue, count: lhs.base.count))
    }

    @inlinable
    public subscript(_ index: Int) -> Element {
        if index < base.count {
            return base[index]
        }
        else {
            return Element.zero
        }
    }
}

extension Repeated: @retroactive Differentiable where Element: Differentiable {
    public typealias TangentVector = Repeated<Element.TangentVector>.DifferentiableView

    @inlinable
    public mutating func move(by offset: TangentVector) {
        precondition(
            self.count == offset.base.count,
            "Count mismatch: \(self.count) and \(offset.base.count)"
        )
        var movedValue = self.repeatedValue
        movedValue.move(by: offset.base.repeatedValue)
        self = repeatElement(movedValue, count: self.count)
    }
}

extension Repeated.DifferentiableView:
    Sequence,
    Collection,
    RandomAccessCollection,
    BidirectionalCollection
    where Element: Differentiable
{
    public typealias Element = Repeated.Element
    public typealias Index = Repeated.Index
    public typealias SubSequence = Repeated.SubSequence

    @inlinable
    public subscript(position: Index) -> Element {
        _read { yield base[position] }
    }

    @inlinable
    public subscript(bounds: Range<Index>) -> SubSequence { base[bounds] }

    @inlinable
    public var startIndex: Index { base.startIndex }

    @inlinable
    public var endIndex: Index { base.endIndex }
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

#endif
