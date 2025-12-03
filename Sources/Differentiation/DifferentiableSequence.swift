#if canImport(_Differentiation)

import _Differentiation

public protocol DifferentiableSequence: Differentiable & Sequence where Element: Differentiable & AdditiveArithmetic, TangentVector: DifferentiableSequenceTangentVector, TangentVector.Element == Element.TangentVector, TangentVector.TangentVector == TangentVector {
    associatedtype Element
    associatedtype TangentVector
    
    
}

public protocol DifferentiableSequenceTangentVector: DifferentiableSequence {
    init()
    mutating func reserveCapacity(_ capacity: Int)
    mutating func appendContribution(of value: Element)
}

extension Array: DifferentiableSequence where Element: Differentiable & AdditiveArithmetic {
    
}

extension Array.DifferentiableView: DifferentiableSequence where Element: AdditiveArithmetic { }

extension Array.DifferentiableView: DifferentiableSequenceTangentVector where Element: AdditiveArithmetic {
    public mutating func appendContribution(of value: Element) {
        self.append(value)
    }
}

extension Repeated: DifferentiableSequence where Element: Differentiable & AdditiveArithmetic {

}

extension Repeated.DifferentiableView: DifferentiableSequence where Element: AdditiveArithmetic {
    
}

extension Repeated.DifferentiableView: DifferentiableSequenceTangentVector where Element: AdditiveArithmetic {
    public init() { self = .zero }
    public func reserveCapacity(_ capacity: Int) { }
    public mutating func appendContribution(of value: Element) {
        self.base = repeatElement(self.base.repeatedValue + value, count: self.base.count + 1)
    }
}

#endif
