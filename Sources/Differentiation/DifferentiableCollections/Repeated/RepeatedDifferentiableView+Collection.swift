
extension Repeated.DifferentiableView:
    Sequence,
    Collection,
    RandomAccessCollection,
    BidirectionalCollection
    where Element: Differentiable
{
    public typealias Element = Repeated.Element
    public typealias Index = Repeated.Index
    public typealias Indices = Repeated.Indices
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
}
