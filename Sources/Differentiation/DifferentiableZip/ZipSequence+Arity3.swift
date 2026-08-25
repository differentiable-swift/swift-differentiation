
@inlinable
public func differentiableZip<
    C1,
    C2,
    C3
>(
    _ collection1: C1,
    _ collection2: C2,
    _ collection3: C3
) -> Zip3SequenceDifferentiable<C1, C2, C3> {
    Zip3SequenceDifferentiable(
        collection1,
        collection2,
        collection3
    )
}

@frozen
public struct Zip3SequenceDifferentiable<
    C1: Collection,
    C2: Collection,
    C3: Collection
> where
    C1.Index == Int,
    C2.Index == Int,
    C3.Index == Int
{
    @usableFromInline
    internal var _collection1: C1
    @usableFromInline
    internal var _collection2: C2
    @usableFromInline
    internal var _collection3: C3
    @inlinable
    internal init(
        _ collection1: C1,
        _ collection2: C2,
        _ collection3: C3
    ) {
        self._collection1 = collection1
        self._collection2 = collection2
        self._collection3 = collection3
    }
}

extension Zip3SequenceDifferentiable: Collection {
    public typealias Element = (
        C1.Element,
        C2.Element,
        C3.Element
    )
    public typealias Index = Int

    @inlinable
    public var startIndex: Int { 0 }
    @inlinable
    public var endIndex: Int {
        var result = _collection1.count
        result = Swift.min(result, _collection2.count)
        result = Swift.min(result, _collection3.count)
        return result
    }

    @inlinable
    public subscript(index: Int) -> Element {
        (
            _collection1[_collection1.startIndex.advanced(by: index)],
            _collection2[_collection2.startIndex.advanced(by: index)],
            _collection3[_collection3.startIndex.advanced(by: index)]
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

extension Zip3SequenceDifferentiable: Sendable where
    C1: Sendable,
    C2: Sendable,
    C3: Sendable
{}

// MARK: Zip3SequenceDifferentiable + Differentiable

@derivative(of: differentiableZip)
@inlinable
public func _vjpDifferentiableZip<C1, C2, C3>(
    _ collection1: C1,
    _ collection2: C2,
    _ collection3: C3
) -> (
    value: Zip3SequenceDifferentiable<C1, C2, C3>,
    pullback: (Zip3SequenceDifferentiable<C1, C2, C3>.TangentVector) -> (
        C1.TangentVector,
        C2.TangentVector,
        C3.TangentVector
    )
) where
    C1: DifferentiableCollection,
    C2: DifferentiableCollection,
    C3: DifferentiableCollection
{
    (
        value: differentiableZip(
            collection1,
            collection2,
            collection3
        ),
        pullback: { v in
            (
                v.collection1,
                v.collection2,
                v.collection3
            )
        }
    )
}

extension Zip3SequenceDifferentiable {
    @inlinable
    public func differentiableMap<Result: Differentiable>(
        _ transform: @differentiable(reverse) (
            C1.Element,
            C2.Element,
            C3.Element
        ) -> Result
    ) -> [Result] {
        self.map(transform)
    }
}

extension Zip3SequenceDifferentiable: Differentiable where
    C1: DifferentiableCollection,
    C2: DifferentiableCollection,
    C3: DifferentiableCollection
{
    @inlinable
    public mutating func move(by offset: TangentVector) {
        _collection1.move(by: offset.collection1)
        _collection2.move(by: offset.collection2)
        _collection3.move(by: offset.collection3)
    }

    @derivative(of: differentiableMap)
    @inlinable
    public func _vjpDifferentiableMap<Result: Differentiable>(
        _ transform: @differentiable(reverse) (
            C1.Element,
            C2.Element,
            C3.Element
        ) -> Result
    ) -> (value: [Result], pullback: ([Result].TangentVector) -> TangentVector) {
        let count = self.count
        var pullbacks: ContiguousArray<(Result.TangentVector) -> (
            C1.Element.TangentVector,
            C2.Element.TangentVector,
            C3.Element.TangentVector
        )> = []
        pullbacks.reserveCapacity(count)

        let results = [Result](unsafeUninitializedCapacity: count) { buffer, initializedCount in
            var c1i = _collection1.startIndex
            var c2i = _collection2.startIndex
            var c3i = _collection3.startIndex

            for i in 0 ..< count {
                let (value, pullback) = valueWithPullback(
                    at:
                    _collection1[c1i],
                    _collection2[c2i],
                    _collection3[c3i],
                    of: transform
                )

                buffer.initializeElement(at: i, to: value)
                pullbacks.append(pullback)

                _collection1.formIndex(after: &c1i)
                _collection2.formIndex(after: &c2i)
                _collection3.formIndex(after: &c3i)
            }

            initializedCount = count
        }

        return (
            value: results,
            pullback: { v in
                let n = pullbacks.count
                if n == 0 {
                    return TangentVector(
                        C1.TangentVector.zero,
                        C2.TangentVector.zero,
                        C3.TangentVector.zero
                    )
                }

                let zeroUpstream = v.count == 0
                if !zeroUpstream {
                    precondition(v.count == n)
                }

                // Scratch is initialized while building `tangents1` and moved out while building the
                // rest. This is memory-safe because of `init(count:_:)`'s once-per-index, in-order contract
                // (see `DifferentiableCollectionTangentVector`).
                let scratch2 = UnsafeMutableBufferPointer<C2.Element.TangentVector>.allocate(capacity: n)
                let scratch3 = UnsafeMutableBufferPointer<C3.Element.TangentVector>.allocate(capacity: n)
                defer { scratch2.deallocate() }
                defer { scratch3.deallocate() }

                let tangents1: C1.TangentVector
                if zeroUpstream {
                    tangents1 = pullbacks.withUnsafeBufferPointer { pullbackBuffer in
                        C1.TangentVector(count: n) { index in
                            let (v1, v2, v3) = pullbackBuffer[index](.zero)
                            scratch2.initializeElement(at: index, to: v2)
                            scratch3.initializeElement(at: index, to: v3)
                            return v1
                        }
                    }
                }
                else {
                    tangents1 = v.withUnsafeContiguousStorage { vBuffer in
                        pullbacks.withUnsafeBufferPointer { pullbackBuffer in
                            C1.TangentVector(count: n) { index in
                                let (v1, v2, v3) = pullbackBuffer[index](vBuffer[index])
                                scratch2.initializeElement(at: index, to: v2)
                                scratch3.initializeElement(at: index, to: v3)
                                return v1
                            }
                        }
                    }
                }

                let tangents2 = C2.TangentVector(count: n) { i in scratch2.moveElement(from: i) }
                let tangents3 = C3.TangentVector(count: n) { i in scratch3.moveElement(from: i) }

                return TangentVector(
                    tangents1,
                    tangents2,
                    tangents3
                )
            }
        )
    }
}

extension Zip3SequenceDifferentiable {
    public struct TangentVector: Differentiable & AdditiveArithmetic where
        C1: Differentiable,
        C2: Differentiable,
        C3: Differentiable
    {
        public typealias TangentVector = Self

        @usableFromInline
        var collection1: C1.TangentVector
        @usableFromInline
        var collection2: C2.TangentVector
        @usableFromInline
        var collection3: C3.TangentVector
        @inlinable
        init(
            _ collection1: C1.TangentVector,
            _ collection2: C2.TangentVector,
            _ collection3: C3.TangentVector
        ) {
            self.collection1 = collection1
            self.collection2 = collection2
            self.collection3 = collection3
        }
    }
}
