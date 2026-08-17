import DifferentiableOperators
import Differentiation
import Testing

/// Same math, different rounding: the operator pullbacks and the fused per-element AD
/// evaluate algebraically equal expressions in different forms (e.g. `-d·lhs·(1/r)²` vs
/// `-(a·b + c)/d²`), so gradients can differ by a few ulps.
private func approxEqual(
    _ lhs: Array<Double>.DifferentiableView,
    _ rhs: Array<Double>.DifferentiableView,
    relativeTolerance: Double = 1e-12
) -> Bool {
    lhs.count == rhs.count && zip(lhs.base, rhs.base).allSatisfy { l, r in
        abs(l - r) <= relativeTolerance * max(abs(l), abs(r), 1)
    }
}

@Suite
struct FusedZipWithTests {
    /// The chained-operators path and the fusedZipWith path must produce the same
    /// values and the same gradients for `(a * b + c) / d`.
    @Test
    func operatorsAndFusedAgree() {
        let a = (0 ..< 32).map { _ in Double.random(in: 0.5 ... 2.0) }
        let b = (0 ..< 32).map { _ in Double.random(in: 0.5 ... 2.0) }
        let c = (0 ..< 32).map { _ in Double.random(in: 0.5 ... 2.0) }
        let d = (0 ..< 32).map { _ in Double.random(in: 0.5 ... 2.0) }

        let operators = valueWithPullback4(at: a, b, c, d, of: { a, b, c, d in
            (a .* b .+ c) ./ d
        })
        let fused = valueWithPullback4(at: a, b, c, d, of: { a, b, c, d in
            fusedZipWith(a, b, c, d) { a, b, c, d in (a * b + c) / d }
        })

        #expect(operators.value == fused.value)

        var seed = Array.DifferentiableView([Double](repeating: 0, count: a.count))
        seed.base[3] = 1
        seed.base[17] = -2

        let zipWith = valueWithPullback4(at: a, b, c, d, of: { a, b, c, d in
            differentiableZipWith(a, b, c, d) { a, b, c, d in (a * b + c) / d }
        })

        #expect(operators.value == zipWith.value)

        let operatorGradients = operators.pullback(seed)
        let fusedGradients = fused.pullback(seed)
        let zipWithGradients = zipWith.pullback(seed)

        #expect(approxEqual(operatorGradients.0, fusedGradients.0))
        #expect(approxEqual(operatorGradients.1, fusedGradients.1))
        #expect(approxEqual(operatorGradients.2, fusedGradients.2))
        #expect(approxEqual(operatorGradients.3, fusedGradients.3))

        #expect(approxEqual(operatorGradients.0, zipWithGradients.0))
        #expect(approxEqual(operatorGradients.1, zipWithGradients.1))
        #expect(approxEqual(operatorGradients.2, zipWithGradients.2))
        #expect(approxEqual(operatorGradients.3, zipWithGradients.3))

        // The hand-written partials in the benchmark's fusedZipWithPartials expression are
        // unchecked by construction, so verifying them against the AD paths matters most here.
        let partials = valueWithPullback4(at: a, b, c, d, of: { a, b, c, d in
            fusedZipWithPartials(a, b, c, d) { a, b, c, d in
                let invD = 1.0 / d
                let value = (a * b + c) * invD
                return (value, (b * invD, a * invD, invD, -value * invD))
            }
        })

        #expect(approxEqual(.init(operators.value), .init(partials.value)))

        let partialsGradients = partials.pullback(seed)

        #expect(approxEqual(operatorGradients.0, partialsGradients.0))
        #expect(approxEqual(operatorGradients.1, partialsGradients.1))
        #expect(approxEqual(operatorGradients.2, partialsGradients.2))
        #expect(approxEqual(operatorGradients.3, partialsGradients.3))
    }

    /// Spot-check the fused gradients against the analytic derivatives of `(a * b + c) / d`:
    /// ∂/∂a = b/d, ∂/∂b = a/d, ∂/∂c = 1/d, ∂/∂d = -(a·b + c)/d².
    @Test
    func fusedGradientsMatchAnalytic() {
        let a: [Double] = [1.0, 2.0]
        let b: [Double] = [3.0, 0.5]
        let c: [Double] = [2.0, 1.0]
        let d: [Double] = [2.0, 4.0]

        let fused = valueWithPullback4(at: a, b, c, d, of: { a, b, c, d in
            fusedZipWith(a, b, c, d) { a, b, c, d in (a * b + c) / d }
        })

        #expect(fused.value == [2.5, 0.5])

        let gradients = fused.pullback(Array.DifferentiableView([1, 1]))

        #expect(gradients.0 == Array.DifferentiableView([3.0 / 2.0, 0.5 / 4.0]))
        #expect(gradients.1 == Array.DifferentiableView([1.0 / 2.0, 2.0 / 4.0]))
        #expect(gradients.2 == Array.DifferentiableView([1.0 / 2.0, 1.0 / 4.0]))
        #expect(gradients.3 == Array.DifferentiableView([-2.5 / 2.0, -0.5 / 4.0]))
    }
}
