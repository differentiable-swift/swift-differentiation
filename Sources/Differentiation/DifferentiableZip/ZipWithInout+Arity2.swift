
import _Differentiation

@inlinable
public func differentiableZipWith<Inout, C2>(
    _ c1: inout Inout,
    _ c2: C2,
    with transform: @differentiable(reverse) (
        Inout.Element,
        C2.Element
    ) -> Inout.Element
) -> Void where
    Inout: MutableCollection,
    Inout: DifferentiableCollection,
    Inout.Element: Differentiable,
    C2: DifferentiableCollection,
    C2.Element: Differentiable
{
    var capacity = c1.count
    capacity = Swift.min(capacity, c2.count)

    if capacity == 0 { return }

    var c1i = c1.startIndex
    var c2i = c2.startIndex

    for _ in 0 ..< capacity {
        c1[c1i] = transform(
            c1[c1i],
            c2[c2i]
        )
        c1.formIndex(after: &c1i)
        c2.formIndex(after: &c2i)
    }
}

@derivative(of: differentiableZipWith)
@inlinable
public func _vjpDifferentiableZipWith<Inout, C2>(
    _ c1: inout Inout,
    _ c2: C2,
    with transform: @differentiable(reverse) (
        Inout.Element,
        C2.Element
    ) -> Inout.Element
) -> (
    value: Void,
    pullback: (inout Inout.TangentVector) -> (
        C2.TangentVector
    )
) where
    Inout: MutableCollection,
    Inout.TangentVector: MutableCollection,
    Inout: DifferentiableCollection,
    Inout.Element: Differentiable,
    C2: DifferentiableCollection,
    C2.Element: Differentiable
{
    var count = c1.count
    count = Swift.min(count, c2.count)

    if count == 0 {
        return (
            value: (),
            pullback: { _ in
                C2.TangentVector.zero
            }
        )
    }

    let pullbacks = ContiguousArray<(Inout.Element.TangentVector) -> (
        Inout.Element.TangentVector,
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

            c1[c1i] = value

            pullbacksBuffer.initializeElement(at: i, to: pullback)

            c1.formIndex(after: &c1i)
            c2.formIndex(after: &c2i)
        }

        pullbacksInitializedCount = count
    }

    return (
        value: (),
        pullback: { v in
            if v.count == 0 {
                return C2.TangentVector.zero
            }

            let n = pullbacks.count
            precondition(v.count == n)

            let tangents2 = pullbacks.withUnsafeBufferPointer { pullbackBuffer in
                var vi = v.startIndex
                return C2.TangentVector.building(count: v.count) { index in
                    let (v1, v2) = pullbackBuffer[index](v[vi])
                    v[vi] = v1

                    v.formIndex(after: &vi)
                    return v2
                }
            }

            return tangents2
        }
    )
}
