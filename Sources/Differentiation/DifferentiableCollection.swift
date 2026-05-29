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
    init(repeating value: Element, count: Int)
    mutating func writeTangentContribution(of value: Element, at index: Index)
}

extension Array: DifferentiableCollection where Element: Differentiable & AdditiveArithmetic {}

extension Array.DifferentiableView: DifferentiableCollection where Element: AdditiveArithmetic {}

extension Array.DifferentiableView: DifferentiableCollectionTangentVector where Element: AdditiveArithmetic {
    @inlinable
    public mutating func writeTangentContribution(of value: Element, at index: Index) {
        self[index] += value
    }
}

extension ContiguousArray: DifferentiableCollection where Element: Differentiable & AdditiveArithmetic {}

extension ContiguousArray.DifferentiableView: DifferentiableCollection where Element: AdditiveArithmetic {}

extension ContiguousArray.DifferentiableView: DifferentiableCollectionTangentVector where Element: AdditiveArithmetic {
    public mutating func appendContribution(of value: Element) {
        self.append(value)
    }
}

extension ArraySlice: DifferentiableCollection where Element: Differentiable & AdditiveArithmetic {}

extension ArraySlice.DifferentiableView: DifferentiableCollection where Element: AdditiveArithmetic {}

extension ArraySlice.DifferentiableView: DifferentiableCollectionTangentVector where Element: AdditiveArithmetic {
    public mutating func appendContribution(of value: Element) {
        self.append(value)
    }
}

extension Repeated: DifferentiableCollection where Element: Differentiable & AdditiveArithmetic {}

extension Repeated.DifferentiableView: DifferentiableCollection where Element: AdditiveArithmetic {}

extension Repeated.DifferentiableView: DifferentiableCollectionTangentVector where Element: AdditiveArithmetic {
    @inlinable
    public init(repeating value: Element, count: Int) {
        self = .init(base: repeatElement(value, count: count))
    }

    @inlinable
    public mutating func writeTangentContribution(of value: Repeated<Element>.Element, at _: Repeated<Element>.Index) {
        let newValue = self.base.repeatedValue + value
        self.base = repeatElement(newValue, count: self.count)
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
