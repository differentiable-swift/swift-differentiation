
import _Differentiation

@inlinable
public func differentiableZipWith<C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, Result>(
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    _ c5: C5,
    _ c6: C6,
    _ c7: C7,
    _ c8: C8,
    _ c9: C9,
    _ c10: C10,
    with transform: @differentiable(reverse) (
        C1.Element,
        C2.Element,
        C3.Element,
        C4.Element,
        C5.Element,
        C6.Element,
        C7.Element,
        C8.Element,
        C9.Element,
        C10.Element
    ) -> Result
) -> [Result] where
    C1: DifferentiableCollection,
    C2: DifferentiableCollection,
    C3: DifferentiableCollection,
    C4: DifferentiableCollection,
    C5: DifferentiableCollection,
    C6: DifferentiableCollection,
    C7: DifferentiableCollection,
    C8: DifferentiableCollection,
    C9: DifferentiableCollection,
    C10: DifferentiableCollection,
    Result: Differentiable
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

    if capacity == 0 { return [] }

    return [Result](unsafeUninitializedCapacity: capacity) { buffer, initializedCount in
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

        for i in 0 ..< capacity {
            let value = transform(
                c1[c1i],
                c2[c2i],
                c3[c3i],
                c4[c4i],
                c5[c5i],
                c6[c6i],
                c7[c7i],
                c8[c8i],
                c9[c9i],
                c10[c10i]
            )
            buffer.initializeElement(at: i, to: value)
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
        }

        initializedCount = capacity
    }
}

@derivative(of: differentiableZipWith)
@inlinable
public func _vjpDifferentiableZipWith<C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, Result>(
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    _ c5: C5,
    _ c6: C6,
    _ c7: C7,
    _ c8: C8,
    _ c9: C9,
    _ c10: C10,
    with transform: @differentiable(reverse) (
        C1.Element,
        C2.Element,
        C3.Element,
        C4.Element,
        C5.Element,
        C6.Element,
        C7.Element,
        C8.Element,
        C9.Element,
        C10.Element
    ) -> Result
) -> (
    value: [Result],
    pullback: ([Result].TangentVector) -> (
        C1.TangentVector,
        C2.TangentVector,
        C3.TangentVector,
        C4.TangentVector,
        C5.TangentVector,
        C6.TangentVector,
        C7.TangentVector,
        C8.TangentVector,
        C9.TangentVector,
        C10.TangentVector
    )
) where
    C1: DifferentiableCollection,
    C2: DifferentiableCollection,
    C3: DifferentiableCollection,
    C4: DifferentiableCollection,
    C5: DifferentiableCollection,
    C6: DifferentiableCollection,
    C7: DifferentiableCollection,
    C8: DifferentiableCollection,
    C9: DifferentiableCollection,
    C10: DifferentiableCollection,
    Result: Differentiable
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

    if count == 0 {
        return (
            value: [],
            pullback: { _ in
                (
                    C1.TangentVector.zero,
                    C2.TangentVector.zero,
                    C3.TangentVector.zero,
                    C4.TangentVector.zero,
                    C5.TangentVector.zero,
                    C6.TangentVector.zero,
                    C7.TangentVector.zero,
                    C8.TangentVector.zero,
                    C9.TangentVector.zero,
                    C10.TangentVector.zero
                )
            }
        )
    }

    var pullbacks: ContiguousArray<(Result.TangentVector) -> (
        C1.Element.TangentVector,
        C2.Element.TangentVector,
        C3.Element.TangentVector,
        C4.Element.TangentVector,
        C5.Element.TangentVector,
        C6.Element.TangentVector,
        C7.Element.TangentVector,
        C8.Element.TangentVector,
        C9.Element.TangentVector,
        C10.Element.TangentVector
    )> = []
    pullbacks.reserveCapacity(count)

    let results = [Result](unsafeUninitializedCapacity: count) { buffer, initializedCount in
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

        for i in 0 ..< count {
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
                of: transform
            )

            buffer.initializeElement(at: i, to: value)
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
        }

        initializedCount = count
    }

    return (
        value: results,
        pullback: { v in
            // if the incoming tangent is empty (ie. .zero) we can exit early due to the linear nature of the pullback.
            if v.count == 0 {
                return (
                    C1.TangentVector.zero,
                    C2.TangentVector.zero,
                    C3.TangentVector.zero,
                    C4.TangentVector.zero,
                    C5.TangentVector.zero,
                    C6.TangentVector.zero,
                    C7.TangentVector.zero,
                    C8.TangentVector.zero,
                    C9.TangentVector.zero,
                    C10.TangentVector.zero
                )
            }

            let n = pullbacks.count
            precondition(v.count == n)

            // Scratch is initialized while building `tangents1` and moved out while building the
            // rest. This is memory-safe because `building(count:_:)` guarantees a once-per-index, in-order visit
            // (see `DifferentiableCollectionTangentVector`).
            let scratch2 = UnsafeMutableBufferPointer<C2.Element.TangentVector>.allocate(capacity: n)
            let scratch3 = UnsafeMutableBufferPointer<C3.Element.TangentVector>.allocate(capacity: n)
            let scratch4 = UnsafeMutableBufferPointer<C4.Element.TangentVector>.allocate(capacity: n)
            let scratch5 = UnsafeMutableBufferPointer<C5.Element.TangentVector>.allocate(capacity: n)
            let scratch6 = UnsafeMutableBufferPointer<C6.Element.TangentVector>.allocate(capacity: n)
            let scratch7 = UnsafeMutableBufferPointer<C7.Element.TangentVector>.allocate(capacity: n)
            let scratch8 = UnsafeMutableBufferPointer<C8.Element.TangentVector>.allocate(capacity: n)
            let scratch9 = UnsafeMutableBufferPointer<C9.Element.TangentVector>.allocate(capacity: n)
            let scratch10 = UnsafeMutableBufferPointer<C10.Element.TangentVector>.allocate(capacity: n)
            defer { scratch2.deallocate() }
            defer { scratch3.deallocate() }
            defer { scratch4.deallocate() }
            defer { scratch5.deallocate() }
            defer { scratch6.deallocate() }
            defer { scratch7.deallocate() }
            defer { scratch8.deallocate() }
            defer { scratch9.deallocate() }
            defer { scratch10.deallocate() }

            let tangents1 = v.withUnsafeContiguousStorage { vBuffer in
                pullbacks.withUnsafeBufferPointer { pullbackBuffer in
                    C1.TangentVector.building(count: n) { index in
                        let (v1, v2, v3, v4, v5, v6, v7, v8, v9, v10) = pullbackBuffer[index](vBuffer[index])
                        scratch2.initializeElement(at: index, to: v2)
                        scratch3.initializeElement(at: index, to: v3)
                        scratch4.initializeElement(at: index, to: v4)
                        scratch5.initializeElement(at: index, to: v5)
                        scratch6.initializeElement(at: index, to: v6)
                        scratch7.initializeElement(at: index, to: v7)
                        scratch8.initializeElement(at: index, to: v8)
                        scratch9.initializeElement(at: index, to: v9)
                        scratch10.initializeElement(at: index, to: v10)
                        return v1
                    }
                }
            }

            let tangents2 = C2.TangentVector.building(count: n) { i in scratch2.moveElement(from: i) }
            let tangents3 = C3.TangentVector.building(count: n) { i in scratch3.moveElement(from: i) }
            let tangents4 = C4.TangentVector.building(count: n) { i in scratch4.moveElement(from: i) }
            let tangents5 = C5.TangentVector.building(count: n) { i in scratch5.moveElement(from: i) }
            let tangents6 = C6.TangentVector.building(count: n) { i in scratch6.moveElement(from: i) }
            let tangents7 = C7.TangentVector.building(count: n) { i in scratch7.moveElement(from: i) }
            let tangents8 = C8.TangentVector.building(count: n) { i in scratch8.moveElement(from: i) }
            let tangents9 = C9.TangentVector.building(count: n) { i in scratch9.moveElement(from: i) }
            let tangents10 = C10.TangentVector.building(count: n) { i in scratch10.moveElement(from: i) }

            return (
                tangents1,
                tangents2,
                tangents3,
                tangents4,
                tangents5,
                tangents6,
                tangents7,
                tangents8,
                tangents9,
                tangents10
            )
        }
    )
}
