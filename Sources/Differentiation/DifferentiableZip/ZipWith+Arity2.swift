
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
    let capacity = min(
        c1.count,
        c2.count
    )

    if capacity == 0 { return [] }

    var results = ContiguousArray<Result>()
    results.reserveCapacity(capacity)

    var c1i = c1.startIndex
    var c2i = c2.startIndex

    for _ in 0 ..< capacity {
        results.append(transform(
            c1[c1i],
            c2[c2i]
        ))
        c1.formIndex(after: &c1i)
        c2.formIndex(after: &c2i)
    }

    return Array(results)
}

#if canImport(_Differentiation)

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
    let count = min(
        c1.count,
        c2.count
    )

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

    var results = ContiguousArray<Result>()
    results.reserveCapacity(count)
    var pullbacks: ContiguousArray<(Result.TangentVector) -> (
        C1.Element.TangentVector,
        C2.Element.TangentVector
    )> = []
    pullbacks.reserveCapacity(count)

    var c1i = c1.startIndex
    var c2i = c2.startIndex

    for _ in 0 ..< count {
        let (value, pullback) = valueWithPullback(
            at:
            c1[c1i],
            c2[c2i],
            of: transform
        )

        results.append(value)
        pullbacks.append(pullback)

        c1.formIndex(after: &c1i)
        c2.formIndex(after: &c2i)
    }

    return (
        value: Array(results),
        pullback: { v in
            var results1 = C1.TangentVector()
            results1.reserveCapacity(v.count)
            var results2 = C2.TangentVector()
            results2.reserveCapacity(v.count)
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

#endif
