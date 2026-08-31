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
    public func index(after i: Int) -> Int {
        base.index(after: i)
    }

    @inlinable
    public func formIndex(after i: inout Int) {
        base.formIndex(after: &i)
    }

    @inlinable
    public func index(before i: Int) -> Int {
        base.index(before: i)
    }

    @inlinable
    public func formIndex(before i: inout Int) {
        base.formIndex(before: &i)
    }

    @inlinable
    public func index(_ i: Int, offsetBy distance: Int) -> Int {
        base.index(i, offsetBy: distance)
    }

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

    @inlinable
    public mutating func reserveCapacity(_ n: Int) {
        base.reserveCapacity(n)
    }

    @inlinable
    public mutating func append(_ newElement: Element) {
        base.append(newElement)
    }

    @inlinable
    public mutating func append<S: Sequence>(contentsOf newElements: S) where S.Element == Element {
        base.append(contentsOf: newElements)
    }

    @inlinable
    @discardableResult
    public mutating func remove(at index: Int) -> Element {
        base.remove(at: index)
    }
}
