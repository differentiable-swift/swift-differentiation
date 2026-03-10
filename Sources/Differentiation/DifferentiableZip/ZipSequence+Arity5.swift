
@inlinable
public func differentiableZip<
    C1,
    C2,
    C3,
    C4,
    C5
>(
    _ collection1: C1,
    _ collection2: C2,
    _ collection3: C3,
    _ collection4: C4,
    _ collection5: C5
) -> Zip5SequenceDifferentiable<C1, C2, C3, C4, C5> {
    Zip5SequenceDifferentiable(
        collection1,
        collection2,
        collection3,
        collection4,
        collection5
    )
}

@frozen
public struct Zip5SequenceDifferentiable<
    C1: Collection,
    C2: Collection,
    C3: Collection,
    C4: Collection,
    C5: Collection
> where
    C1.Index == Int,
    C2.Index == Int,
    C3.Index == Int,
    C4.Index == Int,
    C5.Index == Int
{
    @usableFromInline
    internal var _collection1: C1
    @usableFromInline
    internal var _collection2: C2
    @usableFromInline
    internal var _collection3: C3
    @usableFromInline
    internal var _collection4: C4
    @usableFromInline
    internal var _collection5: C5
    @inlinable
    internal init(
        _ collection1: C1,
        _ collection2: C2,
        _ collection3: C3,
        _ collection4: C4,
        _ collection5: C5
    ) {
        self._collection1 = collection1
        self._collection2 = collection2
        self._collection3 = collection3
        self._collection4 = collection4
        self._collection5 = collection5
    }
}

extension Zip5SequenceDifferentiable: Collection {
    public typealias Element = (
        C1.Element,
        C2.Element,
        C3.Element,
        C4.Element,
        C5.Element
    )
    public typealias Index = Int

    @inlinable
    public var startIndex: Int { 0 }
    @inlinable
    public var endIndex: Int {
        Swift.min(
            _collection1.count,
            _collection2.count,
            _collection3.count,
            _collection4.count,
            _collection5.count
        )
    }

    @inlinable
    public subscript(index: Int) -> Element {
        (
            _collection1[index],
            _collection2[index],
            _collection3[index],
            _collection4[index],
            _collection5[index]
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

extension Zip5SequenceDifferentiable: Sendable where
    C1: Sendable,
    C2: Sendable,
    C3: Sendable,
    C4: Sendable,
    C5: Sendable
{}

// MARK: Zip5SequenceDifferentiable + Differentiable

#if canImport(_Differentiation)

@derivative(of: differentiableZip)
@inlinable
public func _vjpDifferentiableZip<C1, C2, C3, C4, C5>(
    _ collection1: C1,
    _ collection2: C2,
    _ collection3: C3,
    _ collection4: C4,
    _ collection5: C5
) -> (
    value: Zip5SequenceDifferentiable<C1, C2, C3, C4, C5>,
    pullback: (Zip5SequenceDifferentiable<C1, C2, C3, C4, C5>.TangentVector) -> (
        C1.TangentVector,
        C2.TangentVector,
        C3.TangentVector,
        C4.TangentVector,
        C5.TangentVector
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
    C2.TangentVector.Element == C2.Element.TangentVector,
    C3: Differentiable,
    C3.Element: Differentiable,
    C3.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C3.TangentVector.Index == Int,
    C3.TangentVector.Element == C3.Element.TangentVector,
    C4: Differentiable,
    C4.Element: Differentiable,
    C4.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C4.TangentVector.Index == Int,
    C4.TangentVector.Element == C4.Element.TangentVector,
    C5: Differentiable,
    C5.Element: Differentiable,
    C5.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C5.TangentVector.Index == Int,
    C5.TangentVector.Element == C5.Element.TangentVector
{
    (
        value: differentiableZip(
            collection1,
            collection2,
            collection3,
            collection4,
            collection5
        ),
        pullback: { v in
            (
                v.collection1,
                v.collection2,
                v.collection3,
                v.collection4,
                v.collection5
            )
        }
    )
}

extension Zip5SequenceDifferentiable {
    @inlinable
    public func differentiableMap<Result: Differentiable>(
        _ transform: @differentiable(reverse) (
            C1.Element,
            C2.Element,
            C3.Element,
            C4.Element,
            C5.Element
        ) -> Result
    ) -> [Result] {
        self.map(transform)
    }
}

extension Zip5SequenceDifferentiable: Differentiable where
    C1: Differentiable,
    C1.Element: Differentiable,
    C1.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C1.TangentVector.Index == Int,
    C1.TangentVector.Element == C1.Element.TangentVector,
    C2: Differentiable,
    C2.Element: Differentiable,
    C2.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C2.TangentVector.Index == Int,
    C2.TangentVector.Element == C2.Element.TangentVector,
    C3: Differentiable,
    C3.Element: Differentiable,
    C3.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C3.TangentVector.Index == Int,
    C3.TangentVector.Element == C3.Element.TangentVector,
    C4: Differentiable,
    C4.Element: Differentiable,
    C4.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C4.TangentVector.Index == Int,
    C4.TangentVector.Element == C4.Element.TangentVector,
    C5: Differentiable,
    C5.Element: Differentiable,
    C5.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C5.TangentVector.Index == Int,
    C5.TangentVector.Element == C5.Element.TangentVector
{
    @inlinable
    public mutating func move(by offset: TangentVector) {
        _collection1.move(by: offset.collection1)
        _collection2.move(by: offset.collection2)
        _collection3.move(by: offset.collection3)
        _collection4.move(by: offset.collection4)
        _collection5.move(by: offset.collection5)
    }

    @derivative(of: differentiableMap)
    @inlinable
    public func _vjpDifferentiableMap<Result: Differentiable>(
        _ transform: @differentiable(reverse) (
            C1.Element,
            C2.Element,
            C3.Element,
            C4.Element,
            C5.Element
        ) -> Result
    ) -> (value: [Result], pullback: ([Result].TangentVector) -> TangentVector) {
        var results: [Result] = []
        results.reserveCapacity(self.count)
        var pullbacks: [(Result.TangentVector) -> (
            C1.Element.TangentVector,
            C2.Element.TangentVector,
            C3.Element.TangentVector,
            C4.Element.TangentVector,
            C5.Element.TangentVector
        )] = []
        pullbacks.reserveCapacity(self.count)

        for parameters in self {
            let (value, pullback) = valueWithPullback(
                at:
                parameters.0,
                parameters.1,
                parameters.2,
                parameters.3,
                parameters.4,
                of: transform
            )
            results.append(value)
            pullbacks.append(pullback)
        }

        return (
            value: results,
            pullback: { v in
                var results1 = C1.TangentVector(repeating: .zero, count: v.count)
                var results2 = C2.TangentVector(repeating: .zero, count: v.count)
                var results3 = C3.TangentVector(repeating: .zero, count: v.count)
                var results4 = C4.TangentVector(repeating: .zero, count: v.count)
                var results5 = C5.TangentVector(repeating: .zero, count: v.count)

                var results1Index = results1.startIndex
                var results2Index = results2.startIndex
                var results3Index = results3.startIndex
                var results4Index = results4.startIndex
                var results5Index = results5.startIndex

                // thoughts should Repeated tangentvector be a collection instead of also value + count alone? Will that make things easier?
                // we can't do append on a Repeated object so we either have to generate it from a single scope or not at all

                assert(v.count == pullbacks.count)
                for (tangentElement, pullback) in zip(v, pullbacks) {
                    let (
                        result1,
                        result2,
                        result3,
                        result4,
                        result5
                    ) = pullback(tangentElement)

                    results1.writeTangentContribution(of: result1, at: results1Index)
                    results2.writeTangentContribution(of: result2, at: results2Index)
                    results3.writeTangentContribution(of: result3, at: results3Index)
                    results4.writeTangentContribution(of: result4, at: results4Index)
                    results5.writeTangentContribution(of: result5, at: results5Index)

                    results1.formIndex(after: &results1Index)
                    results2.formIndex(after: &results2Index)
                    results3.formIndex(after: &results3Index)
                    results4.formIndex(after: &results4Index)
                    results5.formIndex(after: &results5Index)
                }

                return TangentVector(
                    results1,
                    results2,
                    results3,
                    results4,
                    results5
                )
            }
        )
    }
}

extension Zip5SequenceDifferentiable {
    public struct TangentVector: Collection & Differentiable & AdditiveArithmetic where
        C1: Differentiable,
        C1.TangentVector: Collection,
        C1.TangentVector.Index == Int,
        C2: Differentiable,
        C2.TangentVector: Collection,
        C2.TangentVector.Index == Int,
        C3: Differentiable,
        C3.TangentVector: Collection,
        C3.TangentVector.Index == Int,
        C4: Differentiable,
        C4.TangentVector: Collection,
        C4.TangentVector.Index == Int,
        C5: Differentiable,
        C5.TangentVector: Collection,
        C5.TangentVector.Index == Int
    {
        public typealias TangentVector = Self
        public typealias Element = (
            C1.TangentVector.Element,
            C2.TangentVector.Element,
            C3.TangentVector.Element,
            C4.TangentVector.Element,
            C5.TangentVector.Element
        )
        public typealias Index = Int

        @inlinable
        public var startIndex: Int { 0 }
        @inlinable
        public var endIndex: Int {
            Swift.min(
                collection1.count,
                collection2.count,
                collection3.count,
                collection4.count,
                collection5.count
            )
        }

        @inlinable
        public subscript(index: Int) -> Element {
            (
                collection1[index],
                collection2[index],
                collection3[index],
                collection4[index],
                collection5[index]
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
        @usableFromInline
        var collection3: C3.TangentVector
        @usableFromInline
        var collection4: C4.TangentVector
        @usableFromInline
        var collection5: C5.TangentVector
        @inlinable
        init(
            _ collection1: C1.TangentVector,
            _ collection2: C2.TangentVector,
            _ collection3: C3.TangentVector,
            _ collection4: C4.TangentVector,
            _ collection5: C5.TangentVector
        ) {
            self.collection1 = collection1
            self.collection2 = collection2
            self.collection3 = collection3
            self.collection4 = collection4
            self.collection5 = collection5
        }
    }
}

#endif
