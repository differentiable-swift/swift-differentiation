
import _Differentiation

@inlinable
public func differentiableZipWith<Inout, C2, C3, C4, C5, C6, C7>(
    _ c1: inout Inout,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    _ c5: C5,
    _ c6: C6,
    _ c7: C7,
    with transform: @differentiable(reverse) (
        Inout.Element,
        C2.Element,
        C3.Element,
        C4.Element,
        C5.Element,
        C6.Element,
        C7.Element
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
    C7.Element: Differentiable
{
    var capacity = c1.count
    capacity = Swift.min(capacity, c2.count)
    capacity = Swift.min(capacity, c3.count)
    capacity = Swift.min(capacity, c4.count)
    capacity = Swift.min(capacity, c5.count)
    capacity = Swift.min(capacity, c6.count)
    capacity = Swift.min(capacity, c7.count)

    if capacity == 0 { return }

    var c1i = c1.startIndex
    var c2i = c2.startIndex
    var c3i = c3.startIndex
    var c4i = c4.startIndex
    var c5i = c5.startIndex
    var c6i = c6.startIndex
    var c7i = c7.startIndex

    for _ in 0 ..< capacity {
        c1[c1i] = transform(
            c1[c1i],
            c2[c2i],
            c3[c3i],
            c4[c4i],
            c5[c5i],
            c6[c6i],
            c7[c7i]
        )
        c1.formIndex(after: &c1i)
        c2.formIndex(after: &c2i)
        c3.formIndex(after: &c3i)
        c4.formIndex(after: &c4i)
        c5.formIndex(after: &c5i)
        c6.formIndex(after: &c6i)
        c7.formIndex(after: &c7i)
    }
}

@derivative(of: differentiableZipWith)
@inlinable
public func _vjpDifferentiableZipWith<Inout, C2, C3, C4, C5, C6, C7>(
    _ c1: inout Inout,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    _ c5: C5,
    _ c6: C6,
    _ c7: C7,
    with transform: @differentiable(reverse) (
        Inout.Element,
        C2.Element,
        C3.Element,
        C4.Element,
        C5.Element,
        C6.Element,
        C7.Element
    ) -> Inout.Element
) -> (
    value: Void,
    pullback: (inout Inout.TangentVector) -> (
        C2.TangentVector,
        C3.TangentVector,
        C4.TangentVector,
        C5.TangentVector,
        C6.TangentVector,
        C7.TangentVector
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
    C7.Element: Differentiable
{
    var count = c1.count
    count = Swift.min(count, c2.count)
    count = Swift.min(count, c3.count)
    count = Swift.min(count, c4.count)
    count = Swift.min(count, c5.count)
    count = Swift.min(count, c6.count)
    count = Swift.min(count, c7.count)

    if count == 0 {
        return (
            value: (),
            pullback: { _ in
                (
                    C2.TangentVector.zero,
                    C3.TangentVector.zero,
                    C4.TangentVector.zero,
                    C5.TangentVector.zero,
                    C6.TangentVector.zero,
                    C7.TangentVector.zero
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
        C7.Element.TangentVector
    )> = []
    pullbacks.reserveCapacity(count)

    var c1i = c1.startIndex
    var c2i = c2.startIndex
    var c3i = c3.startIndex
    var c4i = c4.startIndex
    var c5i = c5.startIndex
    var c6i = c6.startIndex
    var c7i = c7.startIndex

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
    }

    return (
        value: (),
        pullback: { v in
            let n = pullbacks.count

            if v.count == 0 {
                return (
                    C2.TangentVector.zero,
                    C3.TangentVector.zero,
                    C4.TangentVector.zero,
                    C5.TangentVector.zero,
                    C6.TangentVector.zero,
                    C7.TangentVector.zero
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
            let scratch4 = UnsafeMutableBufferPointer<C4.Element.TangentVector>.allocate(capacity: n)
            let scratch5 = UnsafeMutableBufferPointer<C5.Element.TangentVector>.allocate(capacity: n)
            let scratch6 = UnsafeMutableBufferPointer<C6.Element.TangentVector>.allocate(capacity: n)
            let scratch7 = UnsafeMutableBufferPointer<C7.Element.TangentVector>.allocate(capacity: n)
            defer { scratch3.deallocate() }
            defer { scratch4.deallocate() }
            defer { scratch5.deallocate() }
            defer { scratch6.deallocate() }
            defer { scratch7.deallocate() }

            var vi = v.startIndex
            let tangents2 = pullbacks.withUnsafeBufferPointer { pullbackBuffer in
                C2.TangentVector(count: n) { index in
                    let (v1, v2, v3, v4, v5, v6, v7) = pullbackBuffer[index](v[vi])
                    v[vi] = v1
                    scratch3.initializeElement(at: index, to: v3)
                    scratch4.initializeElement(at: index, to: v4)
                    scratch5.initializeElement(at: index, to: v5)
                    scratch6.initializeElement(at: index, to: v6)
                    scratch7.initializeElement(at: index, to: v7)
                    v.formIndex(after: &vi)
                    return v2
                }
            }

            let tangents3 = C3.TangentVector(count: n) { i in scratch3.moveElement(from: i) }
            let tangents4 = C4.TangentVector(count: n) { i in scratch4.moveElement(from: i) }
            let tangents5 = C5.TangentVector(count: n) { i in scratch5.moveElement(from: i) }
            let tangents6 = C6.TangentVector(count: n) { i in scratch6.moveElement(from: i) }
            let tangents7 = C7.TangentVector(count: n) { i in scratch7.moveElement(from: i) }

            return (
                tangents2,
                tangents3,
                tangents4,
                tangents5,
                tangents6,
                tangents7
            )
        }
    )
}
