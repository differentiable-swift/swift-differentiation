
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
    var capacity = c1.count
    capacity = Swift.min(capacity, c2.count)
    capacity = Swift.min(capacity, c3.count)

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
    var count = c1.count
    count = Swift.min(count, c2.count)
    count = Swift.min(count, c3.count)

    if count == 0 {
        return (
            value: (),
            pullback: { _ in
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
            let n = pullbacks.count

            if v.count == 0 {
                return (
                    C2.TangentVector.zero,
                    C3.TangentVector.zero
                )
            }

            precondition(v.count == n)

            // `tangents2` is the driver: it runs each element pullback once, writes the `Inout`
            // tangent back into `v` in place (along `v`'s native indices — its index type need not be
            // `Int`), and stashes the remaining tangents (`C3` here; `C3…CN` in general) into scratch
            // buffers. The remaining tangents are then built by moving out of those buffers. Memory-safe
            // because of `init(count:_:)`'s once-per-index, in-order contract: every scratch slot is
            // initialized during the driver pass before it is moved (see
            // `DifferentiableCollectionTangentVector`).
            let scratch3 = UnsafeMutableBufferPointer<C3.Element.TangentVector>.allocate(capacity: n)
            defer { scratch3.deallocate() }

            var vi = v.startIndex
            let tangents2 = pullbacks.withUnsafeBufferPointer { pullbackBuffer in
                C2.TangentVector(count: n) { index in
                    let (v1, v2, v3) = pullbackBuffer[index](v[vi])
                    v[vi] = v1
                    scratch3.initializeElement(at: index, to: v3)
                    v.formIndex(after: &vi)
                    return v2
                }
            }

            let tangents3 = C3.TangentVector(count: n) { i in scratch3.moveElement(from: i) }

            return (
                tangents2,
                tangents3
            )
        }
    )
}
