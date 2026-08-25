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
    /// Build a dense tangent of `count` elements, where element `i` is `element(i)`.
    ///
    /// The fast path for constructing a tangent in a pullback: the conformer owns the loop, so
    /// contiguous types fill their storage directly while non-contiguous types (e.g. `Repeated`)
    /// fold the elements in without allocating any intermediate storage.
    /// There is no default implementation, so a new conformer that forgets this gets a compile error
    /// rather than silently falling back to a slow path.
    ///
    /// - Important: This is a **conformance requirement**, not merely a convention. A conformer
    ///   MUST invoke `element` exactly once for every index in `0 ..< count`, in strictly increasing
    ///   order (`0, 1, …, count - 1`), and MUST NOT call it for any other index or more than once.
    ///   Callers rely on this for memory safety: it lets them walk a companion collection in lockstep
    ///   with a running index (instead of a random-access `index(_:offsetBy:)` per element), and it
    ///   lets them stage values into raw scratch storage that is `initialize`d on one pass and
    ///   `move`d out on another. A conformer that skipped, repeated, or reordered indices would turn
    ///   such call sites into use-of-uninitialized-memory or double-move — undefined behavior.
    init(count: Int, _ element: (Int) -> Element)
}

extension Array: DifferentiableCollection where Element: Differentiable {}

extension Array.DifferentiableView: DifferentiableCollectionTangentVector {
    @inlinable
    public init(count: Int, _ element: (Int) -> Element) {
        self.init([Element](unsafeUninitializedCapacity: count) { buffer, initializedCount in
            for i in 0 ..< count {
                buffer.initializeElement(at: i, to: element(i))
            }
            initializedCount = count
        })
    }
}

extension ContiguousArray: DifferentiableCollection where Element: Differentiable {}

extension ContiguousArray.DifferentiableView: DifferentiableCollectionTangentVector {
    @inlinable
    public init(count: Int, _ element: (Int) -> Element) {
        self.init(ContiguousArray<Element>(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            for i in 0 ..< count {
                buffer.initializeElement(at: i, to: element(i))
            }
            initializedCount = count
        })
    }
}

extension ArraySlice: DifferentiableCollection where Element: Differentiable {}

extension ArraySlice.DifferentiableView: DifferentiableCollectionTangentVector {
    @inlinable
    public init(count: Int, _ element: (Int) -> Element) {
        self.init(ArraySlice([Element](unsafeUninitializedCapacity: count) { buffer, initializedCount in
            for i in 0 ..< count {
                buffer.initializeElement(at: i, to: element(i))
            }
            initializedCount = count
        }))
    }
}

extension Repeated: DifferentiableCollection where Element: Differentiable {}

extension Repeated.DifferentiableView: DifferentiableCollectionTangentVector where Element: AdditiveArithmetic {
    /// `Repeated` collapses to a single repeated value, so it sums the pulled elements into one
    /// accumulator and builds the `Repeated` object once.
    @inlinable
    public init(count: Int, _ element: (Int) -> Element) {
        var value: Element = .zero
        for i in 0 ..< count {
            value += element(i)
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
