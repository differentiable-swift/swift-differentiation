#if canImport(_Differentiation)

import _Differentiation

@derivative(of: zip)
@inlinable
public func _vjpZip<Sequence1, Sequence2>(
    _ sequence1: Sequence1, _ sequence2: Sequence2
) -> (
    value: Zip2Sequence<Sequence1, Sequence2>,
    pullback: (Zip2Sequence<Sequence1, Sequence2>.TangentVector) -> (Sequence1.TangentVector, Sequence2.TangentVector)
) where
    Sequence1: Differentiable & RangeReplaceableCollection,
    Sequence2: Differentiable & RangeReplaceableCollection,
    Sequence1.Element: Differentiable,
    Sequence2.Element: Differentiable,
    Sequence1.TangentVector: RangeReplaceableCollection,
    Sequence2.TangentVector: RangeReplaceableCollection,
    Sequence1.TangentVector.Element == Sequence1.Element.TangentVector,
    Sequence2.TangentVector.Element == Sequence2.Element.TangentVector
{
    (
        value: zip(sequence1, sequence2),
        pullback: { v in
            (v.sequence1, v.sequence2)
        }
    )
}

extension Zip2Sequence: @retroactive Differentiable where
    Sequence1: Differentiable & RangeReplaceableCollection,
    Sequence2: Differentiable & RangeReplaceableCollection,
    Sequence1.Element: Differentiable,
    Sequence2.Element: Differentiable,
    Sequence1.TangentVector: RangeReplaceableCollection,
    Sequence2.TangentVector: RangeReplaceableCollection,
    Sequence1.TangentVector.Element == Sequence1.Element.TangentVector,
    Sequence2.TangentVector.Element == Sequence2.Element.TangentVector
{
    @inlinable
    public mutating func move(by offset: TangentVector) {
        // TODO: inside the stdlib we might be able to do this work in place
        var result1 = Sequence1()
        var result2 = Sequence2()

        for (original, offset) in zip(self, offset) {
            var original = original

            original.0.move(by: offset.0)
            original.1.move(by: offset.1)

            result1.append(original.0)
            result2.append(original.1)
        }
        self = zip(result1, result2)
    }

    @inlinable
    public func differentiableMap<Result: Differentiable>(_ transform: @differentiable(reverse) (Sequence1.Element, Sequence2.Element)
        -> Result
    ) -> [Result] {
        self.map(transform)
    }

    @derivative(of: differentiableMap)
    @inlinable
    public func _vjpDifferentiableMap<Result: Differentiable>(_ transform: @differentiable(reverse) (Sequence1.Element, Sequence2.Element)
        -> Result
    ) -> (value: [Result], pullback: ([Result].TangentVector) -> Zip2Sequence.TangentVector) {
        var results: [Result] = []
        results.reserveCapacity(self.underestimatedCount)
        var pullbacks: [(Result.TangentVector) -> (Sequence1.Element.TangentVector, Sequence2.Element.TangentVector)] = []
        pullbacks.reserveCapacity(self.underestimatedCount)

        for pair in self {
            let (value, pullback) = valueWithPullback(at: pair.0, pair.1, of: transform)
            results.append(value)
            pullbacks.append(pullback)
        }

        return (
            value: results,
            pullback: { v in
                var results1 = Sequence1.TangentVector()
                results1.reserveCapacity(v.count)
                var results2 = Sequence2.TangentVector()
                results2.reserveCapacity(v.count)

                for (tangentElement, pullback) in zip(v, pullbacks) {
                    let (result1, result2) = pullback(tangentElement)
                    results1.append(result1)
                    results2.append(result2)
                }

                return TangentVector(results1, results2)
            }
        )
    }

    @inlinable
    public func differentiableReduce<Result: Differentiable>(
        _ initialResult: Result,
        _ nextPartialResult: @differentiable(reverse) (Result, Sequence1.Element, Sequence2.Element) -> Result
    ) -> Result {
        self.reduce(initialResult, { result, element in nextPartialResult(result, element.0, element.1) })
    }

    @derivative(of: differentiableReduce)
    @inlinable
    public func _vjpDifferentiableReduce<Result: Differentiable>(
        _ initialResult: Result,
        _ nextPartialResult: @differentiable(reverse) (Result, Sequence1.Element, Sequence2.Element) -> Result
    ) -> (
        value: Result,
        pullback: (Result.TangentVector) -> (Zip2Sequence.TangentVector, Result.TangentVector)
    ) {
        var result: Result = initialResult
        let underestimatedCount = self.underestimatedCount
        var pullbacks: [
            (Result.TangentVector) -> (Result.TangentVector, Sequence1.Element.TangentVector, Sequence2.Element.TangentVector)
        ] = []
        pullbacks.reserveCapacity(underestimatedCount)

        for (element1, element2) in self {
            let (nextPartialResult, pullback) = valueWithPullback(at: result, element1, element2, of: nextPartialResult)
            result = nextPartialResult
            pullbacks.append(pullback)
        }
        return (
            value: result,
            pullback: { v in
                var resultTangent = v
                var results1: [Sequence1.Element.TangentVector] = []
                results1.reserveCapacity(underestimatedCount)
                var results2: [Sequence2.Element.TangentVector] = []
                results2.reserveCapacity(underestimatedCount)

                for pullback in pullbacks.reversed() {
                    let (newResultTangent, sequence1Tangent, sequence2Tangent) = pullback(resultTangent)
                    resultTangent = newResultTangent
                    results1.append(sequence1Tangent)
                    results2.append(sequence2Tangent)
                }

                // TODO: eleminate the intermediate storage for the reversed results (`results1` and `results2`)
                var results1Reversed = Sequence1.TangentVector()
                results1.reserveCapacity(underestimatedCount)
                var results2Reversed = Sequence2.TangentVector()
                results2.reserveCapacity(underestimatedCount)

                for element in results1.reversed() {
                    results1Reversed.append(element)
                }

                for element in results2.reversed() {
                    results2Reversed.append(element)
                }

                return (TangentVector(results1Reversed, results2Reversed), resultTangent)
            }
        )
    }
}

extension Zip2Sequence {
    public struct TangentVector: Sequence & Differentiable & AdditiveArithmetic where Sequence1: Differentiable, Sequence2: Differentiable,
        Sequence1.TangentVector: Sequence, Sequence2.TangentVector: Sequence
    {
        public typealias TangentVector = Self
        public typealias Element = (Sequence1.TangentVector.Element, Sequence2.TangentVector.Element)

        @usableFromInline
        var sequence1: Sequence1.TangentVector
        @usableFromInline
        var sequence2: Sequence2.TangentVector

        @inlinable
        init(_ sequence1: Sequence1.TangentVector, _ sequence2: Sequence2.TangentVector) {
            self.sequence1 = sequence1
            self.sequence2 = sequence2
        }

        @inlinable
        public __consuming func makeIterator() -> Iterator {
            Iterator(baseStream1: sequence1.makeIterator(), baseStream2: sequence2.makeIterator())
        }

        @inlinable // generic-performance
        public var underestimatedCount: Int {
            Swift.min(
                sequence1.underestimatedCount,
                sequence2.underestimatedCount
            )
        }

        public struct Iterator: IteratorProtocol {
            public typealias Element = (Sequence1.TangentVector.Element, Sequence2.TangentVector.Element)

            @usableFromInline
            var baseStream1: Sequence1.TangentVector.Iterator
            @usableFromInline
            var baseStream2: Sequence2.TangentVector.Iterator
            @usableFromInline
            var reachedEnd: Bool = false

            @inlinable
            init(baseStream1: Sequence1.TangentVector.Iterator, baseStream2: Sequence2.TangentVector.Iterator) {
                self.baseStream1 = baseStream1
                self.baseStream2 = baseStream2
            }

            @inlinable
            public mutating func next() -> (Sequence1.TangentVector.Element, Sequence2.TangentVector.Element)? {
                if reachedEnd {
                    return nil
                }

                guard let element1 = baseStream1.next(),
                      let element2 = baseStream2.next() else
                {
                    reachedEnd = true
                    return nil
                }

                return (element1, element2)
            }
        }
    }
}

#endif
