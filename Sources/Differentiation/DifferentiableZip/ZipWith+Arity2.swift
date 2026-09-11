
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
    C1: DifferentiableCollection,
    C1.Element: Differentiable,
    C2: DifferentiableCollection,
    C2.Element: Differentiable,
    Result: Differentiable
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
    C1: DifferentiableCollection,
    C1.Element: Differentiable,
    C2: DifferentiableCollection,
    C2.Element: Differentiable,
    Result: Differentiable
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
            guard v.count != 0 else {
                return (
                    C1.TangentVector.zero,
                    C2.TangentVector.zero
                )
            }
            var results1 = C1.TangentVector()
            var results2 = C2.TangentVector()

            results1.reserveCapacity(pullbacks.count)
            results2.reserveCapacity(pullbacks.count)

            precondition(v.count == pullbacks.count)

            for (tangentElement, pullback) in zip(v, pullbacks) {
                let (v1, v2) = pullback(tangentElement)

                results1.appendContribution(of: v1)
                results2.appendContribution(of: v2)
            }

            return (
                results1,
                results2
            )
        }
    )
}
