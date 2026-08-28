import Benchmark
import Differentiation

/// Deterministic, well-conditioned input so baseline comparisons aren't perturbed by RNG.
private func makeInput(_ n: Int, seed: Float = 1) -> [Float] {
    (0 ..< n).map { Float(($0 % 97) + 1) * 0.013 * seed }
}

/// Eight collections wrapped in one `Differentiable` aggregate so the whole arity-8 call can be
/// differentiated through the single-argument `valueWithPullback` overload.
private struct Inputs8: Differentiable {
    var c1, c2, c3, c4, c5, c6, c7, c8: [Float]

    init(_ n: Int) {
        c1 = makeInput(n, seed: 1)
        c2 = makeInput(n, seed: 2)
        c3 = makeInput(n, seed: 3)
        c4 = makeInput(n, seed: 4)
        c5 = makeInput(n, seed: 5)
        c6 = makeInput(n, seed: 6)
        c7 = makeInput(n, seed: 7)
        c8 = makeInput(n, seed: 8)
    }
}

@differentiable(reverse)
private func zipWith2(_ lhs: [Float], _ rhs: [Float]) -> [Float] {
    differentiableZipWith(lhs, rhs) { $0 * $1 }
}

@differentiable(reverse)
private func zipWith2Repeated(_ lhs: [Float], _ rhs: Repeated<Float>) -> [Float] {
    differentiableZipWith(lhs, rhs) { $0 * $1 }
}

@differentiable(reverse)
private func zipWith8(_ x: Inputs8) -> [Float] {
    differentiableZipWith(x.c1, x.c2, x.c3, x.c4, x.c5, x.c6, x.c7, x.c8) {
        $0 * $1 + $2 * $3 + $4 * $5 + $6 * $7
    }
}

let benchmarks: @Sendable () -> Void = {
    Benchmark.defaultConfiguration = .init(
        metrics: [.wallClock, .throughput, .mallocCountTotal, .peakMemoryResident],
        scalingFactor: .one
    )

    for n in [1000, 100000] {
        // Plain, non-differentiated execution: the baseline cost of the primal loop alone.
        Benchmark("zipWith.arity2.value.n=\(n)") { benchmark, input in
            let (lhs, rhs) = input
            for _ in benchmark.scaledIterations {
                blackHole(zipWith2(lhs, rhs))
            }
        } setup: {
            (makeInput(n), makeInput(n, seed: 2))
        }

        Benchmark("zipWith.arity2.repeatedOperand.value.n=\(n)") { benchmark, input in
            let (lhs, rhs) = input
            for _ in benchmark.scaledIterations {
                blackHole(zipWith2Repeated(lhs, rhs))
            }
        } setup: {
            (makeInput(n), repeatElement(Float(0.5), count: n))
        }

        Benchmark("zipWith.arity8.value.n=\(n)") { benchmark, input in
            for _ in benchmark.scaledIterations {
                blackHole(zipWith8(input))
            }
        } setup: {
            Inputs8(n)
        }

        // Forward pass + pullback-closure capture. Not affected by the cursor change directly,
        // but guards against regressions in what the pullback captures.
        Benchmark("zipWith.arity2.valueWithPullback.n=\(n)") { benchmark, input in
            let (lhs, rhs) = input
            for _ in benchmark.scaledIterations {
                blackHole(valueWithPullback(at: lhs, rhs, of: zipWith2))
            }
        } setup: {
            (makeInput(n), makeInput(n, seed: 2))
        }

        Benchmark("zipWith.arity2.repeatedOperand.valueWithPullback.n=\(n)") { benchmark, input in
            let (lhs, rhs) = input
            for _ in benchmark.scaledIterations {
                blackHole(valueWithPullback(at: lhs, rhs, of: zipWith2Repeated))
            }
        } setup: {
            (makeInput(n), repeatElement(Float(0.5), count: n))
        }

        Benchmark("zipWith.arity8.valueWithPullback.n=\(n)") { benchmark, input in
            for _ in benchmark.scaledIterations {
                blackHole(valueWithPullback(at: input, of: zipWith8))
            }
        } setup: {
            Inputs8(n)
        }

        // The hot path the cursor change touches: pullback execution in isolation.
        Benchmark("zipWith.arity2.pullback.n=\(n)") { benchmark, input in
            let (pullback, seed) = input
            for _ in benchmark.scaledIterations {
                blackHole(pullback(seed))
            }
        } setup: { () -> (([Float].TangentVector) -> ([Float].TangentVector, [Float].TangentVector), [Float].TangentVector) in
            let pullback = valueWithPullback(at: makeInput(n), makeInput(n, seed: 2), of: zipWith2).pullback
            let seed = [Float].TangentVector(repeating: 1, count: n)
            return (pullback, seed)
        }

        // Exercises the fold-style `Repeated` tangent construction instead of contiguous storage.
        Benchmark("zipWith.arity2.repeatedOperand.pullback.n=\(n)") { benchmark, input in
            let (pullback, seed) = input
            for _ in benchmark.scaledIterations {
                blackHole(pullback(seed))
            }
        } setup: { () -> (([Float].TangentVector) -> ([Float].TangentVector, Repeated<Float>.TangentVector), [Float].TangentVector) in
            let pullback = valueWithPullback(at: makeInput(n), repeatElement(0.5, count: n), of: zipWith2Repeated).pullback
            let seed = [Float].TangentVector(repeating: 1, count: n)
            return (pullback, seed)
        }

        // High arity: seven scratch buffers in the pullback, worst case for the staging pattern.
        Benchmark("zipWith.arity8.pullback.n=\(n)") { benchmark, input in
            let (pullback, seed) = input
            for _ in benchmark.scaledIterations {
                blackHole(pullback(seed))
            }
        } setup: { () -> (([Float].TangentVector) -> Inputs8.TangentVector, [Float].TangentVector) in
            let pullback = valueWithPullback(at: Inputs8(n), of: zipWith8).pullback
            let seed = [Float].TangentVector(repeating: 1, count: n)
            return (pullback, seed)
        }
    }
}
