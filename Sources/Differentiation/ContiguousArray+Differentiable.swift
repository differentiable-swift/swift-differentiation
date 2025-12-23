#if canImport(_Differentiation)
import _Differentiation

#endif

extension ContiguousArray {
    /// A Differentiable alternative to `Array.subscript.modify`.
    /// Differentiation does not yet support `Array.subscript.modify` because it is a coroutine.
    /// https://github.com/swiftlang/swift/issues/55256
    #if canImport(_Differentiation)
    @differentiable(reverse where Element: Differentiable)
    #endif
    @inlinable
    public mutating func update(at index: Int, with newValue: Element) {
        self[index] = newValue
    }
}

#if canImport(_Differentiation)

extension ContiguousArray where Element: Differentiable {
    @frozen
    public struct DifferentiableView {
        public var base: ContiguousArray<Element>

        @inlinable
        init(_ base: ContiguousArray<Element>) {
            self.base = base
        }
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

extension ContiguousArray.DifferentiableView: ExpressibleByArrayLiteral
    where Element: Differentiable
{
    @inlinable
    public init(arrayLiteral elements: Element...) {
        self.init(ContiguousArray(elements))
    }
}

extension ContiguousArray.DifferentiableView: Equatable where Element: Equatable {
    @inlinable
    public static func == (lhs: ContiguousArray.DifferentiableView, rhs: ContiguousArray.DifferentiableView) -> Bool {
        lhs.base == rhs.base
    }
}

extension ContiguousArray.DifferentiableView: AdditiveArithmetic where Element: AdditiveArithmetic {
    @inlinable
    public static var zero: ContiguousArray.DifferentiableView {
        ContiguousArray.DifferentiableView([])
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
        var result = ContiguousArray()
        result.reserveCapacity(lhs.base.count)
        for i in lhs.base.indices {
            result.append(lhs.base[i] + rhs.base[i])
        }
        return ContiguousArray.DifferentiableView(result)
    }

    @inlinable
    public static func - (
        lhs: ContiguousArray.DifferentiableView,
        rhs: ContiguousArray.DifferentiableView
    ) -> ContiguousArray.DifferentiableView {
        if rhs.base.count == 0 {
            return lhs
        }

        var result = ContiguousArray()
        result.reserveCapacity(lhs.base.count)

        if lhs.base.count == 0 {
            for i in rhs.base.indices {
                result.append(.zero - rhs.base[i])
            }
            return ContiguousArray.DifferentiableView(result)
        }

        precondition(
            lhs.base.count == rhs.base.count,
            "Count mismatch: \(lhs.base.count) and \(rhs.base.count)"
        )

        for i in rhs.base.indices {
            result.append(lhs.base[i] - rhs.base[i])
        }
        return ContiguousArray.DifferentiableView(result)
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

extension ContiguousArray: @retroactive Differentiable where Element: Differentiable {
    public typealias TangentVector = ContiguousArray<Element.TangentVector>.DifferentiableView

    @inlinable
    public mutating func move(by offset: ContiguousArray<Element.TangentVector>.DifferentiableView) {
        if offset.base.isEmpty {
            return
        }
        precondition(
            self.count == offset.base.count, """
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

extension ContiguousArray.DifferentiableView:
    Sequence,
    Collection,
    RangeReplaceableCollection,
    RandomAccessCollection,
    BidirectionalCollection,
    MutableCollection
    where Element: Differentiable
{
    public typealias Element = ContiguousArray.Element
    public typealias Index = ContiguousArray.Index
    public typealias SubSequence = ContiguousArray.SubSequence

    @inlinable
    public subscript(position: Index) -> Element {
        _read { yield base[position] }
        set(newValue) { base[position] = newValue }
    }

    @inlinable
    public subscript(bounds: Range<Index>) -> SubSequence {
        get { base[bounds] }
        set(newValue) { base[bounds] = newValue }
    }

    @inlinable
    public var startIndex: Index { base.startIndex }

    @inlinable
    public var endIndex: Index { base.endIndex }

    @inlinable
    public init() { self.init(ContiguousArray<Element>()) }

    @inlinable
    public mutating func replaceSubrange<C>(_ subrange: Range<Self.Index>, with newElements: C)
        where C: Collection, Self.Element == C.Element
    {
        base.replaceSubrange(subrange, with: newElements)
    }
}

#endif
