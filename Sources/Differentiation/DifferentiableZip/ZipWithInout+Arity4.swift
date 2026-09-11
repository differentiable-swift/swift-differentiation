
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
    var capacity = c1.count
    capacity = Swift.min(capacity, c2.count)
    capacity = Swift.min(capacity, c3.count)
    capacity = Swift.min(capacity, c4.count)

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
    var count = c1.count
    count = Swift.min(count, c2.count)
    count = Swift.min(count, c3.count)
    count = Swift.min(count, c4.count)

    if count == 0 {
        return (
            value: (),
            pullback: { _ in
                (
                    C2.TangentVector.zero,
                    C3.TangentVector.zero,
                    C4.TangentVector.zero
                )
            }
        )
    }

    let pullbacks = ContiguousArray<(Inout.Element.TangentVector) -> (
        Inout.Element.TangentVector,
        C2.Element.TangentVector,
        C3.Element.TangentVector,
        C4.Element.TangentVector
    )>(unsafeUninitializedCapacity: count) { pullbacksBuffer, pullbacksInitializedCount in
        var c1i = c1.startIndex
        var c2i = c2.startIndex
        var c3i = c3.startIndex
        var c4i = c4.startIndex

        for i in 0 ..< count {
            let (value, pullback) = valueWithPullback(
                at:
                c1[c1i],
                c2[c2i],
                c3[c3i],
                c4[c4i],
                of: transform
            )

            c1[c1i] = value

            pullbacksBuffer.initializeElement(at: i, to: pullback)

            c1.formIndex(after: &c1i)
            c2.formIndex(after: &c2i)
            c3.formIndex(after: &c3i)
            c4.formIndex(after: &c4i)
        }

        pullbacksInitializedCount = count
    }

    return (
        value: (),
        pullback: { v in
            if v.count == 0 {
                return (
                    C2.TangentVector.zero,
                    C3.TangentVector.zero,
                    C4.TangentVector.zero
                )
            }

            let n = pullbacks.count
            precondition(v.count == n)

            let scratch3 = UnsafeMutableBufferPointer<C3.Element.TangentVector>.allocate(capacity: n)
            let scratch4 = UnsafeMutableBufferPointer<C4.Element.TangentVector>.allocate(capacity: n)
            defer { scratch3.deallocate() }
            defer { scratch4.deallocate() }

            let tangents2 = pullbacks.withUnsafeBufferPointer { pullbackBuffer in
                var vi = v.startIndex
                return C2.TangentVector.building(count: v.count) { index in
                    let (v1, v2, v3, v4) = pullbackBuffer[index](v[vi])
                    v[vi] = v1
                    scratch3.initializeElement(at: index, to: v3)
                    scratch4.initializeElement(at: index, to: v4)

                    v.formIndex(after: &vi)
                    return v2
                }
            }

            let tangents3 = C3.TangentVector.building(count: n) { i in scratch3.moveElement(from: i) }
            let tangents4 = C4.TangentVector.building(count: n) { i in scratch4.moveElement(from: i) }

            return (
                tangents2,
                tangents3,
                tangents4
            )
        }
    )
}
