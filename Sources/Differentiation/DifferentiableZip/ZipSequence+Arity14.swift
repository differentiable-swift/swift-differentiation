
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
        var result = _collection1.count
        result = Swift.min(result, _collection2.count)
        result = Swift.min(result, _collection3.count)
        result = Swift.min(result, _collection4.count)
        result = Swift.min(result, _collection5.count)
        result = Swift.min(result, _collection6.count)
        result = Swift.min(result, _collection7.count)
        result = Swift.min(result, _collection8.count)
        result = Swift.min(result, _collection9.count)
        result = Swift.min(result, _collection10.count)
        result = Swift.min(result, _collection11.count)
        result = Swift.min(result, _collection12.count)
        result = Swift.min(result, _collection13.count)
        result = Swift.min(result, _collection14.count)
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
            _collection9[_collection9.index(_collection9.startIndex, offsetBy: index)],
            _collection10[_collection10.index(_collection10.startIndex, offsetBy: index)],
            _collection11[_collection11.index(_collection11.startIndex, offsetBy: index)],
            _collection12[_collection12.index(_collection12.startIndex, offsetBy: index)],
            _collection13[_collection13.index(_collection13.startIndex, offsetBy: index)],
            _collection14[_collection14.index(_collection14.startIndex, offsetBy: index)]
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
    C1: DifferentiableCollection,
    C2: DifferentiableCollection,
    C3: DifferentiableCollection,
    C4: DifferentiableCollection,
    C5: DifferentiableCollection,
    C6: DifferentiableCollection,
    C7: DifferentiableCollection,
    C8: DifferentiableCollection,
    C9: DifferentiableCollection,
    C10: DifferentiableCollection,
    C11: DifferentiableCollection,
    C12: DifferentiableCollection,
    C13: DifferentiableCollection,
    C14: DifferentiableCollection
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
    C1: DifferentiableCollection,
    C2: DifferentiableCollection,
    C3: DifferentiableCollection,
    C4: DifferentiableCollection,
    C5: DifferentiableCollection,
    C6: DifferentiableCollection,
    C7: DifferentiableCollection,
    C8: DifferentiableCollection,
    C9: DifferentiableCollection,
    C10: DifferentiableCollection,
    C11: DifferentiableCollection,
    C12: DifferentiableCollection,
    C13: DifferentiableCollection,
    C14: DifferentiableCollection
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
            C9.Element.TangentVector,
            C10.Element.TangentVector,
            C11.Element.TangentVector,
            C12.Element.TangentVector,
            C13.Element.TangentVector,
            C14.Element.TangentVector
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
                C9.Element.TangentVector,
                C10.Element.TangentVector,
                C11.Element.TangentVector,
                C12.Element.TangentVector,
                C13.Element.TangentVector,
                C14.Element.TangentVector
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
                        parameters.9,
                        parameters.10,
                        parameters.11,
                        parameters.12,
                        parameters.13,
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
                        C9.TangentVector.zero,
                        C10.TangentVector.zero,
                        C11.TangentVector.zero,
                        C12.TangentVector.zero,
                        C13.TangentVector.zero,
                        C14.TangentVector.zero
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
                let scratch10 = UnsafeMutableBufferPointer<C10.Element.TangentVector>.allocate(capacity: n)
                let scratch11 = UnsafeMutableBufferPointer<C11.Element.TangentVector>.allocate(capacity: n)
                let scratch12 = UnsafeMutableBufferPointer<C12.Element.TangentVector>.allocate(capacity: n)
                let scratch13 = UnsafeMutableBufferPointer<C13.Element.TangentVector>.allocate(capacity: n)
                let scratch14 = UnsafeMutableBufferPointer<C14.Element.TangentVector>.allocate(capacity: n)
                defer { scratch2.deallocate() }
                defer { scratch3.deallocate() }
                defer { scratch4.deallocate() }
                defer { scratch5.deallocate() }
                defer { scratch6.deallocate() }
                defer { scratch7.deallocate() }
                defer { scratch8.deallocate() }
                defer { scratch9.deallocate() }
                defer { scratch10.deallocate() }
                defer { scratch11.deallocate() }
                defer { scratch12.deallocate() }
                defer { scratch13.deallocate() }
                defer { scratch14.deallocate() }

                let tangents1 = v.withUnsafeContiguousStorage { vBuffer in
                    pullbacks.withUnsafeBufferPointer { pullbackBuffer in
                        C1.TangentVector.building(count: n) { index in
                            let (v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14) = pullbackBuffer[index](vBuffer[index])
                            scratch2.initializeElement(at: index, to: v2)
                            scratch3.initializeElement(at: index, to: v3)
                            scratch4.initializeElement(at: index, to: v4)
                            scratch5.initializeElement(at: index, to: v5)
                            scratch6.initializeElement(at: index, to: v6)
                            scratch7.initializeElement(at: index, to: v7)
                            scratch8.initializeElement(at: index, to: v8)
                            scratch9.initializeElement(at: index, to: v9)
                            scratch10.initializeElement(at: index, to: v10)
                            scratch11.initializeElement(at: index, to: v11)
                            scratch12.initializeElement(at: index, to: v12)
                            scratch13.initializeElement(at: index, to: v13)
                            scratch14.initializeElement(at: index, to: v14)
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
                let tangents10 = C10.TangentVector.building(count: n) { i in scratch10.moveElement(from: i) }
                let tangents11 = C11.TangentVector.building(count: n) { i in scratch11.moveElement(from: i) }
                let tangents12 = C12.TangentVector.building(count: n) { i in scratch12.moveElement(from: i) }
                let tangents13 = C13.TangentVector.building(count: n) { i in scratch13.moveElement(from: i) }
                let tangents14 = C14.TangentVector.building(count: n) { i in scratch14.moveElement(from: i) }

                return TangentVector(
                    tangents1,
                    tangents2,
                    tangents3,
                    tangents4,
                    tangents5,
                    tangents6,
                    tangents7,
                    tangents8,
                    tangents9,
                    tangents10,
                    tangents11,
                    tangents12,
                    tangents13,
                    tangents14
                )
            }
        )
    }
}

// TODO: We should change this to a DifferentiableView approach similar to Repeated and Array once tuples can conform to `AdditiveArithmetic` (This currently blocks from `Element` conforming due to being a tuple of collection elements

extension Zip14SequenceDifferentiable {
    public struct TangentVector: Collection & Differentiable & AdditiveArithmetic where
        C1: DifferentiableCollection,
        C2: DifferentiableCollection,
        C3: DifferentiableCollection,
        C4: DifferentiableCollection,
        C5: DifferentiableCollection,
        C6: DifferentiableCollection,
        C7: DifferentiableCollection,
        C8: DifferentiableCollection,
        C9: DifferentiableCollection,
        C10: DifferentiableCollection,
        C11: DifferentiableCollection,
        C12: DifferentiableCollection,
        C13: DifferentiableCollection,
        C14: DifferentiableCollection
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
            var result = collection1.count
            result = Swift.min(result, collection2.count)
            result = Swift.min(result, collection3.count)
            result = Swift.min(result, collection4.count)
            result = Swift.min(result, collection5.count)
            result = Swift.min(result, collection6.count)
            result = Swift.min(result, collection7.count)
            result = Swift.min(result, collection8.count)
            result = Swift.min(result, collection9.count)
            result = Swift.min(result, collection10.count)
            result = Swift.min(result, collection11.count)
            result = Swift.min(result, collection12.count)
            result = Swift.min(result, collection13.count)
            result = Swift.min(result, collection14.count)
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
                collection9[collection9.index(collection9.startIndex, offsetBy: index)],
                collection10[collection10.index(collection10.startIndex, offsetBy: index)],
                collection11[collection11.index(collection11.startIndex, offsetBy: index)],
                collection12[collection12.index(collection12.startIndex, offsetBy: index)],
                collection13[collection13.index(collection13.startIndex, offsetBy: index)],
                collection14[collection14.index(collection14.startIndex, offsetBy: index)]
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
