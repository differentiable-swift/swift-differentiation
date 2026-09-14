
import _Differentiation

@inlinable
public func differentiableZipWith<C1, C2, Result>(
    _ c1: C1,
    _ c2: C2,
    with transform: @differentiable(reverse) (
        C1.Element,
        C2.Element
    ) -> Result
) -> [Result] where
    Result: Differentiable,
    C1: DifferentiableCollection,
    C2: DifferentiableCollection
{
    var capacity = c1.count
    capacity = Swift.min(capacity, c2.count)

    if capacity == 0 { return [] }

    return [Result](unsafeUninitializedCapacity: capacity) { buffer, initializedCount in
        var c1i = c1.startIndex
        var c2i = c2.startIndex

        for i in 0 ..< capacity {
            let value = transform(
                c1[c1i],
                c2[c2i]
            )
            buffer.initializeElement(at: i, to: value)
            c1.formIndex(after: &c1i)
            c2.formIndex(after: &c2i)
        }
        initializedCount = capacity
    }
}

@derivative(of: differentiableZipWith)
@inlinable
public func _vjpDifferentiableZipWith<C1, C2, Result>(
    _ c1: C1,
    _ c2: C2,
    with transform: @differentiable(reverse) (
        C1.Element,
        C2.Element
    ) -> Result
) -> (
    value: [Result],
    pullback: ([Result].TangentVector) -> (
        C1.TangentVector,
        C2.TangentVector
    )
) where
    Result: Differentiable,
    C1: DifferentiableCollection,
    C2: DifferentiableCollection
{
    var count = c1.count
    count = Swift.min(count, c2.count)

    if count == 0 {
        return (
            value: [],
            pullback: { _ in
                (
                    C1.TangentVector.zero,
                    C2.TangentVector.zero
                )
            }
        )
    }

    var pullbacks: ContiguousArray<(Result.TangentVector) -> (
        C1.Element.TangentVector,
        C2.Element.TangentVector
    )>!
    let results = Array<Result>(unsafeUninitializedCapacity: count) { resultsBuffer, resultsInitializedCount in
        pullbacks = ContiguousArray<(Result.TangentVector) -> (
            C1.Element.TangentVector,
            C2.Element.TangentVector
        )>(unsafeUninitializedCapacity: count) { pullbacksBuffer, pullbacksInitializedCount in
            var c1i = c1.startIndex
            var c2i = c2.startIndex

            for i in 0 ..< count {
                let (value, pullback) = valueWithPullback(
                    at:
                    c1[c1i],
                    c2[c2i],
                    of: transform
                )

                resultsBuffer.initializeElement(at: i, to: value)
                pullbacksBuffer.initializeElement(at: i, to: pullback)

                c1.formIndex(after: &c1i)
                c2.formIndex(after: &c2i)
            }
            pullbacksInitializedCount = count
        }
        resultsInitializedCount = count
    }

    return (
        value: results,
        pullback: { v in
            if v.count == 0 {
                return (
                    C1.TangentVector.zero,
                    C2.TangentVector.zero
                )
            }
            let n = pullbacks.count
            precondition(v.count == n)

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

            return (
                tangents1,
                tangents2
            )
        }
    )
}
