
#if canImport(_Differentiation)
import _Differentiation

@inlinable
public func differentiableZipWith<Inout, C2, C3, C4>(
    _ c1: inout Inout,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    with transform: @differentiable(reverse) (
        Inout.Element,
        C2.Element,
        C3.Element,
        C4.Element
    ) -> Inout.Element
) -> Void where
    Inout: MutableCollection,
    Inout: DifferentiableCollection,
    Inout.Element: Differentiable,
    C2: DifferentiableCollection,
    C2.Element: Differentiable,
    C3: DifferentiableCollection,
    C3.Element: Differentiable,
    C4: DifferentiableCollection,
    C4.Element: Differentiable
{
    let capacity = min(
        c1.count,
        c2.count,
        c3.count,
        c4.count
    )

    if capacity == 0 { return }

    var c1i = c1.startIndex
    var c2i = c2.startIndex
    var c3i = c3.startIndex
    var c4i = c4.startIndex

    for _ in 0 ..< capacity {
        c1[c1i] = transform(
            c1[c1i],
            c2[c2i],
            c3[c3i],
            c4[c4i]
        )
        c1.formIndex(after: &c1i)
        c2.formIndex(after: &c2i)
        c3.formIndex(after: &c3i)
        c4.formIndex(after: &c4i)
    }
}

@derivative(of: differentiableZipWith)
@inlinable
public func _vjpDifferentiableZipWith<Inout, C2, C3, C4>(
    _ c1: inout Inout,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    with transform: @differentiable(reverse) (
        Inout.Element,
        C2.Element,
        C3.Element,
        C4.Element
    ) -> Inout.Element
) -> (
    value: Void,
    pullback: (inout Inout.TangentVector) -> (
        C2.TangentVector,
        C3.TangentVector,
        C4.TangentVector
    )
) where
    Inout: MutableCollection,
    Inout.TangentVector: MutableCollection,
    Inout: DifferentiableCollection,
    Inout.Element: Differentiable,
    C2: DifferentiableCollection,
    C2.Element: Differentiable,
    C3: DifferentiableCollection,
    C3.Element: Differentiable,
    C4: DifferentiableCollection,
    C4.Element: Differentiable
{
    let count = min(
        c1.count,
        c2.count,
        c3.count,
        c4.count
    )

    if count == 0 {
        return (
            value: (),
            pullback: { _ in
                // swiftformat:disable:next redundantParens
                (
                    C2.TangentVector.zero,
                    C3.TangentVector.zero,
                    C4.TangentVector.zero
                )
            }
        )
    }

    var pullbacks: ContiguousArray<(Inout.Element.TangentVector) -> (
        Inout.Element.TangentVector,
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

        c1[c1i] = value

        pullbacks.append(pullback)

        c1.formIndex(after: &c1i)
        c2.formIndex(after: &c2i)
        c3.formIndex(after: &c3i)
        c4.formIndex(after: &c4i)
    }

    return (
        value: (),
        pullback: { v in
            precondition(v.count == pullbacks.count)
            var results2 = C2.TangentVector()
            results2.reserveCapacity(v.count)
            var results3 = C3.TangentVector()
            results3.reserveCapacity(v.count)
            var results4 = C4.TangentVector()
            results4.reserveCapacity(v.count)
            for (index, (tangentElement, pullback)) in zip(v.indices, zip(v, pullbacks)) {
                let (v1, v2, v3, v4) = pullback(tangentElement)
                v[index] = v1
                results2.appendContribution(of: v2)
                results3.appendContribution(of: v3)
                results4.appendContribution(of: v4)
            }

            // swiftformat:disable:next redundantParens
            return (
                results2,
                results3,
                results4
            )
        }
    )
}

#endif
