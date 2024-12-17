#if canImport(_Differentiation)

import _Differentiation

extension Array.DifferentiableView:
    @retroactive Sequence,
    @retroactive Collection,
    @retroactive RangeReplaceableCollection,
    @retroactive RandomAccessCollection,
    @retroactive BidirectionalCollection,
    @retroactive MutableCollection
    where Element: Differentiable
{
    public typealias Element = Array.Element
    public typealias Index = Array.Index
    public typealias SubSequence = Array.SubSequence

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
    public init() { self.init(Array<Element>()) }

    @inlinable
    public mutating func replaceSubrange<C>(_ subrange: Range<Self.Index>, with newElements: C)
        where C: Collection, Self.Element == C.Element
    {
        base.replaceSubrange(subrange, with: newElements)
    }
}

#endif
