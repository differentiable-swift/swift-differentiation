
@inlinable
public func differentiableZip<
    C1,
    C2,
    C3,
    C4,
    C5,
    C6,
    C7,
    C8
>(
    _ collection1: C1,
    _ collection2: C2,
    _ collection3: C3,
    _ collection4: C4,
    _ collection5: C5,
    _ collection6: C6,
    _ collection7: C7,
    _ collection8: C8
) -> Zip8SequenceDifferentiable<C1, C2, C3, C4, C5, C6, C7, C8> {
    Zip8SequenceDifferentiable(
        collection1,
        collection2,
        collection3,
        collection4,
        collection5,
        collection6,
        collection7,
        collection8
    )
}

@frozen
public struct Zip8SequenceDifferentiable<
    C1: Collection,
    C2: Collection,
    C3: Collection,
    C4: Collection,
    C5: Collection,
    C6: Collection,
    C7: Collection,
    C8: Collection
> where
    C1.Index == Int,
    C2.Index == Int,
    C3.Index == Int,
    C4.Index == Int,
    C5.Index == Int,
    C6.Index == Int,
    C7.Index == Int,
    C8.Index == Int
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
    @usableFromInline
    internal var _collection6: C6
    @usableFromInline
    internal var _collection7: C7
    @usableFromInline
    internal var _collection8: C8
    @inlinable
    internal init(
        _ collection1: C1,
        _ collection2: C2,
        _ collection3: C3,
        _ collection4: C4,
        _ collection5: C5,
        _ collection6: C6,
        _ collection7: C7,
        _ collection8: C8
    ) {
        self._collection1 = collection1
        self._collection2 = collection2
        self._collection3 = collection3
        self._collection4 = collection4
        self._collection5 = collection5
        self._collection6 = collection6
        self._collection7 = collection7
        self._collection8 = collection8
    }
}

extension Zip8SequenceDifferentiable: Collection {
    public typealias Element = (
        C1.Element,
        C2.Element,
        C3.Element,
        C4.Element,
        C5.Element,
        C6.Element,
        C7.Element,
        C8.Element
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
            _collection5.count,
            _collection6.count,
            _collection7.count,
            _collection8.count
        )
    }

    @inlinable
    public subscript(index: Int) -> Element {
        (
            _collection1[_collection1.startIndex.advanced(by: index)],
            _collection2[_collection2.startIndex.advanced(by: index)],
            _collection3[_collection3.startIndex.advanced(by: index)],
            _collection4[_collection4.startIndex.advanced(by: index)],
            _collection5[_collection5.startIndex.advanced(by: index)],
            _collection6[_collection6.startIndex.advanced(by: index)],
            _collection7[_collection7.startIndex.advanced(by: index)],
            _collection8[_collection8.startIndex.advanced(by: index)]
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

extension Zip8SequenceDifferentiable: Sendable where
    C1: Sendable,
    C2: Sendable,
    C3: Sendable,
    C4: Sendable,
    C5: Sendable,
    C6: Sendable,
    C7: Sendable,
    C8: Sendable
{}

// MARK: Zip8SequenceDifferentiable + Differentiable

#if canImport(_Differentiation)

@derivative(of: differentiableZip)
@inlinable
public func _vjpDifferentiableZip<C1, C2, C3, C4, C5, C6, C7, C8>(
    _ collection1: C1,
    _ collection2: C2,
    _ collection3: C3,
    _ collection4: C4,
    _ collection5: C5,
    _ collection6: C6,
    _ collection7: C7,
    _ collection8: C8
) -> (
    value: Zip8SequenceDifferentiable<C1, C2, C3, C4, C5, C6, C7, C8>,
    pullback: (Zip8SequenceDifferentiable<C1, C2, C3, C4, C5, C6, C7, C8>.TangentVector) -> (
        C1.TangentVector,
        C2.TangentVector,
        C3.TangentVector,
        C4.TangentVector,
        C5.TangentVector,
        C6.TangentVector,
        C7.TangentVector,
        C8.TangentVector
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
    C5.TangentVector.Element == C5.Element.TangentVector,
    C6: Differentiable,
    C6.Element: Differentiable,
    C6.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C6.TangentVector.Index == Int,
    C6.TangentVector.Element == C6.Element.TangentVector,
    C7: Differentiable,
    C7.Element: Differentiable,
    C7.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C7.TangentVector.Index == Int,
    C7.TangentVector.Element == C7.Element.TangentVector,
    C8: Differentiable,
    C8.Element: Differentiable,
    C8.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C8.TangentVector.Index == Int,
    C8.TangentVector.Element == C8.Element.TangentVector
{
    (
        value: differentiableZip(
            collection1,
            collection2,
            collection3,
            collection4,
            collection5,
            collection6,
            collection7,
            collection8
        ),
        pullback: { v in
            (
                v.collection1,
                v.collection2,
                v.collection3,
                v.collection4,
                v.collection5,
                v.collection6,
                v.collection7,
                v.collection8
            )
        }
    )
}

extension Zip8SequenceDifferentiable {
    @inlinable
    public func differentiableMap<Result: Differentiable>(
        _ transform: @differentiable(reverse) (
            C1.Element,
            C2.Element,
            C3.Element,
            C4.Element,
            C5.Element,
            C6.Element,
            C7.Element,
            C8.Element
        ) -> Result
    ) -> [Result] {
        self.map(transform)
    }
}

extension Zip8SequenceDifferentiable: Differentiable where
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
    C5.TangentVector.Element == C5.Element.TangentVector,
    C6: Differentiable,
    C6.Element: Differentiable,
    C6.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C6.TangentVector.Index == Int,
    C6.TangentVector.Element == C6.Element.TangentVector,
    C7: Differentiable,
    C7.Element: Differentiable,
    C7.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C7.TangentVector.Index == Int,
    C7.TangentVector.Element == C7.Element.TangentVector,
    C8: Differentiable,
    C8.Element: Differentiable,
    C8.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C8.TangentVector.Index == Int,
    C8.TangentVector.Element == C8.Element.TangentVector
{
    @inlinable
    public mutating func move(by offset: TangentVector) {
        _collection1.move(by: offset.collection1)
        _collection2.move(by: offset.collection2)
        _collection3.move(by: offset.collection3)
        _collection4.move(by: offset.collection4)
        _collection5.move(by: offset.collection5)
        _collection6.move(by: offset.collection6)
        _collection7.move(by: offset.collection7)
        _collection8.move(by: offset.collection8)
    }

    @derivative(of: differentiableMap)
    @inlinable
    public func _vjpDifferentiableMap<Result: Differentiable>(
        _ transform: @differentiable(reverse) (
            C1.Element,
            C2.Element,
            C3.Element,
            C4.Element,
            C5.Element,
            C6.Element,
            C7.Element,
            C8.Element
        ) -> Result
    ) -> (value: [Result], pullback: ([Result].TangentVector) -> TangentVector) {
        var results: [Result] = []
        results.reserveCapacity(self.count)
        var pullbacks: [(Result.TangentVector) -> (
            C1.Element.TangentVector,
            C2.Element.TangentVector,
            C3.Element.TangentVector,
            C4.Element.TangentVector,
            C5.Element.TangentVector,
            C6.Element.TangentVector,
            C7.Element.TangentVector,
            C8.Element.TangentVector
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
                parameters.5,
                parameters.6,
                parameters.7,
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
                var results3 = C3.TangentVector()
                var results4 = C4.TangentVector()
                var results5 = C5.TangentVector()
                var results6 = C6.TangentVector()
                var results7 = C7.TangentVector()
                var results8 = C8.TangentVector()

                results1.reserveCapacity(v.count)
                results2.reserveCapacity(v.count)
                results3.reserveCapacity(v.count)
                results4.reserveCapacity(v.count)
                results5.reserveCapacity(v.count)
                results6.reserveCapacity(v.count)
                results7.reserveCapacity(v.count)
                results8.reserveCapacity(v.count)

                // thoughts should Repeated tangentvector be a collection instead of also value + count alone? Will that make things easier?
                // we can't do append on a Repeated object so we either have to generate it from a single scope or not at all

                assert(v.count == pullbacks.count)
                for (tangentElement, pullback) in zip(v, pullbacks) {
                    let (
                        result1,
                        result2,
                        result3,
                        result4,
                        result5,
                        result6,
                        result7,
                        result8
                    ) = pullback(tangentElement)

                    results1.appendContribution(of: result1)
                    results2.appendContribution(of: result2)
                    results3.appendContribution(of: result3)
                    results4.appendContribution(of: result4)
                    results5.appendContribution(of: result5)
                    results6.appendContribution(of: result6)
                    results7.appendContribution(of: result7)
                    results8.appendContribution(of: result8)
                }

                return TangentVector(
                    results1,
                    results2,
                    results3,
                    results4,
                    results5,
                    results6,
                    results7,
                    results8
                )
            }
        )
    }
}

extension Zip8SequenceDifferentiable {
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
        C5.TangentVector.Index == Int,
        C6: Differentiable,
        C6.TangentVector: Collection,
        C6.TangentVector.Index == Int,
        C7: Differentiable,
        C7.TangentVector: Collection,
        C7.TangentVector.Index == Int,
        C8: Differentiable,
        C8.TangentVector: Collection,
        C8.TangentVector.Index == Int
    {
        public typealias TangentVector = Self
        public typealias Element = (
            C1.TangentVector.Element,
            C2.TangentVector.Element,
            C3.TangentVector.Element,
            C4.TangentVector.Element,
            C5.TangentVector.Element,
            C6.TangentVector.Element,
            C7.TangentVector.Element,
            C8.TangentVector.Element
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
                collection5.count,
                collection6.count,
                collection7.count,
                collection8.count
            )
        }

        @inlinable
        public subscript(index: Int) -> Element {
            (
                collection1[index],
                collection2[index],
                collection3[index],
                collection4[index],
                collection5[index],
                collection6[index],
                collection7[index],
                collection8[index]
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
        @usableFromInline
        var collection6: C6.TangentVector
        @usableFromInline
        var collection7: C7.TangentVector
        @usableFromInline
        var collection8: C8.TangentVector
        @inlinable
        init(
            _ collection1: C1.TangentVector,
            _ collection2: C2.TangentVector,
            _ collection3: C3.TangentVector,
            _ collection4: C4.TangentVector,
            _ collection5: C5.TangentVector,
            _ collection6: C6.TangentVector,
            _ collection7: C7.TangentVector,
            _ collection8: C8.TangentVector
        ) {
            self.collection1 = collection1
            self.collection2 = collection2
            self.collection3 = collection3
            self.collection4 = collection4
            self.collection5 = collection5
            self.collection6 = collection6
            self.collection7 = collection7
            self.collection8 = collection8
        }
    }
}

#endif
