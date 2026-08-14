
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

    var pullbacks: ContiguousArray<(Inout.Element.TangentVector) -> (
        Inout.Element.TangentVector,
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

        c1[c1i] = value

        pullbacks.append(pullback)

        c1.formIndex(after: &c1i)
        c2.formIndex(after: &c2i)
    }

    return (
        value: (),
        pullback: { v in
            let n = pullbacks.count

            if v.count == 0 {
                return C2.TangentVector.zero
            }

            precondition(v.count == n)

            // `tangents2` is the driver: it runs each element pullback once, writes the `Inout`
            // tangent back into `v` in place (along `v`'s native indices — its index type need not be
            // `Int`), and stashes the remaining tangents (`C3` here; `C3…CN` in general) into scratch
            // buffers. The remaining tangents are then built by moving out of those buffers. Memory-safe
            // because of `init(count:_:)`'s once-per-index, in-order contract: every scratch slot is
            // initialized during the driver pass before it is moved (see
            // `DifferentiableCollectionTangentVector`).

            var vi = v.startIndex
            let tangents2 = pullbacks.withUnsafeBufferPointer { pullbackBuffer in
                C2.TangentVector(count: n) { index in
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
