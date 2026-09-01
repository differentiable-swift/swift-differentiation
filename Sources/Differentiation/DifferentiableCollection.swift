import _Differentiation

// `DifferentiableCollection` is just a collection of conformances and has no requirements of it's own. This mainly exists to show the end
// goal, which is working with a collection that is differentiable. Even though the requirements for that mainly rest on the collection's
// tangentvector.
public protocol DifferentiableCollection: Differentiable & Collection where
    Element: Differentiable,
    TangentVector: DifferentiableCollectionTangentVector,
    TangentVector.Element == Element.TangentVector
{
    associatedtype Element
    associatedtype TangentVector
}

public protocol DifferentiableCollectionTangentVector {
    associatedtype Element

    /// Build a dense tangent of `count` elements, where element `i` is the `i`-th value returned
    /// by `nextElement()`.
    ///
    /// The fast path for constructing a tangent in a pullback: the conformer owns the loop, so
    /// contiguous types fill their storage directly while non-contiguous types (e.g. `Repeated`)
    /// fold the elements in without allocating any intermediate storage.
    ///
    /// A conformer must call `nextElement()` exactly `count` times. The library's pullbacks
    /// construct tangents through the internal `building(count:_:)` helper, whose closure enforces
    /// that contract at runtime: it hands out elements strictly in index order, traps when called
    /// more than `count` times, and traps after the fact if the conformer consumed fewer. Because
    /// the closure carries no index parameter and is non-escaping, a conformer cannot skip, repeat,
    /// reorder, or smuggle it, the properties those pullbacks rely on for memory safety when they
    /// stage per-element work (lockstep index walks, raw scratch storage) behind it.
    init(count: Int, nextElement: () -> Element)
}

extension DifferentiableCollectionTangentVector {
    /// Build a dense tangent of `count` elements, where element `i` is `element(i)`.
    ///
    /// Drives `init(count:nextElement:)` with a closure that produces `element(0), element(1), …,
    /// element(count - 1)` strictly in order, exactly once each, and traps if the conformer
    /// consumes too few or too many. Callers may therefore stage per-index side effects in
    /// `element` without trusting the conformer's loop to be well-behaved. Construct tangents
    /// through this entry point rather than calling `init(count:nextElement:)` directly — a direct
    /// call carries none of these checks.
    @inlinable
    static func building(count: Int, _ element: (Int) -> Element) -> Self {
        var next = 0
        let result = Self(count: count) {
            precondition(next < count, "\(Self.self).init(count:nextElement:) consumed more than \(count) elements")
            defer { next += 1 }
            return element(next)
        }
        precondition(
            next == count,
            "\(Self.self).init(count:nextElement:) consumed \(next) of \(count) elements"
        )
        return result
    }
}

extension Array: DifferentiableCollection where Element: Differentiable {}

extension Array.DifferentiableView: DifferentiableCollectionTangentVector {
    @inlinable
    public init(count: Int, nextElement: () -> Element) {
        self.init([Element](unsafeUninitializedCapacity: count) { buffer, initializedCount in
            for i in 0 ..< count {
                buffer.initializeElement(at: i, to: nextElement())
            }
            initializedCount = count
        })
    }
}

extension ContiguousArray: DifferentiableCollection where Element: Differentiable {}

extension ContiguousArray.DifferentiableView: DifferentiableCollectionTangentVector {
    @inlinable
    public init(count: Int, nextElement: () -> Element) {
        self.init(ContiguousArray<Element>(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            for i in 0 ..< count {
                buffer.initializeElement(at: i, to: nextElement())
            }
            initializedCount = count
        })
    }
}

extension ArraySlice: DifferentiableCollection where Element: Differentiable {}

extension ArraySlice.DifferentiableView: DifferentiableCollectionTangentVector {
    @inlinable
    public init(count: Int, nextElement: () -> Element) {
        self.init(ArraySlice([Element](unsafeUninitializedCapacity: count) { buffer, initializedCount in
            for i in 0 ..< count {
                buffer.initializeElement(at: i, to: nextElement())
            }
            initializedCount = count
        }))
    }
}

extension Repeated: DifferentiableCollection where Element: Differentiable {}

extension Repeated.DifferentiableView: DifferentiableCollectionTangentVector where Element: AdditiveArithmetic {
    /// `Repeated` collapses to a single repeated value, so it sums the consumed elements into one
    /// accumulator and builds the `Repeated` object once.
    @inlinable
    public init(count: Int, nextElement: () -> Element) {
        var value: Element = .zero
        for _ in 0 ..< count {
            value += nextElement()
        }
        self.init(base: repeatElement(value, count: count))
    }
}

//// TODO: Blocked by tuples not conforming to AdditiveArithmetic
//// This would allow nested calls of differentiable Zip
// extension Zip2SequenceDifferentiable.TangentVector: DifferentiableSequence where
//    Sequence1: DifferentiableSequence,
//    Sequence2: DifferentiableSequence,
//    Sequence1.TangentVector.Element: AdditiveArithmetic,
//    Sequence2.TangentVector.Element: AdditiveArithmetic
// {}
//
// extension Zip2SequenceDifferentiable.TangentVector: DifferentiableSequenceTangentVector where
//    Sequence1: DifferentiableSequence,
//    Sequence2: DifferentiableSequence
// {}
