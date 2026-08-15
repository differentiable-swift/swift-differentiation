
import _Differentiation

@inlinable
public func fusedZipWith<C1, C2>(
    _ c1: C1,
    _ c2: C2,
    with transform: @differentiable(reverse) (
        Double,
        Double
    ) -> Double
) -> [Double] where
    C1: DifferentiableCollection,
    C1.Element == Double,
    C2: DifferentiableCollection,
    C2.Element == Double
{
    var capacity = c1.count
    capacity = Swift.min(capacity, c2.count)

    if capacity == 0 { return [] }

    return [Double](unsafeUninitializedCapacity: capacity) { buffer, initializedCount in
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

@derivative(of: fusedZipWith)
@inlinable
public func _vjpFusedZipWith<C1, C2>(
    _ c1: C1,
    _ c2: C2,
    with transform: @differentiable(reverse) (
        Double,
        Double
    ) -> Double
) -> (
    value: [Double],
    pullback: ([Double].TangentVector) -> (
        C1.TangentVector,
        C2.TangentVector
    )
) where
    C1: DifferentiableCollection,
    C1.Element == Double,
    C2: DifferentiableCollection,
    C2.Element == Double
{
    var n = c1.count
    n = Swift.min(n, c2.count)

    if n == 0 {
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

    let gradientScratch1 = UnsafeMutableBufferPointer<Double.TangentVector>.allocate(capacity: n)
    let gradientScratch2 = UnsafeMutableBufferPointer<Double.TangentVector>.allocate(capacity: n)
    defer {
        gradientScratch1.deallocate()
        gradientScratch2.deallocate()
    }

    let results = [Double](unsafeUninitializedCapacity: n) { buffer, initializedCount in
        var c1i = c1.startIndex
        var c2i = c2.startIndex

        for i in 0 ..< n {
            let (value, pullback) = valueWithPullback(
                at:
                c1[c1i],
                c2[c2i],
                of: transform
            )

            let (v1, v2) = pullback(1.0)

            buffer.initializeElement(at: i, to: value)
            gradientScratch1.initializeElement(at: i, to: v1)
            gradientScratch2.initializeElement(at: i, to: v2)

            c1.formIndex(after: &c1i)
            c2.formIndex(after: &c2i)
        }

        initializedCount = n
    }

    let gradients1 = [Double].TangentVector(count: n) { i in
        gradientScratch1.moveElement(from: i)
    }
    let gradients2 = [Double].TangentVector(count: n) { i in
        gradientScratch2.moveElement(from: i)
    }

    return (
        value: results,
        pullback: { v in
            let tangentCount = v.count

            if tangentCount == 0 {
                return (C1.TangentVector.zero, C2.TangentVector.zero)
            }

            precondition(tangentCount == n)

            let scratch2 = UnsafeMutableBufferPointer<Double.TangentVector>.allocate(capacity: n)
            defer { scratch2.deallocate() }

            let tangents1 = v.withUnsafeContiguousStorage { vBuffer in
                C1.TangentVector(count: n) { i in
                    let v = vBuffer[i]
                    let g1 = gradients1[i]
                    let g2 = gradients2[i]
                    scratch2.initializeElement(at: i, to: v * g2)
                    return v * g1
                }
            }

            let tangents2 = C2.TangentVector(count: n) { i in scratch2.moveElement(from: i) }

            return (
                tangents1,
                tangents2
            )
        }
    )
}
