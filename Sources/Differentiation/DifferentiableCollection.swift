import _Differentiation

public protocol DifferentiableCollection: Differentiable & Collection where
    Element: Differentiable,
    TangentVector: DifferentiableCollectionTangentVector,
    TangentVector.Element == Element.TangentVector
{
    associatedtype Element
    associatedtype TangentVector
}

public protocol DifferentiableCollectionTangentVector: DifferentiableCollection {
    init()
    mutating func reserveCapacity(_ capacity: Int)
    mutating func appendContribution(of value: Element)
    init(count: Int, nextElement: () -> Element)
}

extension Array: DifferentiableCollection where Element: Differentiable & AdditiveArithmetic {}

extension Array.DifferentiableView: DifferentiableCollection where Element: AdditiveArithmetic {}

extension Array.DifferentiableView: DifferentiableCollectionTangentVector where Element: AdditiveArithmetic {
    @inlinable
    public mutating func appendContribution(of value: Element) {
        self.append(value)
    }

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

extension ContiguousArray: DifferentiableCollection where Element: Differentiable & AdditiveArithmetic {}

extension ContiguousArray.DifferentiableView: DifferentiableCollection where Element: AdditiveArithmetic {}

extension ContiguousArray.DifferentiableView: DifferentiableCollectionTangentVector where Element: AdditiveArithmetic {
    @inlinable
    public mutating func appendContribution(of value: Element) {
        self.append(value)
    }

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

extension ArraySlice: DifferentiableCollection where Element: Differentiable & AdditiveArithmetic {}

extension ArraySlice.DifferentiableView: DifferentiableCollection where Element: AdditiveArithmetic {}

extension ArraySlice.DifferentiableView: DifferentiableCollectionTangentVector where Element: AdditiveArithmetic {
    @inlinable
    public mutating func appendContribution(of value: Element) {
        self.append(value)
    }

    @inlinable
    public init(count: Int, nextElement: () -> Element) {
        self.init(ArraySlice(Array<Element>(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            for i in 0 ..< count {
                buffer.initializeElement(at: i, to: nextElement())
            }
            initializedCount = count
        }))
    }
}

extension Repeated: DifferentiableCollection where Element: Differentiable & AdditiveArithmetic {}

extension Repeated.DifferentiableView: DifferentiableCollection where Element: AdditiveArithmetic {}

extension Repeated.DifferentiableView: DifferentiableCollectionTangentVector where Element: AdditiveArithmetic {
    @inlinable
    public init() { self = .zero }

    @inlinable
    public mutating func reserveCapacity(_: Int) { /* no-op */ }

    @inlinable
    public mutating func appendContribution(of value: Repeated<Element>.Element) {
        let newValue = self.base.repeatedValue + value
        let newCount = self.base.count + 1
        self.base = repeatElement(newValue, count: newCount)
    }

    @inlinable
    public init(count: Int, nextElement: () -> Element) {
        var value: Element = .zero
        for _ in 0 ..< count {
            value += nextElement()
        }
        self.init(base: repeatElement(value, count: count))
    }
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
// {
//    public init() {
//        self.sequence1 = .init()
//        self.sequence2 = .init()
//    }
//
//    public mutating func reserveCapacity(_ capacity: Int) {
//        sequence1.reserveCapacity(capacity)
//        sequence2.reserveCapacity(capacity)
//    }
//
//    public mutating func appendContribution(of value: (Sequence1.TangentVector.Element, Sequence2.TangentVector.Element)) {
//        fatalError("Incomplete")
//    }
// }
