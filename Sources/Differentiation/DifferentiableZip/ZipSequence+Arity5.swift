
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
        var result = _collection1.count
        result = Swift.min(result, _collection2.count)
        result = Swift.min(result, _collection3.count)
        result = Swift.min(result, _collection4.count)
        result = Swift.min(result, _collection5.count)
        return result
    }

    @inlinable
    public subscript(index: Int) -> Element {
        (
            _collection1[_collection1.startIndex.advanced(by: index)],
            _collection2[_collection2.startIndex.advanced(by: index)],
            _collection3[_collection3.startIndex.advanced(by: index)],
            _collection4[_collection4.startIndex.advanced(by: index)],
            _collection5[_collection5.startIndex.advanced(by: index)]
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
        let capacity = self.count

        var pullbacks: ContiguousArray<(Result.TangentVector) -> (
            C1.Element.TangentVector,
            C2.Element.TangentVector,
            C3.Element.TangentVector,
            C4.Element.TangentVector,
            C5.Element.TangentVector
        )>!

        let results = Array<Result>(unsafeUninitializedCapacity: count) { resultsBuffer, resultsInitializedCount in
            pullbacks = ContiguousArray<(Result.TangentVector) -> (
                C1.Element.TangentVector,
                C2.Element.TangentVector,
                C3.Element.TangentVector,
                C4.Element.TangentVector,
                C5.Element.TangentVector
            )>(unsafeUninitializedCapacity: count) { pullbacksBuffer, pullbacksInitializedCount in
                for i in 0 ..< capacity {
                    let parameters = self[i]
                    let (value, pullback) = valueWithPullback(
                        at:
                        parameters.0,
                        parameters.1,
                        parameters.2,
                        parameters.3,
                        parameters.4,
                        of: transform
                    )
                    resultsBuffer.initializeElement(at: i, to: value)
                    pullbacksBuffer.initializeElement(at: i, to: pullback)
                }
                pullbacksInitializedCount = count
            }
            resultsInitializedCount = count
        }

        return (
            value: results,
            pullback: { v in
                if v.count == 0 {
                    return TangentVector(
                        C1.TangentVector.zero,
                        C2.TangentVector.zero,
                        C3.TangentVector.zero,
                        C4.TangentVector.zero,
                        C5.TangentVector.zero
                    )
                }
                let n = pullbacks.count
                precondition(v.count == n)

                let scratch2 = UnsafeMutableBufferPointer<C2.Element.TangentVector>.allocate(capacity: n)
                let scratch3 = UnsafeMutableBufferPointer<C3.Element.TangentVector>.allocate(capacity: n)
                let scratch4 = UnsafeMutableBufferPointer<C4.Element.TangentVector>.allocate(capacity: n)
                let scratch5 = UnsafeMutableBufferPointer<C5.Element.TangentVector>.allocate(capacity: n)
                defer { scratch2.deallocate() }
                defer { scratch3.deallocate() }
                defer { scratch4.deallocate() }
                defer { scratch5.deallocate() }

                let tangents1 = v.withUnsafeContiguousStorage { vBuffer in
                    pullbacks.withUnsafeBufferPointer { pullbackBuffer in
                        C1.TangentVector.building(count: n) { index in
                            let (v1, v2, v3, v4, v5) = pullbackBuffer[index](vBuffer[index])
                            scratch2.initializeElement(at: index, to: v2)
                            scratch3.initializeElement(at: index, to: v3)
                            scratch4.initializeElement(at: index, to: v4)
                            scratch5.initializeElement(at: index, to: v5)
                            return v1
                        }
                    }
                }

                let tangents2 = C2.TangentVector.building(count: n) { i in scratch2.moveElement(from: i) }
                let tangents3 = C3.TangentVector.building(count: n) { i in scratch3.moveElement(from: i) }
                let tangents4 = C4.TangentVector.building(count: n) { i in scratch4.moveElement(from: i) }
                let tangents5 = C5.TangentVector.building(count: n) { i in scratch5.moveElement(from: i) }

                return TangentVector(
                    tangents1,
                    tangents2,
                    tangents3,
                    tangents4,
                    tangents5
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
            var result = collection1.count
            result = Swift.min(result, collection2.count)
            result = Swift.min(result, collection3.count)
            result = Swift.min(result, collection4.count)
            result = Swift.min(result, collection5.count)
            return result
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
