
import _Differentiation

@inlinable
public func differentiableZipWith<C1, C2, C3, C4, Result>(
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    with transform: @differentiable(reverse) (
        C1.Element,
        C2.Element,
        C3.Element,
        C4.Element
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
    Result: Differentiable
{
    var capacity = c1.count
    capacity = Swift.min(capacity, c2.count)
    capacity = Swift.min(capacity, c3.count)
    capacity = Swift.min(capacity, c4.count)

    if capacity == 0 { return [] }

    var results = ContiguousArray<Result>()
    results.reserveCapacity(capacity)

    var c1i = c1.startIndex
    var c2i = c2.startIndex
    var c3i = c3.startIndex
    var c4i = c4.startIndex

    for _ in 0 ..< capacity {
        results.append(transform(
            c1[c1i],
            c2[c2i],
            c3[c3i],
            c4[c4i]
        ))
        c1.formIndex(after: &c1i)
        c2.formIndex(after: &c2i)
        c3.formIndex(after: &c3i)
        c4.formIndex(after: &c4i)
    }

    return Array(results)
}

@derivative(of: differentiableZipWith)
@inlinable
public func _vjpDifferentiableZipWith<C1, C2, C3, C4, Result>(
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    with transform: @differentiable(reverse) (
        C1.Element,
        C2.Element,
        C3.Element,
        C4.Element
    ) -> Result
) -> (
    value: [Result],
    pullback: ([Result].TangentVector) -> (
        C1.TangentVector,
        C2.TangentVector,
        C3.TangentVector,
        C4.TangentVector
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
    Result: Differentiable
{
    var count = c1.count
    count = Swift.min(count, c2.count)
    count = Swift.min(count, c3.count)
    count = Swift.min(count, c4.count)

    if count == 0 {
        return (
            value: [],
            pullback: { _ in
                (
                    C1.TangentVector.zero,
                    C2.TangentVector.zero,
                    C3.TangentVector.zero,
                    C4.TangentVector.zero
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
        C4.Element.TangentVector
    )> = []
    pullbacks.reserveCapacity(count)

    var c1i = c1.startIndex
    var c2i = c2.startIndex
    var c3i = c3.startIndex
    var c4i = c4.startIndex

    for _ in 0 ..< count {
        let (value, pullback) = valueWithPullback(
            at:
            c1[c1i],
            c2[c2i],
            c3[c3i],
            c4[c4i],
            of: transform
        )

        results.append(value)
        pullbacks.append(pullback)

        c1.formIndex(after: &c1i)
        c2.formIndex(after: &c2i)
        c3.formIndex(after: &c3i)
        c4.formIndex(after: &c4i)
    }

    return (
        value: Array(results),
        pullback: { v in
            var results1 = C1.TangentVector()
            var results2 = C2.TangentVector()
            var results3 = C3.TangentVector()
            var results4 = C4.TangentVector()

            results1.reserveCapacity(pullbacks.count)
            results2.reserveCapacity(pullbacks.count)
            results3.reserveCapacity(pullbacks.count)
            results4.reserveCapacity(pullbacks.count)

            if v.count == 0 {
                for pullback in pullbacks {
                    let (v1, v2, v3, v4) = pullback(.zero)
                    results1.appendContribution(of: v1)
                    results2.appendContribution(of: v2)
                    results3.appendContribution(of: v3)
                    results4.appendContribution(of: v4)
                }
            }
            else {
                precondition(v.count == pullbacks.count)

                for (tangentElement, pullback) in zip(v, pullbacks) {
                    let (v1, v2, v3, v4) = pullback(tangentElement)

                    results1.appendContribution(of: v1)
                    results2.appendContribution(of: v2)
                    results3.appendContribution(of: v3)
                    results4.appendContribution(of: v4)
                }
            }

            return (
                results1,
                results2,
                results3,
                results4
            )
        }
    )
}
