
import _Differentiation

@inlinable
public func fusedZip<C1, C2, C3, Result>(
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    with transform: @differentiable(reverse) (
        C1.Element,
        C2.Element,
        C3.Element
    ) -> Result
) -> [Result] where
    Result: BinaryFloatingPoint,
    Result: Differentiable,
    Result.TangentVector == Result,
    C1: DifferentiableCollection,
    C2: DifferentiableCollection,
    C3: DifferentiableCollection
{
    var capacity = c1.count
    capacity = Swift.min(capacity, c2.count)
    capacity = Swift.min(capacity, c3.count)

    if capacity == 0 { return [] }

    return [Result](unsafeUninitializedCapacity: capacity) { buffer, initializedCount in
        var c1i = c1.startIndex
        var c2i = c2.startIndex
        var c3i = c3.startIndex
        for i in 0 ..< capacity {
            let value = transform(
                c1[c1i],
                c2[c2i],
                c3[c3i]
            )
            buffer.initializeElement(at: i, to: value)
            c1.formIndex(after: &c1i)
            c2.formIndex(after: &c2i)
            c3.formIndex(after: &c3i)
        }
        initializedCount = capacity
    }
}

@derivative(of: fusedZip)
@inlinable
public func _vjpFusedZip<C1, C2, C3, Result>(
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    with transform: @differentiable(reverse) (
        C1.Element,
        C2.Element,
        C3.Element
    ) -> Result
) -> (
    value: [Result],
    pullback: ([Result].TangentVector) -> (
        C1.TangentVector,
        C2.TangentVector,
        C3.TangentVector
    )
) where
    Result: BinaryFloatingPoint,
    Result: Differentiable,
    Result.TangentVector == Result,
    C1: DifferentiableCollection,
    C2: DifferentiableCollection,
    C3: DifferentiableCollection,
    C1.Element.TangentVector: ScalableByBinaryFloatingPoint,
    C2.Element.TangentVector: ScalableByBinaryFloatingPoint,
    C3.Element.TangentVector: ScalableByBinaryFloatingPoint
{
    var count = c1.count
    count = Swift.min(count, c2.count)
    count = Swift.min(count, c3.count)

    if count == 0 {
        return (
            value: [],
            pullback: { _ in
                (
                    C1.TangentVector.zero,
                    C2.TangentVector.zero,
                    C3.TangentVector.zero
                )
            }
        )
    }

    var gradients1Storage: [C1.Element.TangentVector]!
    var gradients2Storage: [C2.Element.TangentVector]!
    var gradients3Storage: [C3.Element.TangentVector]!
    let results = [Result](unsafeUninitializedCapacity: count) { resultsBuffer, initializedCount0 in
        gradients1Storage = [C1.Element.TangentVector](unsafeUninitializedCapacity: count) { gradients1Buffer, initializedCount1 in
            gradients2Storage = [C2.Element.TangentVector](unsafeUninitializedCapacity: count) { gradients2Buffer, initializedCount2 in
                gradients3Storage = [C3.Element.TangentVector](unsafeUninitializedCapacity: count) { gradients3Buffer, initializedCount3 in
                    var c1i = c1.startIndex
                    var c2i = c2.startIndex
                    var c3i = c3.startIndex
                    for i in 0 ..< count {
                        let (value, pullback) = valueWithPullback(
                            at:
                            c1[c1i],
                            c2[c2i],
                            c3[c3i],
                            of: transform
                        )

                        let (g1, g2, g3) = pullback(1.0)
                        resultsBuffer.initializeElement(at: i, to: value)
                        gradients1Buffer.initializeElement(at: i, to: g1)
                        gradients2Buffer.initializeElement(at: i, to: g2)
                        gradients3Buffer.initializeElement(at: i, to: g3)

                        c1.formIndex(after: &c1i)
                        c2.formIndex(after: &c2i)
                        c3.formIndex(after: &c3i)
                    }
                    initializedCount0 = count
                    initializedCount1 = count
                    initializedCount2 = count
                    initializedCount3 = count
                }
            }
        }
    }
    let gradients1: [C1.Element.TangentVector] = gradients1Storage
    let gradients2: [C2.Element.TangentVector] = gradients2Storage
    let gradients3: [C3.Element.TangentVector] = gradients3Storage

    return (
        value: results,
        pullback: { v in
            let n = v.count
            if n == 0 {
                return (
                    C1.TangentVector.zero,
                    C2.TangentVector.zero,
                    C3.TangentVector.zero
                )
            }
            return v.withUnsafeContiguousStorage { vBuffer in
                let tangents1 = C1.TangentVector.building(count: n) { i in gradients1[i].scaled(by: vBuffer[i]) }
                let tangents2 = C2.TangentVector.building(count: n) { i in gradients2[i].scaled(by: vBuffer[i]) }
                let tangents3 = C3.TangentVector.building(count: n) { i in gradients3[i].scaled(by: vBuffer[i]) }
                return (
                    tangents1,
                    tangents2,
                    tangents3
                )
            }
        }
    )
}
