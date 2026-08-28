
import _Differentiation

@inlinable
public func differentiableZipWith<Inout, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13>(
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
    _ c12: C12,
    _ c13: C13,
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
        C11.Element,
        C12.Element,
        C13.Element
    ) -> Inout.Element
) -> Void where
    Inout: MutableCollection,
    Inout: DifferentiableCollection,
    Inout.Element: Differentiable,
    C2: DifferentiableCollection,
    C3: DifferentiableCollection,
    C4: DifferentiableCollection,
    C5: DifferentiableCollection,
    C6: DifferentiableCollection,
    C7: DifferentiableCollection,
    C8: DifferentiableCollection,
    C9: DifferentiableCollection,
    C10: DifferentiableCollection,
    C11: DifferentiableCollection,
    C12: DifferentiableCollection,
    C13: DifferentiableCollection
{
    var capacity = c1.count
    capacity = Swift.min(capacity, c2.count)
    capacity = Swift.min(capacity, c3.count)
    capacity = Swift.min(capacity, c4.count)
    capacity = Swift.min(capacity, c5.count)
    capacity = Swift.min(capacity, c6.count)
    capacity = Swift.min(capacity, c7.count)
    capacity = Swift.min(capacity, c8.count)
    capacity = Swift.min(capacity, c9.count)
    capacity = Swift.min(capacity, c10.count)
    capacity = Swift.min(capacity, c11.count)
    capacity = Swift.min(capacity, c12.count)
    capacity = Swift.min(capacity, c13.count)

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
    var c12i = c12.startIndex
    var c13i = c13.startIndex

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
            c11[c11i],
            c12[c12i],
            c13[c13i]
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
        c12.formIndex(after: &c12i)
        c13.formIndex(after: &c13i)
    }
}

@derivative(of: differentiableZipWith)
@inlinable
public func _vjpDifferentiableZipWith<Inout, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13>(
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
    _ c12: C12,
    _ c13: C13,
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
        C11.Element,
        C12.Element,
        C13.Element
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
        C11.TangentVector,
        C12.TangentVector,
        C13.TangentVector
    )
) where
    Inout: MutableCollection,
    Inout.TangentVector: MutableCollection,
    Inout: DifferentiableCollection,
    Inout.Element: Differentiable,
    C2: DifferentiableCollection,
    C3: DifferentiableCollection,
    C4: DifferentiableCollection,
    C5: DifferentiableCollection,
    C6: DifferentiableCollection,
    C7: DifferentiableCollection,
    C8: DifferentiableCollection,
    C9: DifferentiableCollection,
    C10: DifferentiableCollection,
    C11: DifferentiableCollection,
    C12: DifferentiableCollection,
    C13: DifferentiableCollection
{
    var count = c1.count
    count = Swift.min(count, c2.count)
    count = Swift.min(count, c3.count)
    count = Swift.min(count, c4.count)
    count = Swift.min(count, c5.count)
    count = Swift.min(count, c6.count)
    count = Swift.min(count, c7.count)
    count = Swift.min(count, c8.count)
    count = Swift.min(count, c9.count)
    count = Swift.min(count, c10.count)
    count = Swift.min(count, c11.count)
    count = Swift.min(count, c12.count)
    count = Swift.min(count, c13.count)

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
                    C7.TangentVector.zero,
                    C8.TangentVector.zero,
                    C9.TangentVector.zero,
                    C10.TangentVector.zero,
                    C11.TangentVector.zero,
                    C12.TangentVector.zero,
                    C13.TangentVector.zero
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
        C11.Element.TangentVector,
        C12.Element.TangentVector,
        C13.Element.TangentVector
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
    var c12i = c12.startIndex
    var c13i = c13.startIndex

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
            c12[c12i],
            c13[c13i],
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
        c12.formIndex(after: &c12i)
        c13.formIndex(after: &c13i)
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
                    C7.TangentVector.zero,
                    C8.TangentVector.zero,
                    C9.TangentVector.zero,
                    C10.TangentVector.zero,
                    C11.TangentVector.zero,
                    C12.TangentVector.zero,
                    C13.TangentVector.zero
                )
            }

            precondition(v.count == n)

            // `tangents2` is the driver: it runs each element pullback once, writes the `Inout`
            // tangent back into `v` in place (along `v`'s native indices — its index type need not be
            // `Int`), and stashes the remaining tangents (`C3` here; `C3…CN` in general) into scratch
            // buffers. The remaining tangents are then built by moving out of those buffers. Memory-safe
            // because `building(count:_:)` guarantees a once-per-index, in-order visit: every scratch slot is
            // initialized during the driver pass before it is moved (see
            // `DifferentiableCollectionTangentVector`).
            let scratch3 = UnsafeMutableBufferPointer<C3.Element.TangentVector>.allocate(capacity: n)
            let scratch4 = UnsafeMutableBufferPointer<C4.Element.TangentVector>.allocate(capacity: n)
            let scratch5 = UnsafeMutableBufferPointer<C5.Element.TangentVector>.allocate(capacity: n)
            let scratch6 = UnsafeMutableBufferPointer<C6.Element.TangentVector>.allocate(capacity: n)
            let scratch7 = UnsafeMutableBufferPointer<C7.Element.TangentVector>.allocate(capacity: n)
            let scratch8 = UnsafeMutableBufferPointer<C8.Element.TangentVector>.allocate(capacity: n)
            let scratch9 = UnsafeMutableBufferPointer<C9.Element.TangentVector>.allocate(capacity: n)
            let scratch10 = UnsafeMutableBufferPointer<C10.Element.TangentVector>.allocate(capacity: n)
            let scratch11 = UnsafeMutableBufferPointer<C11.Element.TangentVector>.allocate(capacity: n)
            let scratch12 = UnsafeMutableBufferPointer<C12.Element.TangentVector>.allocate(capacity: n)
            let scratch13 = UnsafeMutableBufferPointer<C13.Element.TangentVector>.allocate(capacity: n)
            defer { scratch3.deallocate() }
            defer { scratch4.deallocate() }
            defer { scratch5.deallocate() }
            defer { scratch6.deallocate() }
            defer { scratch7.deallocate() }
            defer { scratch8.deallocate() }
            defer { scratch9.deallocate() }
            defer { scratch10.deallocate() }
            defer { scratch11.deallocate() }
            defer { scratch12.deallocate() }
            defer { scratch13.deallocate() }

            var vi = v.startIndex
            let tangents2 = pullbacks.withUnsafeBufferPointer { pullbackBuffer in
                C2.TangentVector.building(count: n) { index in
                    let (v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13) = pullbackBuffer[index](v[vi])
                    v[vi] = v1
                    scratch3.initializeElement(at: index, to: v3)
                    scratch4.initializeElement(at: index, to: v4)
                    scratch5.initializeElement(at: index, to: v5)
                    scratch6.initializeElement(at: index, to: v6)
                    scratch7.initializeElement(at: index, to: v7)
                    scratch8.initializeElement(at: index, to: v8)
                    scratch9.initializeElement(at: index, to: v9)
                    scratch10.initializeElement(at: index, to: v10)
                    scratch11.initializeElement(at: index, to: v11)
                    scratch12.initializeElement(at: index, to: v12)
                    scratch13.initializeElement(at: index, to: v13)
                    v.formIndex(after: &vi)
                    return v2
                }
            }

            let tangents3 = C3.TangentVector.building(count: n) { i in scratch3.moveElement(from: i) }
            let tangents4 = C4.TangentVector.building(count: n) { i in scratch4.moveElement(from: i) }
            let tangents5 = C5.TangentVector.building(count: n) { i in scratch5.moveElement(from: i) }
            let tangents6 = C6.TangentVector.building(count: n) { i in scratch6.moveElement(from: i) }
            let tangents7 = C7.TangentVector.building(count: n) { i in scratch7.moveElement(from: i) }
            let tangents8 = C8.TangentVector.building(count: n) { i in scratch8.moveElement(from: i) }
            let tangents9 = C9.TangentVector.building(count: n) { i in scratch9.moveElement(from: i) }
            let tangents10 = C10.TangentVector.building(count: n) { i in scratch10.moveElement(from: i) }
            let tangents11 = C11.TangentVector.building(count: n) { i in scratch11.moveElement(from: i) }
            let tangents12 = C12.TangentVector.building(count: n) { i in scratch12.moveElement(from: i) }
            let tangents13 = C13.TangentVector.building(count: n) { i in scratch13.moveElement(from: i) }

            return (
                tangents2,
                tangents3,
                tangents4,
                tangents5,
                tangents6,
                tangents7,
                tangents8,
                tangents9,
                tangents10,
                tangents11,
                tangents12,
                tangents13
            )
        }
    )
}
