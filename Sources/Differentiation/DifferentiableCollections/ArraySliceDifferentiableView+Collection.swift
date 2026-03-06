#if canImport(_Differentiation)

import _Differentiation

extension ArraySlice.DifferentiableView:
    Sequence,
    Collection,
    RangeReplaceableCollection,
    RandomAccessCollection,
    BidirectionalCollection,
    MutableCollection
    where Element: Differentiable
{
    public typealias Element = ArraySlice.Element
    public typealias Index = ArraySlice.Index
    public typealias SubSequence = ArraySlice.SubSequence

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
        self.init(ArraySlice<Element>())
    }

    @inlinable
    public mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C)
        where C: Collection, Element == C.Element
    {
        base.replaceSubrange(subrange, with: newElements)
    }
}

#endif
