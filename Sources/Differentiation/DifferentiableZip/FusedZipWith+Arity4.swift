
import _Differentiation

@inlinable
public func fusedZipWith<C1, C2, C3, C4>(
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    with transform: @differentiable(reverse) (
        Double,
        Double,
        Double,
        Double
    ) -> Double
) -> [Double] where
    C1: DifferentiableCollection,
    C1.Element == Double,
    C2: DifferentiableCollection,
    C2.Element == Double,
    C3: DifferentiableCollection,
    C3.Element == Double,
    C4: DifferentiableCollection,
    C4.Element == Double
{
    var capacity = c1.count
    capacity = Swift.min(capacity, c2.count)
    capacity = Swift.min(capacity, c3.count)
    capacity = Swift.min(capacity, c4.count)

    if capacity == 0 { return [] }

    return [Double](unsafeUninitializedCapacity: capacity) { buffer, initializedCount in
        var c1i = c1.startIndex
        var c2i = c2.startIndex
        var c3i = c3.startIndex
        var c4i = c4.startIndex

        for i in 0 ..< capacity {
            let value = transform(
                c1[c1i],
                c2[c2i],
                c3[c3i],
                c4[c4i]
            )
            buffer.initializeElement(at: i, to: value)
            c1.formIndex(after: &c1i)
            c2.formIndex(after: &c2i)
            c3.formIndex(after: &c3i)
            c4.formIndex(after: &c4i)
        }

        initializedCount = capacity
    }
}

@derivative(of: fusedZipWith)
@inlinable
public func _vjpFusedZipWith<C1, C2, C3, C4>(
    _ c1: C1,
    _ c2: C2,
    _ c3: C3,
    _ c4: C4,
    with transform: @differentiable(reverse) (
        Double,
        Double,
        Double,
        Double
    ) -> Double
) -> (
    value: [Double],
    pullback: ([Double].TangentVector) -> (
        C1.TangentVector,
        C2.TangentVector,
        C3.TangentVector,
        C4.TangentVector
    )
) where
    C1: DifferentiableCollection,
    C1.Element == Double,
    C2: DifferentiableCollection,
    C2.Element == Double,
    C3: DifferentiableCollection,
    C3.Element == Double,
    C4: DifferentiableCollection,
    C4.Element == Double
{
    var n = c1.count
    n = Swift.min(n, c2.count)
    n = Swift.min(n, c3.count)
    n = Swift.min(n, c4.count)

    if n == 0 {
        return (
            value: [],
            pullback: { _ in
                (
                    C1.TangentVector.zero,
                    C2.TangentVector.zero,
                    C3.TangentVector.zero,
                    C4.TangentVector.zero
                )
            }
        )
    }

    let gradientScratch1 = UnsafeMutableBufferPointer<Double.TangentVector>.allocate(capacity: n)
    let gradientScratch2 = UnsafeMutableBufferPointer<Double.TangentVector>.allocate(capacity: n)
    let gradientScratch3 = UnsafeMutableBufferPointer<Double.TangentVector>.allocate(capacity: n)
    let gradientScratch4 = UnsafeMutableBufferPointer<Double.TangentVector>.allocate(capacity: n)
    defer {
        gradientScratch1.deallocate()
        gradientScratch2.deallocate()
        gradientScratch3.deallocate()
        gradientScratch4.deallocate()
    }

    let results = [Double](unsafeUninitializedCapacity: n) { buffer, initializedCount in
        var c1i = c1.startIndex
        var c2i = c2.startIndex
        var c3i = c3.startIndex
        var c4i = c4.startIndex

        for i in 0 ..< n {
            let (value, pullback) = valueWithPullback(
                at:
                c1[c1i],
                c2[c2i],
                c3[c3i],
                c4[c4i],
                of: transform
            )

            let (v1, v2, v3, v4) = pullback(1.0)

            buffer.initializeElement(at: i, to: value)
            gradientScratch1.initializeElement(at: i, to: v1)
            gradientScratch2.initializeElement(at: i, to: v2)
            gradientScratch3.initializeElement(at: i, to: v3)
            gradientScratch4.initializeElement(at: i, to: v4)

            c1.formIndex(after: &c1i)
            c2.formIndex(after: &c2i)
            c3.formIndex(after: &c3i)
            c4.formIndex(after: &c4i)
        }

        initializedCount = n
    }

    let gradients1 = [Double].TangentVector(count: n) { i in
        gradientScratch1.moveElement(from: i)
    }
    let gradients2 = [Double].TangentVector(count: n) { i in
        gradientScratch2.moveElement(from: i)
    }
    let gradients3 = [Double].TangentVector(count: n) { i in
        gradientScratch3.moveElement(from: i)
    }
    let gradients4 = [Double].TangentVector(count: n) { i in
        gradientScratch4.moveElement(from: i)
    }

    return (
        value: results,
        pullback: { v in
            let tangentCount = v.count

            if tangentCount == 0 {
                return (
                    C1.TangentVector.zero,
                    C2.TangentVector.zero,
                    C3.TangentVector.zero,
                    C4.TangentVector.zero
                )
            }

            precondition(tangentCount == n)

            let scratch2 = UnsafeMutableBufferPointer<Double.TangentVector>.allocate(capacity: n)
            let scratch3 = UnsafeMutableBufferPointer<Double.TangentVector>.allocate(capacity: n)
            let scratch4 = UnsafeMutableBufferPointer<Double.TangentVector>.allocate(capacity: n)
            defer {
                scratch2.deallocate()
                scratch3.deallocate()
                scratch4.deallocate()
            }

            let tangents1 = v.withUnsafeContiguousStorage { vBuffer in
                C1.TangentVector(count: n) { i in
                    let v = vBuffer[i]
                    let g1 = gradients1[i]
                    let g2 = gradients2[i]
                    let g3 = gradients3[i]
                    let g4 = gradients4[i]
                    scratch2.initializeElement(at: i, to: v * g2)
                    scratch3.initializeElement(at: i, to: v * g3)
                    scratch4.initializeElement(at: i, to: v * g4)
                    return v * g1
                }
            }

            let tangents2 = C2.TangentVector(count: n) { i in scratch2.moveElement(from: i) }
            let tangents3 = C3.TangentVector(count: n) { i in scratch3.moveElement(from: i) }
            let tangents4 = C4.TangentVector(count: n) { i in scratch4.moveElement(from: i) }

            return (
                tangents1,
                tangents2,
                tangents3,
                tangents4
            )
        }
    )
}
