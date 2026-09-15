
import _Differentiation

@inlinable
public func fusedZip<C1, C2, Result>(
    _ c1: C1,
    _ c2: C2,
    with transform: @differentiable(reverse) (
        C1.Element,
        C2.Element
    ) -> Result
) -> [Result] where
    Result: BinaryFloatingPoint,
    Result: Differentiable,
    Result.TangentVector == Result,
    C1: DifferentiableCollection,
    C2: DifferentiableCollection
{
    var capacity = c1.count
    capacity = Swift.min(capacity, c2.count)

    if capacity == 0 { return [] }

    return [Result](unsafeUninitializedCapacity: capacity) { buffer, initializedCount in
        var c1i = c1.startIndex
        var c2i = c2.startIndex
        for i in 0 ..< capacity {
            let value = transform(
                c1[c1i],
                c2[c2i]
            )
            buffer.initializeElement(at: i, to: value)
            c1.formIndex(after: &c1i)
            c2.formIndex(after: &c2i)
        }
        initializedCount = capacity
    }
}

@derivative(of: fusedZip)
@inlinable
public func _vjpFusedZip<C1, C2, Result>(
    _ c1: C1,
    _ c2: C2,
    with transform: @differentiable(reverse) (
        C1.Element,
        C2.Element
    ) -> Result
) -> (
    value: [Result],
    pullback: ([Result].TangentVector) -> (
        C1.TangentVector,
        C2.TangentVector
    )
) where
    Result: BinaryFloatingPoint,
    Result: Differentiable,
    Result.TangentVector == Result,
    C1: DifferentiableCollection,
    C2: DifferentiableCollection,
    C1.Element.TangentVector: ScalableByBinaryFloatingPoint,
    C2.Element.TangentVector: ScalableByBinaryFloatingPoint
{
    var count = c1.count
    count = Swift.min(count, c2.count)

    if count == 0 {
        return (
            value: [],
            pullback: { _ in
                (
                    C1.TangentVector.zero,
                    C2.TangentVector.zero
                )
            }
        )
    }

    var gradients1Storage: [C1.Element.TangentVector]!
    var gradients2Storage: [C2.Element.TangentVector]!
    let results = [Result](unsafeUninitializedCapacity: count) { resultsBuffer, initializedCount0 in
        gradients1Storage = [C1.Element.TangentVector](unsafeUninitializedCapacity: count) { gradients1Buffer, initializedCount1 in
            gradients2Storage = [C2.Element.TangentVector](unsafeUninitializedCapacity: count) { gradients2Buffer, initializedCount2 in
                var c1i = c1.startIndex
                var c2i = c2.startIndex
                for i in 0 ..< count {
                    let (value, pullback) = valueWithPullback(
                        at:
                        c1[c1i],
                        c2[c2i],
                        of: transform
                    )

                    let (g1, g2) = pullback(1.0)
                    resultsBuffer.initializeElement(at: i, to: value)
                    gradients1Buffer.initializeElement(at: i, to: g1)
                    gradients2Buffer.initializeElement(at: i, to: g2)

                    c1.formIndex(after: &c1i)
                    c2.formIndex(after: &c2i)
                }
                initializedCount0 = count
                initializedCount1 = count
                initializedCount2 = count
            }
        }
    }
    let gradients1: [C1.Element.TangentVector] = gradients1Storage
    let gradients2: [C2.Element.TangentVector] = gradients2Storage

    return (
        value: results,
        pullback: { v in
            let n = v.count
            if n == 0 {
                return (
                    C1.TangentVector.zero,
                    C2.TangentVector.zero
                )
            }
            return v.withUnsafeContiguousStorage { vBuffer in
                let tangents1 = C1.TangentVector.building(count: n) { i in gradients1[i].scaled(by: vBuffer[i]) }
                let tangents2 = C2.TangentVector.building(count: n) { i in gradients2[i].scaled(by: vBuffer[i]) }
                return (
                    tangents1,
                    tangents2
                )
            }
        }
    )
}
