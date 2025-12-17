#if canImport(_Differentiation)

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
}

extension Array: DifferentiableCollection where Element: Differentiable & AdditiveArithmetic { }

extension Array.DifferentiableView: DifferentiableCollection where Element: AdditiveArithmetic { }

extension Array.DifferentiableView: DifferentiableCollectionTangentVector where Element: AdditiveArithmetic { }

extension Repeated: DifferentiableCollection where Element: Differentiable & AdditiveArithmetic { }

extension Repeated.DifferentiableView: DifferentiableCollection where Element: AdditiveArithmetic { }

extension Repeated.DifferentiableView: DifferentiableCollectionTangentVector where Element: AdditiveArithmetic { }

public protocol DifferentiableSequence: Differentiable & Sequence where
    Element: Differentiable & AdditiveArithmetic,
    TangentVector: DifferentiableSequenceTangentVector,
    TangentVector.Element == Element.TangentVector,
    TangentVector.TangentVector == TangentVector
{
    associatedtype Element
    associatedtype TangentVector
}

public protocol DifferentiableSequenceTangentVector: DifferentiableSequence {
    init()
    mutating func reserveCapacity(_ capacity: Int)
    mutating func appendContribution(of value: Element)
}

extension Array: DifferentiableSequence where Element: Differentiable & AdditiveArithmetic {}

extension Array.DifferentiableView: DifferentiableSequence where Element: AdditiveArithmetic {}

extension Array.DifferentiableView: DifferentiableSequenceTangentVector where Element: AdditiveArithmetic {
    public mutating func appendContribution(of value: Element) {
        self.append(value)
    }
}

extension Repeated: DifferentiableSequence where Element: Differentiable & AdditiveArithmetic {}

extension Repeated.DifferentiableView: DifferentiableSequence where Element: AdditiveArithmetic {}

extension Repeated.DifferentiableView: DifferentiableSequenceTangentVector where Element: AdditiveArithmetic {
    public init() { self = .zero }
    public func reserveCapacity(_: Int) {}
    public mutating func appendContribution(of value: Element) {
        let newValue = self.base.repeatedValue + value
        let newCount = self.base.count + 1
        self.base = repeatElement(newValue, count: newCount)
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

#endif
