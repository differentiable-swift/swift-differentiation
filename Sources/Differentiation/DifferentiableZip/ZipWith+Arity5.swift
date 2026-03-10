
#if canImport(_Differentiation)
import _Differentiation

@inlinable
public func differentiableZipWith<C1, C2, C3, C4, C5, Result>(
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    _ c5: C5,
    with transform: @differentiable(reverse) (
        C1.Element,
        C2.Element,
        C3.Element,
        C4.Element,
        C5.Element
    ) -> Result
) -> [Result] where
    C1: DifferentiableCollection,
    C1.Element: Differentiable,
    C2: DifferentiableCollection,
    C2.Element: Differentiable,
    C3: DifferentiableCollection,
    C3.Element: Differentiable,
    C4: DifferentiableCollection,
    C4.Element: Differentiable,
    C5: DifferentiableCollection,
    C5.Element: Differentiable,
    Result: Differentiable
{
    let capacity = min(
        c1.count,
        c2.count,
        c3.count,
        c4.count,
        c5.count
    )

    if capacity == 0 { return [] }

    var results = ContiguousArray<Result>()
    results.reserveCapacity(capacity)

    var c1i = c1.startIndex
    var c2i = c2.startIndex
    var c3i = c3.startIndex
    var c4i = c4.startIndex
    var c5i = c5.startIndex

    for _ in 0 ..< capacity {
        results.append(transform(
            c1[c1i],
            c2[c2i],
            c3[c3i],
            c4[c4i],
            c5[c5i]
        ))
        c1.formIndex(after: &c1i)
        c2.formIndex(after: &c2i)
        c3.formIndex(after: &c3i)
        c4.formIndex(after: &c4i)
        c5.formIndex(after: &c5i)
    }

    return Array(results)
}

@derivative(of: differentiableZipWith)
@inlinable
public func _vjpDifferentiableZipWith<C1, C2, C3, C4, C5, Result>(
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    _ c5: C5,
    with transform: @differentiable(reverse) (
        C1.Element,
        C2.Element,
        C3.Element,
        C4.Element,
        C5.Element
    ) -> Result
) -> (
    value: [Result],
    pullback: ([Result].TangentVector) -> (
        C1.TangentVector,
        C2.TangentVector,
        C3.TangentVector,
        C4.TangentVector,
        C5.TangentVector
    )
) where
    C1: DifferentiableCollection,
    C1.Element: Differentiable,
    C2: DifferentiableCollection,
    C2.Element: Differentiable,
    C3: DifferentiableCollection,
    C3.Element: Differentiable,
    C4: DifferentiableCollection,
    C4.Element: Differentiable,
    C5: DifferentiableCollection,
    C5.Element: Differentiable,
    Result: Differentiable
{
    let count = min(
        c1.count,
        c2.count,
        c3.count,
        c4.count,
        c5.count
    )

    if count == 0 {
        return (
            value: [],
            pullback: { _ in
                (
                    C1.TangentVector.zero,
                    C2.TangentVector.zero,
                    C3.TangentVector.zero,
                    C4.TangentVector.zero,
                    C5.TangentVector.zero
                )
            }
        )
    }

    var results = ContiguousArray<Result>()
    results.reserveCapacity(count)
    var pullbacks: ContiguousArray<(Result.TangentVector) -> (
        C1.Element.TangentVector,
        C2.Element.TangentVector,
        C3.Element.TangentVector,
        C4.Element.TangentVector,
        C5.Element.TangentVector
    )> = []
    pullbacks.reserveCapacity(count)

    var c1i = c1.startIndex
    var c2i = c2.startIndex
    var c3i = c3.startIndex
    var c4i = c4.startIndex
    var c5i = c5.startIndex

    for _ in 0 ..< count {
        let (value, pullback) = valueWithPullback(
            at:
            c1[c1i],
            c2[c2i],
            c3[c3i],
            c4[c4i],
            c5[c5i],
            of: transform
        )

        results.append(value)
        pullbacks.append(pullback)

        c1.formIndex(after: &c1i)
        c2.formIndex(after: &c2i)
        c3.formIndex(after: &c3i)
        c4.formIndex(after: &c4i)
        c5.formIndex(after: &c5i)
    }

    return (
        value: Array(results),
        pullback: { v in
            precondition(v.count == pullbacks.count)

            var results1 = C1.TangentVector(repeating: .zero, count: v.count)
            var results2 = C2.TangentVector(repeating: .zero, count: v.count)
            var results3 = C3.TangentVector(repeating: .zero, count: v.count)
            var results4 = C4.TangentVector(repeating: .zero, count: v.count)
            var results5 = C5.TangentVector(repeating: .zero, count: v.count)
            var results1Index = results1.startIndex
            var results2Index = results2.startIndex
            var results3Index = results3.startIndex
            var results4Index = results4.startIndex
            var results5Index = results5.startIndex

            for (tangentElement, pullback) in zip(v, pullbacks) {
                let (v1, v2, v3, v4, v5) = pullback(tangentElement)
                results1.writeTangentContribution(of: v1, at: results1Index)
                results2.writeTangentContribution(of: v2, at: results2Index)
                results3.writeTangentContribution(of: v3, at: results3Index)
                results4.writeTangentContribution(of: v4, at: results4Index)
                results5.writeTangentContribution(of: v5, at: results5Index)
                results1.formIndex(after: &results1Index)
                results2.formIndex(after: &results2Index)
                results3.formIndex(after: &results3Index)
                results4.formIndex(after: &results4Index)
                results5.formIndex(after: &results5Index)
            }

            return (
                results1,
                results2,
                results3,
                results4,
                results5
            )
        }
    )
}

#endif
