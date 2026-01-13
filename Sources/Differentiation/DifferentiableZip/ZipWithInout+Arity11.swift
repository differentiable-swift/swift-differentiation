
#if canImport(_Differentiation)
import _Differentiation

@inlinable
public func differentiableZipWith<Inout, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11>(
    _ c1: inout Inout,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    _ c5: C5,
    _ c6: C6,
    _ c7: C7,
    _ c8: C8,
    _ c9: C9,
    _ c10: C10,
    _ c11: C11,
    with transform: @differentiable(reverse) (
        Inout.Element,
        C2.Element,
        C3.Element,
        C4.Element,
        C5.Element,
        C6.Element,
        C7.Element,
        C8.Element,
        C9.Element,
        C10.Element,
        C11.Element
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
    C4.Element: Differentiable,
    C5: DifferentiableCollection,
    C5.Element: Differentiable,
    C6: DifferentiableCollection,
    C6.Element: Differentiable,
    C7: DifferentiableCollection,
    C7.Element: Differentiable,
    C8: DifferentiableCollection,
    C8.Element: Differentiable,
    C9: DifferentiableCollection,
    C9.Element: Differentiable,
    C10: DifferentiableCollection,
    C10.Element: Differentiable,
    C11: DifferentiableCollection,
    C11.Element: Differentiable
{
    let capacity = min(
        c1.count,
        c2.count,
        c3.count,
        c4.count,
        c5.count,
        c6.count,
        c7.count,
        c8.count,
        c9.count,
        c10.count,
        c11.count
    )

    if capacity == 0 { return }

    var c1i = c1.startIndex
    var c2i = c2.startIndex
    var c3i = c3.startIndex
    var c4i = c4.startIndex
    var c5i = c5.startIndex
    var c6i = c6.startIndex
    var c7i = c7.startIndex
    var c8i = c8.startIndex
    var c9i = c9.startIndex
    var c10i = c10.startIndex
    var c11i = c11.startIndex

    for _ in 0 ..< capacity {
        c1[c1i] = transform(
            c1[c1i],
            c2[c2i],
            c3[c3i],
            c4[c4i],
            c5[c5i],
            c6[c6i],
            c7[c7i],
            c8[c8i],
            c9[c9i],
            c10[c10i],
            c11[c11i]
        )
        c1.formIndex(after: &c1i)
        c2.formIndex(after: &c2i)
        c3.formIndex(after: &c3i)
        c4.formIndex(after: &c4i)
        c5.formIndex(after: &c5i)
        c6.formIndex(after: &c6i)
        c7.formIndex(after: &c7i)
        c8.formIndex(after: &c8i)
        c9.formIndex(after: &c9i)
        c10.formIndex(after: &c10i)
        c11.formIndex(after: &c11i)
    }
}

@derivative(of: differentiableZipWith)
@inlinable
public func _vjpDifferentiableZipWith<Inout, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11>(
    _ c1: inout Inout,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    _ c5: C5,
    _ c6: C6,
    _ c7: C7,
    _ c8: C8,
    _ c9: C9,
    _ c10: C10,
    _ c11: C11,
    with transform: @differentiable(reverse) (
        Inout.Element,
        C2.Element,
        C3.Element,
        C4.Element,
        C5.Element,
        C6.Element,
        C7.Element,
        C8.Element,
        C9.Element,
        C10.Element,
        C11.Element
    ) -> Inout.Element
) -> (
    value: Void,
    pullback: (inout Inout.TangentVector) -> (
        C2.TangentVector,
        C3.TangentVector,
        C4.TangentVector,
        C5.TangentVector,
        C6.TangentVector,
        C7.TangentVector,
        C8.TangentVector,
        C9.TangentVector,
        C10.TangentVector,
        C11.TangentVector
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
    C4.Element: Differentiable,
    C5: DifferentiableCollection,
    C5.Element: Differentiable,
    C6: DifferentiableCollection,
    C6.Element: Differentiable,
    C7: DifferentiableCollection,
    C7.Element: Differentiable,
    C8: DifferentiableCollection,
    C8.Element: Differentiable,
    C9: DifferentiableCollection,
    C9.Element: Differentiable,
    C10: DifferentiableCollection,
    C10.Element: Differentiable,
    C11: DifferentiableCollection,
    C11.Element: Differentiable
{
    let count = min(
        c1.count,
        c2.count,
        c3.count,
        c4.count,
        c5.count,
        c6.count,
        c7.count,
        c8.count,
        c9.count,
        c10.count,
        c11.count
    )

    if count == 0 {
        return (
            value: (),
            pullback: { _ in
                // swiftformat:disable:next redundantParens
                (
                    C2.TangentVector.zero,
                    C3.TangentVector.zero,
                    C4.TangentVector.zero,
                    C5.TangentVector.zero,
                    C6.TangentVector.zero,
                    C7.TangentVector.zero,
                    C8.TangentVector.zero,
                    C9.TangentVector.zero,
                    C10.TangentVector.zero,
                    C11.TangentVector.zero
                )
            }
        )
    }

    var pullbacks: ContiguousArray<(Inout.Element.TangentVector) -> (
        Inout.Element.TangentVector,
        C2.Element.TangentVector,
        C3.Element.TangentVector,
        C4.Element.TangentVector,
        C5.Element.TangentVector,
        C6.Element.TangentVector,
        C7.Element.TangentVector,
        C8.Element.TangentVector,
        C9.Element.TangentVector,
        C10.Element.TangentVector,
        C11.Element.TangentVector
    )> = []
    pullbacks.reserveCapacity(count)

    var c1i = c1.startIndex
    var c2i = c2.startIndex
    var c3i = c3.startIndex
    var c4i = c4.startIndex
    var c5i = c5.startIndex
    var c6i = c6.startIndex
    var c7i = c7.startIndex
    var c8i = c8.startIndex
    var c9i = c9.startIndex
    var c10i = c10.startIndex
    var c11i = c11.startIndex

    for _ in 0 ..< count {
        let (value, pullback) = valueWithPullback(
            at:
            c1[c1i],
            c2[c2i],
            c3[c3i],
            c4[c4i],
            c5[c5i],
            c6[c6i],
            c7[c7i],
            c8[c8i],
            c9[c9i],
            c10[c10i],
            c11[c11i],
            of: transform
        )

        c1[c1i] = value

        pullbacks.append(pullback)

        c1.formIndex(after: &c1i)
        c2.formIndex(after: &c2i)
        c3.formIndex(after: &c3i)
        c4.formIndex(after: &c4i)
        c5.formIndex(after: &c5i)
        c6.formIndex(after: &c6i)
        c7.formIndex(after: &c7i)
        c8.formIndex(after: &c8i)
        c9.formIndex(after: &c9i)
        c10.formIndex(after: &c10i)
        c11.formIndex(after: &c11i)
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
            var results5 = C5.TangentVector()
            results5.reserveCapacity(v.count)
            var results6 = C6.TangentVector()
            results6.reserveCapacity(v.count)
            var results7 = C7.TangentVector()
            results7.reserveCapacity(v.count)
            var results8 = C8.TangentVector()
            results8.reserveCapacity(v.count)
            var results9 = C9.TangentVector()
            results9.reserveCapacity(v.count)
            var results10 = C10.TangentVector()
            results10.reserveCapacity(v.count)
            var results11 = C11.TangentVector()
            results11.reserveCapacity(v.count)
            for (index, (tangentElement, pullback)) in zip(v.indices, zip(v, pullbacks)) {
                let (v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11) = pullback(tangentElement)
                v[index] = v1
                results2.appendContribution(of: v2)
                results3.appendContribution(of: v3)
                results4.appendContribution(of: v4)
                results5.appendContribution(of: v5)
                results6.appendContribution(of: v6)
                results7.appendContribution(of: v7)
                results8.appendContribution(of: v8)
                results9.appendContribution(of: v9)
                results10.appendContribution(of: v10)
                results11.appendContribution(of: v11)
            }

            // swiftformat:disable:next redundantParens
            return (
                results2,
                results3,
                results4,
                results5,
                results6,
                results7,
                results8,
                results9,
                results10,
                results11
            )
        }
    )
}

#endif
