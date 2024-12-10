#if canImport(_Differentiation)

import _Differentiation

extension Array.DifferentiableView:
    @retroactive Sequence,
    @retroactive Collection,
    @retroactive RangeReplaceableCollection,
    @retroactive RandomAccessCollection,
    @retroactive BidirectionalCollection,
    @retroactive MutableCollection
where Element: Differentiable {
    /// The type being stored
    public typealias Element = Array.Element

    /// The type used as an index into the Array
    public typealias Index = Array.Index

    /// A contiguous sequence of values from within the Array
    public typealias SubSequence = Array.SubSequence

    /// Return or set the ``Element`` at the given index
    @inlinable
    public subscript(position: Index) -> Element {
        _read { yield base[position] }
        set(newValue) { base[position] = newValue }
    }

    /// Return or set the ``SubSequence`` at the given range of indices
    @inlinable
    public subscript(bounds: Range<Index>) -> SubSequence {
        get { base[bounds] }
        set(newValue) { base[bounds] = newValue }
    }

    /// The first index of the Array
    @inlinable
    public var startIndex: Index { base.startIndex }

    /// The last index of the Array
    @inlinable
    public var endIndex: Index { base.endIndex }

    /// Create a new ``Array.DifferentiableView``
    @inlinable
    public init() { self.init(Array<Element>()) }

    /// Replace the elements at a range of indices with the values from another ``Collection``
    @inlinable
    public mutating func replaceSubrange<C>(_ subrange: Range<Self.Index>, with newElements: C)
    where C: Collection, Self.Element == C.Element {
        base.replaceSubrange(subrange, with: newElements)
    }
}

#endif
