
#if canImport(_Differentiation)
import _Differentiation

@inlinable
public func differentiableZipWith<Inout, C2, C3>(
    _ c1: inout Inout,
    _ c2: C2,
    _ c3: C3,
    with transform: @differentiable(reverse) (
        Inout.Element,
        C2.Element,
        C3.Element
    ) -> Inout.Element
) -> Void where
    Inout: MutableCollection,
    Inout: DifferentiableCollection,
    Inout.Element: Differentiable,
    C2: DifferentiableCollection,
    C2.Element: Differentiable,
    C3: DifferentiableCollection,
    C3.Element: Differentiable
{
    let capacity = min(
        c1.count,
        c2.count,
        c3.count
    )

    if capacity == 0 { return }

    var c1i = c1.startIndex
    var c2i = c2.startIndex
    var c3i = c3.startIndex

    for _ in 0 ..< capacity {
        c1[c1i] = transform(
            c1[c1i],
            c2[c2i],
            c3[c3i]
        )
        c1.formIndex(after: &c1i)
        c2.formIndex(after: &c2i)
        c3.formIndex(after: &c3i)
    }
}

@derivative(of: differentiableZipWith)
@inlinable
public func _vjpDifferentiableZipWith<Inout, C2, C3>(
    _ c1: inout Inout,
    _ c2: C2,
    _ c3: C3,
    with transform: @differentiable(reverse) (
        Inout.Element,
        C2.Element,
        C3.Element
    ) -> Inout.Element
) -> (
    value: Void,
    pullback: (inout Inout.TangentVector) -> (
        C2.TangentVector,
        C3.TangentVector
    )
) where
    Inout: MutableCollection,
    Inout.TangentVector: MutableCollection,
    Inout: DifferentiableCollection,
    Inout.Element: Differentiable,
    C2: DifferentiableCollection,
    C2.Element: Differentiable,
    C3: DifferentiableCollection,
    C3.Element: Differentiable
{
    let count = min(
        c1.count,
        c2.count,
        c3.count
    )

    if count == 0 {
        return (
            value: (),
            pullback: { _ in
                // swiftformat:disable:next redundantParens
                (
                    C2.TangentVector.zero,
                    C3.TangentVector.zero
                )
            }
        )
    }

    var pullbacks: ContiguousArray<(Inout.Element.TangentVector) -> (
        Inout.Element.TangentVector,
        C2.Element.TangentVector,
        C3.Element.TangentVector
    )> = []
    pullbacks.reserveCapacity(count)

    var c1i = c1.startIndex
    var c2i = c2.startIndex
    var c3i = c3.startIndex

    for _ in 0 ..< count {
        let (value, pullback) = valueWithPullback(
            at:
            c1[c1i],
            c2[c2i],
            c3[c3i],
            of: transform
        )

        c1[c1i] = value

        pullbacks.append(pullback)

        c1.formIndex(after: &c1i)
        c2.formIndex(after: &c2i)
        c3.formIndex(after: &c3i)
    }

    return (
        value: (),
        pullback: { v in
            precondition(v.count == pullbacks.count)

            var results2 = C2.TangentVector(repeating: .zero, count: v.count)
            var results3 = C3.TangentVector(repeating: .zero, count: v.count)
            var results2Index = results2.startIndex
            var results3Index = results3.startIndex

            for (index, (tangentElement, pullback)) in zip(v.indices, zip(v, pullbacks)) {
                let (v1, v2, v3) = pullback(tangentElement)
                v[index] = v1
                results2.writeTangentContribution(of: v2, at: results2Index)
                results3.writeTangentContribution(of: v3, at: results3Index)
                results2.formIndex(after: &results2Index)
                results3.formIndex(after: &results3Index)
            }

            // swiftformat:disable:next redundantParens
            return (
                results2,
                results3
            )
        }
    )
}

#endif
