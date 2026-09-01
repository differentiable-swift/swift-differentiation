
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
    C10
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
    _ collection10: C10
) -> Zip10SequenceDifferentiable<C1, C2, C3, C4, C5, C6, C7, C8, C9, C10> {
    Zip10SequenceDifferentiable(
        collection1,
        collection2,
        collection3,
        collection4,
        collection5,
        collection6,
        collection7,
        collection8,
        collection9,
        collection10
    )
}

@frozen
public struct Zip10SequenceDifferentiable<
    C1: Collection,
    C2: Collection,
    C3: Collection,
    C4: Collection,
    C5: Collection,
    C6: Collection,
    C7: Collection,
    C8: Collection,
    C9: Collection,
    C10: Collection
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
    C10.Index == Int
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
        _ collection10: C10
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
    }
}

extension Zip10SequenceDifferentiable: Collection {
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
        C10.Element
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
        return result
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
            _collection8[_collection8.startIndex.advanced(by: index)],
            _collection9[_collection9.startIndex.advanced(by: index)],
            _collection10[_collection10.startIndex.advanced(by: index)]
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

extension Zip10SequenceDifferentiable: Sendable where
    C1: Sendable,
    C2: Sendable,
    C3: Sendable,
    C4: Sendable,
    C5: Sendable,
    C6: Sendable,
    C7: Sendable,
    C8: Sendable,
    C9: Sendable,
    C10: Sendable
{}

// MARK: Zip10SequenceDifferentiable + Differentiable

@derivative(of: differentiableZip)
@inlinable
public func _vjpDifferentiableZip<C1, C2, C3, C4, C5, C6, C7, C8, C9, C10>(
    _ collection1: C1,
    _ collection2: C2,
    _ collection3: C3,
    _ collection4: C4,
    _ collection5: C5,
    _ collection6: C6,
    _ collection7: C7,
    _ collection8: C8,
    _ collection9: C9,
    _ collection10: C10
) -> (
    value: Zip10SequenceDifferentiable<C1, C2, C3, C4, C5, C6, C7, C8, C9, C10>,
    pullback: (Zip10SequenceDifferentiable<C1, C2, C3, C4, C5, C6, C7, C8, C9, C10>.TangentVector) -> (
        C1.TangentVector,
        C2.TangentVector,
        C3.TangentVector,
        C4.TangentVector,
        C5.TangentVector,
        C6.TangentVector,
        C7.TangentVector,
        C8.TangentVector,
        C9.TangentVector,
        C10.TangentVector
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
    C10: DifferentiableCollection
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
            collection10
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
                v.collection10
            )
        }
    )
}

extension Zip10SequenceDifferentiable {
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
            C10.Element
        ) -> Result
    ) -> [Result] {
        self.map(transform)
    }
}

extension Zip10SequenceDifferentiable: Differentiable where
    C1: DifferentiableCollection,
    C2: DifferentiableCollection,
    C3: DifferentiableCollection,
    C4: DifferentiableCollection,
    C5: DifferentiableCollection,
    C6: DifferentiableCollection,
    C7: DifferentiableCollection,
    C8: DifferentiableCollection,
    C9: DifferentiableCollection,
    C10: DifferentiableCollection
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
            C10.Element
        ) -> Result
    ) -> (value: [Result], pullback: ([Result].TangentVector) -> TangentVector) {
        let count = self.count
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
            C10.Element.TangentVector
        )> = []
        pullbacks.reserveCapacity(count)

        let results = [Result](unsafeUninitializedCapacity: count) { buffer, initializedCount in
            var c1i = _collection1.startIndex
            var c2i = _collection2.startIndex
            var c3i = _collection3.startIndex
            var c4i = _collection4.startIndex
            var c5i = _collection5.startIndex
            var c6i = _collection6.startIndex
            var c7i = _collection7.startIndex
            var c8i = _collection8.startIndex
            var c9i = _collection9.startIndex
            var c10i = _collection10.startIndex

            for i in 0 ..< count {
                let (value, pullback) = valueWithPullback(
                    at:
                    _collection1[c1i],
                    _collection2[c2i],
                    _collection3[c3i],
                    _collection4[c4i],
                    _collection5[c5i],
                    _collection6[c6i],
                    _collection7[c7i],
                    _collection8[c8i],
                    _collection9[c9i],
                    _collection10[c10i],
                    of: transform
                )

                buffer.initializeElement(at: i, to: value)
                pullbacks.append(pullback)

                _collection1.formIndex(after: &c1i)
                _collection2.formIndex(after: &c2i)
                _collection3.formIndex(after: &c3i)
                _collection4.formIndex(after: &c4i)
                _collection5.formIndex(after: &c5i)
                _collection6.formIndex(after: &c6i)
                _collection7.formIndex(after: &c7i)
                _collection8.formIndex(after: &c8i)
                _collection9.formIndex(after: &c9i)
                _collection10.formIndex(after: &c10i)
            }

            initializedCount = count
        }

        return (
            value: results,
            pullback: { v in
                // if the incoming tangent is empty (ie. .zero) we can exit early due to the linear nature of the pullback.
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
                        C10.TangentVector.zero
                    )
                }

                let n = pullbacks.count
                precondition(v.count == n)

                // Scratch is initialized while building `tangents1` and moved out while building the
                // rest. This is memory-safe because `building(count:_:)` guarantees a once-per-index, in-order visit
                // (see `DifferentiableCollectionTangentVector`).
                let scratch2 = UnsafeMutableBufferPointer<C2.Element.TangentVector>.allocate(capacity: n)
                let scratch3 = UnsafeMutableBufferPointer<C3.Element.TangentVector>.allocate(capacity: n)
                let scratch4 = UnsafeMutableBufferPointer<C4.Element.TangentVector>.allocate(capacity: n)
                let scratch5 = UnsafeMutableBufferPointer<C5.Element.TangentVector>.allocate(capacity: n)
                let scratch6 = UnsafeMutableBufferPointer<C6.Element.TangentVector>.allocate(capacity: n)
                let scratch7 = UnsafeMutableBufferPointer<C7.Element.TangentVector>.allocate(capacity: n)
                let scratch8 = UnsafeMutableBufferPointer<C8.Element.TangentVector>.allocate(capacity: n)
                let scratch9 = UnsafeMutableBufferPointer<C9.Element.TangentVector>.allocate(capacity: n)
                let scratch10 = UnsafeMutableBufferPointer<C10.Element.TangentVector>.allocate(capacity: n)
                defer { scratch2.deallocate() }
                defer { scratch3.deallocate() }
                defer { scratch4.deallocate() }
                defer { scratch5.deallocate() }
                defer { scratch6.deallocate() }
                defer { scratch7.deallocate() }
                defer { scratch8.deallocate() }
                defer { scratch9.deallocate() }
                defer { scratch10.deallocate() }

                let tangents1 = v.withUnsafeContiguousStorage { vBuffer in
                    pullbacks.withUnsafeBufferPointer { pullbackBuffer in
                        C1.TangentVector.building(count: n) { index in
                            let (v1, v2, v3, v4, v5, v6, v7, v8, v9, v10) = pullbackBuffer[index](vBuffer[index])
                            scratch2.initializeElement(at: index, to: v2)
                            scratch3.initializeElement(at: index, to: v3)
                            scratch4.initializeElement(at: index, to: v4)
                            scratch5.initializeElement(at: index, to: v5)
                            scratch6.initializeElement(at: index, to: v6)
                            scratch7.initializeElement(at: index, to: v7)
                            scratch8.initializeElement(at: index, to: v8)
                            scratch9.initializeElement(at: index, to: v9)
                            scratch10.initializeElement(at: index, to: v10)
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
                    tangents10
                )
            }
        )
    }
}

extension Zip10SequenceDifferentiable {
    public struct TangentVector: Differentiable & AdditiveArithmetic where
        C1: Differentiable,
        C2: Differentiable,
        C3: Differentiable,
        C4: Differentiable,
        C5: Differentiable,
        C6: Differentiable,
        C7: Differentiable,
        C8: Differentiable,
        C9: Differentiable,
        C10: Differentiable
    {
        public typealias TangentVector = Self

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
            _ collection10: C10.TangentVector
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
        }
    }
}
