
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
        var result = _collection1.count
        result = Swift.min(result, _collection2.count)
        return result
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
    C1: DifferentiableCollection,
    C2: DifferentiableCollection
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
    C1: DifferentiableCollection,
    C2: DifferentiableCollection
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
        let count = self.count
        var pullbacks: ContiguousArray<(Result.TangentVector) -> (
            C1.Element.TangentVector,
            C2.Element.TangentVector
        )> = []
        pullbacks.reserveCapacity(count)

        let results = [Result](unsafeUninitializedCapacity: count) { buffer, initializedCount in
            var c1i = _collection1.startIndex
            var c2i = _collection2.startIndex

            for i in 0 ..< count {
                let (value, pullback) = valueWithPullback(
                    at:
                    _collection1[c1i],
                    _collection2[c2i],
                    of: transform
                )

                buffer.initializeElement(at: i, to: value)
                pullbacks.append(pullback)

                _collection1.formIndex(after: &c1i)
                _collection2.formIndex(after: &c2i)
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
                        C2.TangentVector.zero
                    )
                }

                let n = pullbacks.count
                precondition(v.count == n)

                // Scratch is initialized while building `tangents1` and moved out while building the
                // rest. This is memory-safe because `building(count:_:)` guarantees a once-per-index, in-order visit
                // (see `DifferentiableCollectionTangentVector`).
                let scratch2 = UnsafeMutableBufferPointer<C2.Element.TangentVector>.allocate(capacity: n)
                defer { scratch2.deallocate() }

                let tangents1 = v.withUnsafeContiguousStorage { vBuffer in
                    pullbacks.withUnsafeBufferPointer { pullbackBuffer in
                        C1.TangentVector.building(count: n) { index in
                            let (v1, v2) = pullbackBuffer[index](vBuffer[index])
                            scratch2.initializeElement(at: index, to: v2)
                            return v1
                        }
                    }
                }

                let tangents2 = C2.TangentVector.building(count: n) { i in scratch2.moveElement(from: i) }

                return TangentVector(
                    tangents1,
                    tangents2
                )
            }
        )
    }
}

extension Zip2SequenceDifferentiable {
    public struct TangentVector: Differentiable & AdditiveArithmetic where
        C1: Differentiable,
        C2: Differentiable
    {
        public typealias TangentVector = Self

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
