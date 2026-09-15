
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
    C9
>(
    _ collection1: C1,
    _ collection2: C2,
    _ collection3: C3,
    _ collection4: C4,
    _ collection5: C5,
    _ collection6: C6,
    _ collection7: C7,
    _ collection8: C8,
    _ collection9: C9
) -> Zip9SequenceDifferentiable<C1, C2, C3, C4, C5, C6, C7, C8, C9> {
    Zip9SequenceDifferentiable(
        collection1,
        collection2,
        collection3,
        collection4,
        collection5,
        collection6,
        collection7,
        collection8,
        collection9
    )
}

@frozen
public struct Zip9SequenceDifferentiable<
    C1: Collection,
    C2: Collection,
    C3: Collection,
    C4: Collection,
    C5: Collection,
    C6: Collection,
    C7: Collection,
    C8: Collection,
    C9: Collection
> {
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
        _ collection9: C9
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
    }
}

extension Zip9SequenceDifferentiable: Collection {
    public typealias Element = (
        C1.Element,
        C2.Element,
        C3.Element,
        C4.Element,
        C5.Element,
        C6.Element,
        C7.Element,
        C8.Element,
        C9.Element
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
        result = Swift.min(result, _collection6.count)
        result = Swift.min(result, _collection7.count)
        result = Swift.min(result, _collection8.count)
        result = Swift.min(result, _collection9.count)
        return result
    }

    @inlinable
    public subscript(index: Int) -> Element {
        (
            _collection1[_collection1.index(_collection1.startIndex, offsetBy: index)],
            _collection2[_collection2.index(_collection2.startIndex, offsetBy: index)],
            _collection3[_collection3.index(_collection3.startIndex, offsetBy: index)],
            _collection4[_collection4.index(_collection4.startIndex, offsetBy: index)],
            _collection5[_collection5.index(_collection5.startIndex, offsetBy: index)],
            _collection6[_collection6.index(_collection6.startIndex, offsetBy: index)],
            _collection7[_collection7.index(_collection7.startIndex, offsetBy: index)],
            _collection8[_collection8.index(_collection8.startIndex, offsetBy: index)],
            _collection9[_collection9.index(_collection9.startIndex, offsetBy: index)]
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

extension Zip9SequenceDifferentiable: Sendable where
    C1: Sendable,
    C2: Sendable,
    C3: Sendable,
    C4: Sendable,
    C5: Sendable,
    C6: Sendable,
    C7: Sendable,
    C8: Sendable,
    C9: Sendable
{}

// MARK: Zip9SequenceDifferentiable + Differentiable

@derivative(of: differentiableZip)
@inlinable
public func _vjpDifferentiableZip<C1, C2, C3, C4, C5, C6, C7, C8, C9>(
    _ collection1: C1,
    _ collection2: C2,
    _ collection3: C3,
    _ collection4: C4,
    _ collection5: C5,
    _ collection6: C6,
    _ collection7: C7,
    _ collection8: C8,
    _ collection9: C9
) -> (
    value: Zip9SequenceDifferentiable<C1, C2, C3, C4, C5, C6, C7, C8, C9>,
    pullback: (Zip9SequenceDifferentiable<C1, C2, C3, C4, C5, C6, C7, C8, C9>.TangentVector) -> (
        C1.TangentVector,
        C2.TangentVector,
        C3.TangentVector,
        C4.TangentVector,
        C5.TangentVector,
        C6.TangentVector,
        C7.TangentVector,
        C8.TangentVector,
        C9.TangentVector
    )
) where
    C1: DifferentiableCollection,
    C2: DifferentiableCollection,
    C3: DifferentiableCollection,
    C4: DifferentiableCollection,
    C5: DifferentiableCollection,
    C6: DifferentiableCollection,
    C7: DifferentiableCollection,
    C8: DifferentiableCollection,
    C9: DifferentiableCollection
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
            collection9
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
                v.collection9
            )
        }
    )
}

extension Zip9SequenceDifferentiable {
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
            C9.Element
        ) -> Result
    ) -> [Result] {
        self.map(transform)
    }
}

extension Zip9SequenceDifferentiable: Differentiable where
    C1: DifferentiableCollection,
    C2: DifferentiableCollection,
    C3: DifferentiableCollection,
    C4: DifferentiableCollection,
    C5: DifferentiableCollection,
    C6: DifferentiableCollection,
    C7: DifferentiableCollection,
    C8: DifferentiableCollection,
    C9: DifferentiableCollection
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
            C9.Element
        ) -> Result
    ) -> (value: [Result], pullback: ([Result].TangentVector) -> TangentVector) {
        let capacity = self.count

        var pullbacks: ContiguousArray<(Result.TangentVector) -> (
            C1.Element.TangentVector,
            C2.Element.TangentVector,
            C3.Element.TangentVector,
            C4.Element.TangentVector,
            C5.Element.TangentVector,
            C6.Element.TangentVector,
            C7.Element.TangentVector,
            C8.Element.TangentVector,
            C9.Element.TangentVector
        )>!

        let results = Array<Result>(unsafeUninitializedCapacity: count) { resultsBuffer, resultsInitializedCount in
            pullbacks = ContiguousArray<(Result.TangentVector) -> (
                C1.Element.TangentVector,
                C2.Element.TangentVector,
                C3.Element.TangentVector,
                C4.Element.TangentVector,
                C5.Element.TangentVector,
                C6.Element.TangentVector,
                C7.Element.TangentVector,
                C8.Element.TangentVector,
                C9.Element.TangentVector
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
                        parameters.5,
                        parameters.6,
                        parameters.7,
                        parameters.8,
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
                        C5.TangentVector.zero,
                        C6.TangentVector.zero,
                        C7.TangentVector.zero,
                        C8.TangentVector.zero,
                        C9.TangentVector.zero
                    )
                }
                let n = pullbacks.count
                precondition(v.count == n)

                let scratch2 = UnsafeMutableBufferPointer<C2.Element.TangentVector>.allocate(capacity: n)
                let scratch3 = UnsafeMutableBufferPointer<C3.Element.TangentVector>.allocate(capacity: n)
                let scratch4 = UnsafeMutableBufferPointer<C4.Element.TangentVector>.allocate(capacity: n)
                let scratch5 = UnsafeMutableBufferPointer<C5.Element.TangentVector>.allocate(capacity: n)
                let scratch6 = UnsafeMutableBufferPointer<C6.Element.TangentVector>.allocate(capacity: n)
                let scratch7 = UnsafeMutableBufferPointer<C7.Element.TangentVector>.allocate(capacity: n)
                let scratch8 = UnsafeMutableBufferPointer<C8.Element.TangentVector>.allocate(capacity: n)
                let scratch9 = UnsafeMutableBufferPointer<C9.Element.TangentVector>.allocate(capacity: n)
                defer { scratch2.deallocate() }
                defer { scratch3.deallocate() }
                defer { scratch4.deallocate() }
                defer { scratch5.deallocate() }
                defer { scratch6.deallocate() }
                defer { scratch7.deallocate() }
                defer { scratch8.deallocate() }
                defer { scratch9.deallocate() }

                let tangents1 = v.withUnsafeContiguousStorage { vBuffer in
                    pullbacks.withUnsafeBufferPointer { pullbackBuffer in
                        C1.TangentVector.building(count: n) { index in
                            let (v1, v2, v3, v4, v5, v6, v7, v8, v9) = pullbackBuffer[index](vBuffer[index])
                            scratch2.initializeElement(at: index, to: v2)
                            scratch3.initializeElement(at: index, to: v3)
                            scratch4.initializeElement(at: index, to: v4)
                            scratch5.initializeElement(at: index, to: v5)
                            scratch6.initializeElement(at: index, to: v6)
                            scratch7.initializeElement(at: index, to: v7)
                            scratch8.initializeElement(at: index, to: v8)
                            scratch9.initializeElement(at: index, to: v9)
                            return v1
                        }
                    }
                }

                let tangents2 = C2.TangentVector.building(count: n) { i in scratch2.moveElement(from: i) }
                let tangents3 = C3.TangentVector.building(count: n) { i in scratch3.moveElement(from: i) }
                let tangents4 = C4.TangentVector.building(count: n) { i in scratch4.moveElement(from: i) }
                let tangents5 = C5.TangentVector.building(count: n) { i in scratch5.moveElement(from: i) }
                let tangents6 = C6.TangentVector.building(count: n) { i in scratch6.moveElement(from: i) }
                let tangents7 = C7.TangentVector.building(count: n) { i in scratch7.moveElement(from: i) }
                let tangents8 = C8.TangentVector.building(count: n) { i in scratch8.moveElement(from: i) }
                let tangents9 = C9.TangentVector.building(count: n) { i in scratch9.moveElement(from: i) }

                return TangentVector(
                    tangents1,
                    tangents2,
                    tangents3,
                    tangents4,
                    tangents5,
                    tangents6,
                    tangents7,
                    tangents8,
                    tangents9
                )
            }
        )
    }
}

// TODO: We should change this to a DifferentiableView approach similar to Repeated and Array once tuples can conform to `AdditiveArithmetic` (This currently blocks from `Element` conforming due to being a tuple of collection elements

extension Zip9SequenceDifferentiable {
    public struct TangentVector: Collection & Differentiable & AdditiveArithmetic where
        C1: DifferentiableCollection,
        C2: DifferentiableCollection,
        C3: DifferentiableCollection,
        C4: DifferentiableCollection,
        C5: DifferentiableCollection,
        C6: DifferentiableCollection,
        C7: DifferentiableCollection,
        C8: DifferentiableCollection,
        C9: DifferentiableCollection
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
            C9.TangentVector.Element
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
            result = Swift.min(result, collection6.count)
            result = Swift.min(result, collection7.count)
            result = Swift.min(result, collection8.count)
            result = Swift.min(result, collection9.count)
            return result
        }

        @inlinable
        public subscript(index: Int) -> Element {
            (
                collection1[collection1.index(collection1.startIndex, offsetBy: index)],
                collection2[collection2.index(collection2.startIndex, offsetBy: index)],
                collection3[collection3.index(collection3.startIndex, offsetBy: index)],
                collection4[collection4.index(collection4.startIndex, offsetBy: index)],
                collection5[collection5.index(collection5.startIndex, offsetBy: index)],
                collection6[collection6.index(collection6.startIndex, offsetBy: index)],
                collection7[collection7.index(collection7.startIndex, offsetBy: index)],
                collection8[collection8.index(collection8.startIndex, offsetBy: index)],
                collection9[collection9.index(collection9.startIndex, offsetBy: index)]
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
            _ collection9: C9.TangentVector
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
        }
    }
}
