
import _Differentiation

/// A `fusedZipWith` variant where `transform` supplies the value and its partial derivatives
/// directly instead of being differentiated per element. This keeps the fused single-pass
/// structure but removes the per-element AD-through-a-closure-value overhead (opaque vjp call
/// plus pullback-closure allocation), so the recording pass stays a plain dense loop.
///
/// The caller is responsible for the partials being the true derivatives of the value;
/// nothing checks them.
@inlinable
public func fusedZipWithPartials<C1, C2>(
    _ c1: C1,
    _ c2: C2,
    with transform: (
        Double,
        Double
    ) -> (
        value: Double,
        partials: (Double, Double)
    )
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
            ).value
            buffer.initializeElement(at: i, to: value)
            c1.formIndex(after: &c1i)
            c2.formIndex(after: &c2i)
        }

        initializedCount = capacity
    }
}

@derivative(of: fusedZipWithPartials)
@inlinable
public func _vjpFusedZipWithPartials<C1, C2>(
    _ c1: C1,
    _ c2: C2,
    with transform: (
        Double,
        Double
    ) -> (
        value: Double,
        partials: (Double, Double)
    )
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
            let (value, partials) = transform(
                c1[c1i],
                c2[c2i]
            )

            buffer.initializeElement(at: i, to: value)
            gradientScratch1.initializeElement(at: i, to: partials.0)
            gradientScratch2.initializeElement(at: i, to: partials.1)

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
