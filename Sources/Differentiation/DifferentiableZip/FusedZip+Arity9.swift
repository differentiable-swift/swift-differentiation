
import _Differentiation

@inlinable
public func fusedZip<C1, C2, C3, C4, C5, C6, C7, C8, C9, Result>(
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    _ c5: C5,
    _ c6: C6,
    _ c7: C7,
    _ c8: C8,
    _ c9: C9,
    with transform: @differentiable(reverse) (
        C1.Element,
        C2.Element,
        C3.Element,
        C4.Element,
        C5.Element,
        C6.Element,
        C7.Element,
        C8.Element,
        C9.Element
    ) -> Result
) -> [Result] where
    Result: BinaryFloatingPoint,
    Result: Differentiable,
    Result.TangentVector == Result,
    C1: DifferentiableCollection,
    C2: DifferentiableCollection,
    C3: DifferentiableCollection,
    C4: DifferentiableCollection,
    C5: DifferentiableCollection,
    C6: DifferentiableCollection,
    C7: DifferentiableCollection,
    C8: DifferentiableCollection,
    C9: DifferentiableCollection
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
                c9[c9i]
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
        }
        initializedCount = capacity
    }
}

@derivative(of: fusedZip)
@inlinable
public func _vjpFusedZip<C1, C2, C3, C4, C5, C6, C7, C8, C9, Result>(
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    _ c5: C5,
    _ c6: C6,
    _ c7: C7,
    _ c8: C8,
    _ c9: C9,
    with transform: @differentiable(reverse) (
        C1.Element,
        C2.Element,
        C3.Element,
        C4.Element,
        C5.Element,
        C6.Element,
        C7.Element,
        C8.Element,
        C9.Element
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
        C9.TangentVector
    )
) where
    Result: BinaryFloatingPoint,
    Result: Differentiable,
    Result.TangentVector == Result,
    C1: DifferentiableCollection,
    C2: DifferentiableCollection,
    C3: DifferentiableCollection,
    C4: DifferentiableCollection,
    C5: DifferentiableCollection,
    C6: DifferentiableCollection,
    C7: DifferentiableCollection,
    C8: DifferentiableCollection,
    C9: DifferentiableCollection,
    C1.Element.TangentVector: ScalableByBinaryFloatingPoint,
    C2.Element.TangentVector: ScalableByBinaryFloatingPoint,
    C3.Element.TangentVector: ScalableByBinaryFloatingPoint,
    C4.Element.TangentVector: ScalableByBinaryFloatingPoint,
    C5.Element.TangentVector: ScalableByBinaryFloatingPoint,
    C6.Element.TangentVector: ScalableByBinaryFloatingPoint,
    C7.Element.TangentVector: ScalableByBinaryFloatingPoint,
    C8.Element.TangentVector: ScalableByBinaryFloatingPoint,
    C9.Element.TangentVector: ScalableByBinaryFloatingPoint
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
                    C9.TangentVector.zero
                )
            }
        )
    }

    var gradients1Storage: [C1.Element.TangentVector]!
    var gradients2Storage: [C2.Element.TangentVector]!
    var gradients3Storage: [C3.Element.TangentVector]!
    var gradients4Storage: [C4.Element.TangentVector]!
    var gradients5Storage: [C5.Element.TangentVector]!
    var gradients6Storage: [C6.Element.TangentVector]!
    var gradients7Storage: [C7.Element.TangentVector]!
    var gradients8Storage: [C8.Element.TangentVector]!
    var gradients9Storage: [C9.Element.TangentVector]!
    let results = [Result](unsafeUninitializedCapacity: count) { resultsBuffer, initializedCount0 in
        gradients1Storage = [C1.Element.TangentVector](unsafeUninitializedCapacity: count) { gradients1Buffer, initializedCount1 in
            gradients2Storage = [C2.Element.TangentVector](unsafeUninitializedCapacity: count) { gradients2Buffer, initializedCount2 in
                gradients3Storage = [C3.Element.TangentVector](unsafeUninitializedCapacity: count) { gradients3Buffer, initializedCount3 in
                    gradients4Storage = [C4.Element.TangentVector](unsafeUninitializedCapacity: count) { gradients4Buffer,
                        initializedCount4 in
                        gradients5Storage = [C5.Element.TangentVector](unsafeUninitializedCapacity: count) { gradients5Buffer,
                            initializedCount5 in
                            gradients6Storage = [C6.Element.TangentVector](unsafeUninitializedCapacity: count) { gradients6Buffer,
                                initializedCount6 in
                                gradients7Storage = [C7.Element.TangentVector](unsafeUninitializedCapacity: count) { gradients7Buffer,
                                    initializedCount7 in
                                    gradients8Storage = [C8.Element.TangentVector](unsafeUninitializedCapacity: count) { gradients8Buffer,
                                        initializedCount8 in
                                        gradients9Storage = [C9.Element.TangentVector](unsafeUninitializedCapacity: count) {
                                            gradients9Buffer, initializedCount9 in
                                            var c1i = c1.startIndex
                                            var c2i = c2.startIndex
                                            var c3i = c3.startIndex
                                            var c4i = c4.startIndex
                                            var c5i = c5.startIndex
                                            var c6i = c6.startIndex
                                            var c7i = c7.startIndex
                                            var c8i = c8.startIndex
                                            var c9i = c9.startIndex
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
                                                    of: transform
                                                )

                                                let (g1, g2, g3, g4, g5, g6, g7, g8, g9) = pullback(1.0)
                                                resultsBuffer.initializeElement(at: i, to: value)
                                                gradients1Buffer.initializeElement(at: i, to: g1)
                                                gradients2Buffer.initializeElement(at: i, to: g2)
                                                gradients3Buffer.initializeElement(at: i, to: g3)
                                                gradients4Buffer.initializeElement(at: i, to: g4)
                                                gradients5Buffer.initializeElement(at: i, to: g5)
                                                gradients6Buffer.initializeElement(at: i, to: g6)
                                                gradients7Buffer.initializeElement(at: i, to: g7)
                                                gradients8Buffer.initializeElement(at: i, to: g8)
                                                gradients9Buffer.initializeElement(at: i, to: g9)

                                                c1.formIndex(after: &c1i)
                                                c2.formIndex(after: &c2i)
                                                c3.formIndex(after: &c3i)
                                                c4.formIndex(after: &c4i)
                                                c5.formIndex(after: &c5i)
                                                c6.formIndex(after: &c6i)
                                                c7.formIndex(after: &c7i)
                                                c8.formIndex(after: &c8i)
                                                c9.formIndex(after: &c9i)
                                            }
                                            initializedCount0 = count
                                            initializedCount1 = count
                                            initializedCount2 = count
                                            initializedCount3 = count
                                            initializedCount4 = count
                                            initializedCount5 = count
                                            initializedCount6 = count
                                            initializedCount7 = count
                                            initializedCount8 = count
                                            initializedCount9 = count
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    let gradients1: [C1.Element.TangentVector] = gradients1Storage
    let gradients2: [C2.Element.TangentVector] = gradients2Storage
    let gradients3: [C3.Element.TangentVector] = gradients3Storage
    let gradients4: [C4.Element.TangentVector] = gradients4Storage
    let gradients5: [C5.Element.TangentVector] = gradients5Storage
    let gradients6: [C6.Element.TangentVector] = gradients6Storage
    let gradients7: [C7.Element.TangentVector] = gradients7Storage
    let gradients8: [C8.Element.TangentVector] = gradients8Storage
    let gradients9: [C9.Element.TangentVector] = gradients9Storage

    return (
        value: results,
        pullback: { v in
            let n = v.count
            if n == 0 {
                return (
                    C1.TangentVector.zero,
                    C2.TangentVector.zero,
                    C3.TangentVector.zero,
                    C4.TangentVector.zero,
                    C5.TangentVector.zero,
                    C6.TangentVector.zero,
                    C7.TangentVector.zero,
                    C8.TangentVector.zero,
                    C9.TangentVector.zero
                )
            }
            return v.withUnsafeContiguousStorage { vBuffer in
                let tangents1 = C1.TangentVector.building(count: n) { i in gradients1[i].scaled(by: vBuffer[i]) }
                let tangents2 = C2.TangentVector.building(count: n) { i in gradients2[i].scaled(by: vBuffer[i]) }
                let tangents3 = C3.TangentVector.building(count: n) { i in gradients3[i].scaled(by: vBuffer[i]) }
                let tangents4 = C4.TangentVector.building(count: n) { i in gradients4[i].scaled(by: vBuffer[i]) }
                let tangents5 = C5.TangentVector.building(count: n) { i in gradients5[i].scaled(by: vBuffer[i]) }
                let tangents6 = C6.TangentVector.building(count: n) { i in gradients6[i].scaled(by: vBuffer[i]) }
                let tangents7 = C7.TangentVector.building(count: n) { i in gradients7[i].scaled(by: vBuffer[i]) }
                let tangents8 = C8.TangentVector.building(count: n) { i in gradients8[i].scaled(by: vBuffer[i]) }
                let tangents9 = C9.TangentVector.building(count: n) { i in gradients9[i].scaled(by: vBuffer[i]) }
                return (
                    tangents1,
                    tangents2,
                    tangents3,
                    tangents4,
                    tangents5,
                    tangents6,
                    tangents7,
                    tangents8,
                    tangents9
                )
            }
        }
    )
}
