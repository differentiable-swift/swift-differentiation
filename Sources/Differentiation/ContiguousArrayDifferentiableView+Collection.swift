#if canImport(_Differentiation)

import _Differentiation

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
    public init() {
        self.init(ContiguousArray<Element>())
    }

    @inlinable
    public mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C)
        where C: Collection, Element == C.Element
    {
        base.replaceSubrange(subrange, with: newElements)
    }
}

#endif
