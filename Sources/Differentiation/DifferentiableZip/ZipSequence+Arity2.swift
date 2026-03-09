
@inlinable
public func differentiableZip<
    C1,
    C2
>(
    _ collection1: C1,
    _ collection2: C2
) -> Zip2SequenceDifferentiable<C1, C2> {
    Zip2SequenceDifferentiable(
        collection1,
        collection2
    )
}

@frozen
public struct Zip2SequenceDifferentiable<
    C1: Collection,
    C2: Collection
> where
    C1.Index == Int,
    C2.Index == Int
{
    @usableFromInline
    internal var _collection1: C1
    @usableFromInline
    internal var _collection2: C2
    @inlinable
    internal init(
        _ collection1: C1,
        _ collection2: C2
    ) {
        self._collection1 = collection1
        self._collection2 = collection2
    }
}

extension Zip2SequenceDifferentiable: Collection {
    public typealias Element = (
        C1.Element,
        C2.Element
    )
    public typealias Index = Int

    @inlinable
    public var startIndex: Int { 0 }
    @inlinable
    public var endIndex: Int {
        Swift.min(
            _collection1.count,
            _collection2.count
        )
    }

    @inlinable
    public subscript(index: Int) -> Element {
        (
            _collection1[_collection1.startIndex.advanced(by: index)],
            _collection2[_collection2.startIndex.advanced(by: index)]
        )
    }

    @inlinable
    public func index(after i: Int) -> Int {
        i + 1
    }

    @inlinable
    public func formIndex(after i: inout Int) {
        i += 1
    }
}

extension Zip2SequenceDifferentiable: Sendable where
    C1: Sendable,
    C2: Sendable
{}

// MARK: Zip2SequenceDifferentiable + Differentiable

#if canImport(_Differentiation)

@derivative(of: differentiableZip)
@inlinable
public func _vjpDifferentiableZip<C1, C2>(
    _ collection1: C1,
    _ collection2: C2
) -> (
    value: Zip2SequenceDifferentiable<C1, C2>,
    pullback: (Zip2SequenceDifferentiable<C1, C2>.TangentVector) -> (
        C1.TangentVector,
        C2.TangentVector
    )
) where
    C1: Differentiable,
    C1.Element: Differentiable,
    C1.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C1.TangentVector.Index == Int,
    C1.TangentVector.Element == C1.Element.TangentVector,
    C2: Differentiable,
    C2.Element: Differentiable,
    C2.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C2.TangentVector.Index == Int,
    C2.TangentVector.Element == C2.Element.TangentVector
{
    (
        value: differentiableZip(
            collection1,
            collection2
        ),
        pullback: { v in
            (
                v.collection1,
                v.collection2
            )
        }
    )
}

extension Zip2SequenceDifferentiable {
    @inlinable
    public func differentiableMap<Result: Differentiable>(
        _ transform: @differentiable(reverse) (
            C1.Element,
            C2.Element
        ) -> Result
    ) -> [Result] {
        self.map(transform)
    }
}

extension Zip2SequenceDifferentiable: Differentiable where
    C1: Differentiable,
    C1.Element: Differentiable,
    C1.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C1.TangentVector.Index == Int,
    C1.TangentVector.Element == C1.Element.TangentVector,
    C2: Differentiable,
    C2.Element: Differentiable,
    C2.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C2.TangentVector.Index == Int,
    C2.TangentVector.Element == C2.Element.TangentVector
{
    @inlinable
    public mutating func move(by offset: TangentVector) {
        _collection1.move(by: offset.collection1)
        _collection2.move(by: offset.collection2)
    }

    @derivative(of: differentiableMap)
    @inlinable
    public func _vjpDifferentiableMap<Result: Differentiable>(
        _ transform: @differentiable(reverse) (
            C1.Element,
            C2.Element
        ) -> Result
    ) -> (value: [Result], pullback: ([Result].TangentVector) -> TangentVector) {
        var results: [Result] = []
        results.reserveCapacity(self.count)
        var pullbacks: [(Result.TangentVector) -> (
            C1.Element.TangentVector,
            C2.Element.TangentVector
        )] = []
        pullbacks.reserveCapacity(self.count)

        for parameters in self {
            let (value, pullback) = valueWithPullback(
                at:
                parameters.0,
                parameters.1,
                of: transform
            )
            results.append(value)
            pullbacks.append(pullback)
        }

        return (
            value: results,
            pullback: { v in
                var results1 = C1.TangentVector()
                var results2 = C2.TangentVector()

                results1.reserveCapacity(v.count)
                results2.reserveCapacity(v.count)

                // thoughts should Repeated tangentvector be a collection instead of also value + count alone? Will that make things easier?
                // we can't do append on a Repeated object so we either have to generate it from a single scope or not at all

                assert(v.count == pullbacks.count)
                for (tangentElement, pullback) in zip(v, pullbacks) {
                    let (
                        result1,
                        result2
                    ) = pullback(tangentElement)

                    results1.appendContribution(of: result1)
                    results2.appendContribution(of: result2)
                }

                return TangentVector(
                    results1,
                    results2
                )
            }
        )
    }
}

extension Zip2SequenceDifferentiable {
    public struct TangentVector: Collection & Differentiable & AdditiveArithmetic where
        C1: Differentiable,
        C1.TangentVector: Collection,
        C1.TangentVector.Index == Int,
        C2: Differentiable,
        C2.TangentVector: Collection,
        C2.TangentVector.Index == Int
    {
        public typealias TangentVector = Self
        public typealias Element = (
            C1.TangentVector.Element,
            C2.TangentVector.Element
        )
        public typealias Index = Int

        @inlinable
        public var startIndex: Int { 0 }
        @inlinable
        public var endIndex: Int {
            Swift.min(
                collection1.count,
                collection2.count
            )
        }

        @inlinable
        public subscript(index: Int) -> Element {
            (
                collection1[index],
                collection2[index]
            )
        }

        @inlinable
        public func index(after i: Int) -> Int {
            i + 1
        }

        @inlinable
        public func formIndex(after i: inout Int) {
            i += 1
        }

        @usableFromInline
        var collection1: C1.TangentVector
        @usableFromInline
        var collection2: C2.TangentVector
        @inlinable
        init(
            _ collection1: C1.TangentVector,
            _ collection2: C2.TangentVector
        ) {
            self.collection1 = collection1
            self.collection2 = collection2
        }
    }
}

#endif
