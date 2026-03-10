
@inlinable
public func differentiableZip<
    C1,
    C2,
    C3,
    C4,
    C5,
    C6,
    C7,
    C8,
    C9,
    C10,
    C11,
    C12,
    C13,
    C14
>(
    _ collection1: C1,
    _ collection2: C2,
    _ collection3: C3,
    _ collection4: C4,
    _ collection5: C5,
    _ collection6: C6,
    _ collection7: C7,
    _ collection8: C8,
    _ collection9: C9,
    _ collection10: C10,
    _ collection11: C11,
    _ collection12: C12,
    _ collection13: C13,
    _ collection14: C14
) -> Zip14SequenceDifferentiable<C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14> {
    Zip14SequenceDifferentiable(
        collection1,
        collection2,
        collection3,
        collection4,
        collection5,
        collection6,
        collection7,
        collection8,
        collection9,
        collection10,
        collection11,
        collection12,
        collection13,
        collection14
    )
}

@frozen
public struct Zip14SequenceDifferentiable<
    C1: Collection,
    C2: Collection,
    C3: Collection,
    C4: Collection,
    C5: Collection,
    C6: Collection,
    C7: Collection,
    C8: Collection,
    C9: Collection,
    C10: Collection,
    C11: Collection,
    C12: Collection,
    C13: Collection,
    C14: Collection
> where
    C1.Index == Int,
    C2.Index == Int,
    C3.Index == Int,
    C4.Index == Int,
    C5.Index == Int,
    C6.Index == Int,
    C7.Index == Int,
    C8.Index == Int,
    C9.Index == Int,
    C10.Index == Int,
    C11.Index == Int,
    C12.Index == Int,
    C13.Index == Int,
    C14.Index == Int
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
    @usableFromInline
    internal var _collection9: C9
    @usableFromInline
    internal var _collection10: C10
    @usableFromInline
    internal var _collection11: C11
    @usableFromInline
    internal var _collection12: C12
    @usableFromInline
    internal var _collection13: C13
    @usableFromInline
    internal var _collection14: C14
    @inlinable
    internal init(
        _ collection1: C1,
        _ collection2: C2,
        _ collection3: C3,
        _ collection4: C4,
        _ collection5: C5,
        _ collection6: C6,
        _ collection7: C7,
        _ collection8: C8,
        _ collection9: C9,
        _ collection10: C10,
        _ collection11: C11,
        _ collection12: C12,
        _ collection13: C13,
        _ collection14: C14
    ) {
        self._collection1 = collection1
        self._collection2 = collection2
        self._collection3 = collection3
        self._collection4 = collection4
        self._collection5 = collection5
        self._collection6 = collection6
        self._collection7 = collection7
        self._collection8 = collection8
        self._collection9 = collection9
        self._collection10 = collection10
        self._collection11 = collection11
        self._collection12 = collection12
        self._collection13 = collection13
        self._collection14 = collection14
    }
}

extension Zip14SequenceDifferentiable: Collection {
    public typealias Element = (
        C1.Element,
        C2.Element,
        C3.Element,
        C4.Element,
        C5.Element,
        C6.Element,
        C7.Element,
        C8.Element,
        C9.Element,
        C10.Element,
        C11.Element,
        C12.Element,
        C13.Element,
        C14.Element
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
            _collection8.count,
            _collection9.count,
            _collection10.count,
            _collection11.count,
            _collection12.count,
            _collection13.count,
            _collection14.count
        )
    }

    @inlinable
    public subscript(index: Int) -> Element {
        (
            _collection1[index],
            _collection2[index],
            _collection3[index],
            _collection4[index],
            _collection5[index],
            _collection6[index],
            _collection7[index],
            _collection8[index],
            _collection9[index],
            _collection10[index],
            _collection11[index],
            _collection12[index],
            _collection13[index],
            _collection14[index]
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

extension Zip14SequenceDifferentiable: Sendable where
    C1: Sendable,
    C2: Sendable,
    C3: Sendable,
    C4: Sendable,
    C5: Sendable,
    C6: Sendable,
    C7: Sendable,
    C8: Sendable,
    C9: Sendable,
    C10: Sendable,
    C11: Sendable,
    C12: Sendable,
    C13: Sendable,
    C14: Sendable
{}

// MARK: Zip14SequenceDifferentiable + Differentiable

#if canImport(_Differentiation)

@derivative(of: differentiableZip)
@inlinable
public func _vjpDifferentiableZip<C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14>(
    _ collection1: C1,
    _ collection2: C2,
    _ collection3: C3,
    _ collection4: C4,
    _ collection5: C5,
    _ collection6: C6,
    _ collection7: C7,
    _ collection8: C8,
    _ collection9: C9,
    _ collection10: C10,
    _ collection11: C11,
    _ collection12: C12,
    _ collection13: C13,
    _ collection14: C14
) -> (
    value: Zip14SequenceDifferentiable<C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14>,
    pullback: (Zip14SequenceDifferentiable<C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14>.TangentVector) -> (
        C1.TangentVector,
        C2.TangentVector,
        C3.TangentVector,
        C4.TangentVector,
        C5.TangentVector,
        C6.TangentVector,
        C7.TangentVector,
        C8.TangentVector,
        C9.TangentVector,
        C10.TangentVector,
        C11.TangentVector,
        C12.TangentVector,
        C13.TangentVector,
        C14.TangentVector
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
    C8.TangentVector.Element == C8.Element.TangentVector,
    C9: Differentiable,
    C9.Element: Differentiable,
    C9.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C9.TangentVector.Index == Int,
    C9.TangentVector.Element == C9.Element.TangentVector,
    C10: Differentiable,
    C10.Element: Differentiable,
    C10.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C10.TangentVector.Index == Int,
    C10.TangentVector.Element == C10.Element.TangentVector,
    C11: Differentiable,
    C11.Element: Differentiable,
    C11.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C11.TangentVector.Index == Int,
    C11.TangentVector.Element == C11.Element.TangentVector,
    C12: Differentiable,
    C12.Element: Differentiable,
    C12.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C12.TangentVector.Index == Int,
    C12.TangentVector.Element == C12.Element.TangentVector,
    C13: Differentiable,
    C13.Element: Differentiable,
    C13.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C13.TangentVector.Index == Int,
    C13.TangentVector.Element == C13.Element.TangentVector,
    C14: Differentiable,
    C14.Element: Differentiable,
    C14.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C14.TangentVector.Index == Int,
    C14.TangentVector.Element == C14.Element.TangentVector
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
            collection8,
            collection9,
            collection10,
            collection11,
            collection12,
            collection13,
            collection14
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
                v.collection8,
                v.collection9,
                v.collection10,
                v.collection11,
                v.collection12,
                v.collection13,
                v.collection14
            )
        }
    )
}

extension Zip14SequenceDifferentiable {
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
            C8.Element,
            C9.Element,
            C10.Element,
            C11.Element,
            C12.Element,
            C13.Element,
            C14.Element
        ) -> Result
    ) -> [Result] {
        self.map(transform)
    }
}

extension Zip14SequenceDifferentiable: Differentiable where
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
    C8.TangentVector.Element == C8.Element.TangentVector,
    C9: Differentiable,
    C9.Element: Differentiable,
    C9.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C9.TangentVector.Index == Int,
    C9.TangentVector.Element == C9.Element.TangentVector,
    C10: Differentiable,
    C10.Element: Differentiable,
    C10.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C10.TangentVector.Index == Int,
    C10.TangentVector.Element == C10.Element.TangentVector,
    C11: Differentiable,
    C11.Element: Differentiable,
    C11.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C11.TangentVector.Index == Int,
    C11.TangentVector.Element == C11.Element.TangentVector,
    C12: Differentiable,
    C12.Element: Differentiable,
    C12.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C12.TangentVector.Index == Int,
    C12.TangentVector.Element == C12.Element.TangentVector,
    C13: Differentiable,
    C13.Element: Differentiable,
    C13.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C13.TangentVector.Index == Int,
    C13.TangentVector.Element == C13.Element.TangentVector,
    C14: Differentiable,
    C14.Element: Differentiable,
    C14.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
    C14.TangentVector.Index == Int,
    C14.TangentVector.Element == C14.Element.TangentVector
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
        _collection9.move(by: offset.collection9)
        _collection10.move(by: offset.collection10)
        _collection11.move(by: offset.collection11)
        _collection12.move(by: offset.collection12)
        _collection13.move(by: offset.collection13)
        _collection14.move(by: offset.collection14)
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
            C8.Element,
            C9.Element,
            C10.Element,
            C11.Element,
            C12.Element,
            C13.Element,
            C14.Element
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
            C8.Element.TangentVector,
            C9.Element.TangentVector,
            C10.Element.TangentVector,
            C11.Element.TangentVector,
            C12.Element.TangentVector,
            C13.Element.TangentVector,
            C14.Element.TangentVector
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
                parameters.8,
                parameters.9,
                parameters.10,
                parameters.11,
                parameters.12,
                parameters.13,
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
                var results6 = C6.TangentVector(repeating: .zero, count: v.count)
                var results7 = C7.TangentVector(repeating: .zero, count: v.count)
                var results8 = C8.TangentVector(repeating: .zero, count: v.count)
                var results9 = C9.TangentVector(repeating: .zero, count: v.count)
                var results10 = C10.TangentVector(repeating: .zero, count: v.count)
                var results11 = C11.TangentVector(repeating: .zero, count: v.count)
                var results12 = C12.TangentVector(repeating: .zero, count: v.count)
                var results13 = C13.TangentVector(repeating: .zero, count: v.count)
                var results14 = C14.TangentVector(repeating: .zero, count: v.count)

                var results1Index = results1.startIndex
                var results2Index = results2.startIndex
                var results3Index = results3.startIndex
                var results4Index = results4.startIndex
                var results5Index = results5.startIndex
                var results6Index = results6.startIndex
                var results7Index = results7.startIndex
                var results8Index = results8.startIndex
                var results9Index = results9.startIndex
                var results10Index = results10.startIndex
                var results11Index = results11.startIndex
                var results12Index = results12.startIndex
                var results13Index = results13.startIndex
                var results14Index = results14.startIndex

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
                        result8,
                        result9,
                        result10,
                        result11,
                        result12,
                        result13,
                        result14
                    ) = pullback(tangentElement)

                    results1.writeTangentContribution(of: result1, at: results1Index)
                    results2.writeTangentContribution(of: result2, at: results2Index)
                    results3.writeTangentContribution(of: result3, at: results3Index)
                    results4.writeTangentContribution(of: result4, at: results4Index)
                    results5.writeTangentContribution(of: result5, at: results5Index)
                    results6.writeTangentContribution(of: result6, at: results6Index)
                    results7.writeTangentContribution(of: result7, at: results7Index)
                    results8.writeTangentContribution(of: result8, at: results8Index)
                    results9.writeTangentContribution(of: result9, at: results9Index)
                    results10.writeTangentContribution(of: result10, at: results10Index)
                    results11.writeTangentContribution(of: result11, at: results11Index)
                    results12.writeTangentContribution(of: result12, at: results12Index)
                    results13.writeTangentContribution(of: result13, at: results13Index)
                    results14.writeTangentContribution(of: result14, at: results14Index)

                    results1.formIndex(after: &results1Index)
                    results2.formIndex(after: &results2Index)
                    results3.formIndex(after: &results3Index)
                    results4.formIndex(after: &results4Index)
                    results5.formIndex(after: &results5Index)
                    results6.formIndex(after: &results6Index)
                    results7.formIndex(after: &results7Index)
                    results8.formIndex(after: &results8Index)
                    results9.formIndex(after: &results9Index)
                    results10.formIndex(after: &results10Index)
                    results11.formIndex(after: &results11Index)
                    results12.formIndex(after: &results12Index)
                    results13.formIndex(after: &results13Index)
                    results14.formIndex(after: &results14Index)
                }

                return TangentVector(
                    results1,
                    results2,
                    results3,
                    results4,
                    results5,
                    results6,
                    results7,
                    results8,
                    results9,
                    results10,
                    results11,
                    results12,
                    results13,
                    results14
                )
            }
        )
    }
}

extension Zip14SequenceDifferentiable {
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
        C8.TangentVector.Index == Int,
        C9: Differentiable,
        C9.TangentVector: Collection,
        C9.TangentVector.Index == Int,
        C10: Differentiable,
        C10.TangentVector: Collection,
        C10.TangentVector.Index == Int,
        C11: Differentiable,
        C11.TangentVector: Collection,
        C11.TangentVector.Index == Int,
        C12: Differentiable,
        C12.TangentVector: Collection,
        C12.TangentVector.Index == Int,
        C13: Differentiable,
        C13.TangentVector: Collection,
        C13.TangentVector.Index == Int,
        C14: Differentiable,
        C14.TangentVector: Collection,
        C14.TangentVector.Index == Int
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
            C8.TangentVector.Element,
            C9.TangentVector.Element,
            C10.TangentVector.Element,
            C11.TangentVector.Element,
            C12.TangentVector.Element,
            C13.TangentVector.Element,
            C14.TangentVector.Element
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
                collection8.count,
                collection9.count,
                collection10.count,
                collection11.count,
                collection12.count,
                collection13.count,
                collection14.count
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
                collection8[index],
                collection9[index],
                collection10[index],
                collection11[index],
                collection12[index],
                collection13[index],
                collection14[index]
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
        @usableFromInline
        var collection9: C9.TangentVector
        @usableFromInline
        var collection10: C10.TangentVector
        @usableFromInline
        var collection11: C11.TangentVector
        @usableFromInline
        var collection12: C12.TangentVector
        @usableFromInline
        var collection13: C13.TangentVector
        @usableFromInline
        var collection14: C14.TangentVector
        @inlinable
        init(
            _ collection1: C1.TangentVector,
            _ collection2: C2.TangentVector,
            _ collection3: C3.TangentVector,
            _ collection4: C4.TangentVector,
            _ collection5: C5.TangentVector,
            _ collection6: C6.TangentVector,
            _ collection7: C7.TangentVector,
            _ collection8: C8.TangentVector,
            _ collection9: C9.TangentVector,
            _ collection10: C10.TangentVector,
            _ collection11: C11.TangentVector,
            _ collection12: C12.TangentVector,
            _ collection13: C13.TangentVector,
            _ collection14: C14.TangentVector
        ) {
            self.collection1 = collection1
            self.collection2 = collection2
            self.collection3 = collection3
            self.collection4 = collection4
            self.collection5 = collection5
            self.collection6 = collection6
            self.collection7 = collection7
            self.collection8 = collection8
            self.collection9 = collection9
            self.collection10 = collection10
            self.collection11 = collection11
            self.collection12 = collection12
            self.collection13 = collection13
            self.collection14 = collection14
        }
    }
}

#endif
