#if canImport(_Differentiation)
import _Differentiation
#endif

/// A wrapper around `Array` with an efficient enum-based `TangentVector`.
///
/// Unlike the stdlib `Array`, subscript access on `DifferentiableArray` produces a
/// one-hot tangent (`.oneHot`) instead of allocating a full zero-padded array,
/// reducing allocation cost from O(n²) to O(n) in typical reverse-mode workloads.
@frozen
public struct DifferentiableArray<Element> {
    @usableFromInline
    var _storage: [Element]

    @inlinable
    public init(_ storage: [Element] = []) {
        _storage = storage
    }

    @inlinable
    public init(repeating repeatedValue: Element, count: Int) {
        _storage = .init(repeating: repeatedValue, count: count)
    }
}

// MARK: - Collection conformances

extension DifferentiableArray: Collection, BidirectionalCollection, RandomAccessCollection {
    public typealias Index = Int
    public typealias SubSequence = ArraySlice<Element>
    public typealias Indices = Range<Int>

    @inlinable public var startIndex: Index { _storage.startIndex }
    @inlinable public var endIndex: Index { _storage.endIndex }
    @inlinable public var count: Int { _storage.count }

    @inlinable
    public subscript(position: Index) -> Element {
        get { _storage[position] }
        set { _storage[position] = newValue }
    }

    @inlinable
    public subscript(bounds: Range<Index>) -> SubSequence {
        get { _storage[bounds] }
        set { _storage[bounds] = newValue }
    }

    @inlinable public func index(before i: Index) -> Index { i - 1 }
    @inlinable public func index(after i: Index) -> Index { i + 1 }
}

extension DifferentiableArray: MutableCollection {}

extension DifferentiableArray: RangeReplaceableCollection {
    @inlinable
    public init() { self.init([]) }

    @inlinable
    public mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C)
        where C: Collection, Element == C.Element
    {
        _storage.replaceSubrange(subrange, with: newElements)
    }
}

extension DifferentiableArray: ExpressibleByArrayLiteral {
    @inlinable
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension DifferentiableArray: CustomStringConvertible {
    public var description: String { _storage.description }
}

extension DifferentiableArray: Equatable where Element: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool { lhs._storage == rhs._storage }
}

