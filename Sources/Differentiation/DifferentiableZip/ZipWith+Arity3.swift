
import _Differentiation

@inlinable
public func differentiableZipWith<C1, C2, C3, Result>(
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    with transform: @differentiable(reverse) (
        C1.Element,
        C2.Element,
        C3.Element
    ) -> Result
) -> [Result] where
    C1: DifferentiableCollection,
    C1.Element: Differentiable,
    C2: DifferentiableCollection,
    C2.Element: Differentiable,
    C3: DifferentiableCollection,
    C3.Element: Differentiable,
    Result: Differentiable
{
    var capacity = c1.count
    capacity = Swift.min(capacity, c2.count)
    capacity = Swift.min(capacity, c3.count)

    if capacity == 0 { return [] }

    return [Result](unsafeUninitializedCapacity: capacity) { buffer, initializedCount in
        var c1i = c1.startIndex
        var c2i = c2.startIndex
        var c3i = c3.startIndex

        for i in 0 ..< capacity {
            let value = transform(
                c1[c1i],
                c2[c2i],
                c3[c3i]
            )
            buffer.initializeElement(at: i, to: value)
            c1.formIndex(after: &c1i)
            c2.formIndex(after: &c2i)
            c3.formIndex(after: &c3i)
        }
        initializedCount = capacity
    }
}

@derivative(of: differentiableZipWith)
@inlinable
public func _vjpDifferentiableZipWith<C1, C2, C3, Result>(
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    with transform: @differentiable(reverse) (
        C1.Element,
        C2.Element,
        C3.Element
    ) -> Result
) -> (
    value: [Result],
    pullback: ([Result].TangentVector) -> (
        C1.TangentVector,
        C2.TangentVector,
        C3.TangentVector
    )
) where
    C1: DifferentiableCollection,
    C1.Element: Differentiable,
    C2: DifferentiableCollection,
    C2.Element: Differentiable,
    C3: DifferentiableCollection,
    C3.Element: Differentiable,
    Result: Differentiable
{
    var count = c1.count
    count = Swift.min(count, c2.count)
    count = Swift.min(count, c3.count)

    if count == 0 {
        return (
            value: [],
            pullback: { _ in
                (
                    C1.TangentVector.zero,
                    C2.TangentVector.zero,
                    C3.TangentVector.zero
                )
            }
        )
    }

    var pullbacks: ContiguousArray<(Result.TangentVector) -> (
        C1.Element.TangentVector,
        C2.Element.TangentVector,
        C3.Element.TangentVector
    )>!
    let results = Array<Result>(unsafeUninitializedCapacity: count) { resultsBuffer, resultsInitializedCount in
        pullbacks = ContiguousArray<(Result.TangentVector) -> (
            C1.Element.TangentVector,
            C2.Element.TangentVector,
            C3.Element.TangentVector
        )>(unsafeUninitializedCapacity: count) { pullbacksBuffer, pullbacksInitializedCount in
            var c1i = c1.startIndex
            var c2i = c2.startIndex
            var c3i = c3.startIndex

            for i in 0 ..< count {
                let (value, pullback) = valueWithPullback(
                    at:
                    c1[c1i],
                    c2[c2i],
                    c3[c3i],
                    of: transform
                )

                resultsBuffer.initializeElement(at: i, to: value)
                pullbacksBuffer.initializeElement(at: i, to: pullback)

                c1.formIndex(after: &c1i)
                c2.formIndex(after: &c2i)
                c3.formIndex(after: &c3i)
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
                    C2.TangentVector.zero,
                    C3.TangentVector.zero
                )
            }
            var results1 = C1.TangentVector()
            var results2 = C2.TangentVector()
            var results3 = C3.TangentVector()

            results1.reserveCapacity(pullbacks.count)
            results2.reserveCapacity(pullbacks.count)
            results3.reserveCapacity(pullbacks.count)

            precondition(v.count == pullbacks.count)

            for (tangentElement, pullback) in zip(v, pullbacks) {
                let (v1, v2, v3) = pullback(tangentElement)

                results1.appendContribution(of: v1)
                results2.appendContribution(of: v2)
                results3.appendContribution(of: v3)
            }

            return (
                results1,
                results2,
                results3
            )
        }
    )
}
