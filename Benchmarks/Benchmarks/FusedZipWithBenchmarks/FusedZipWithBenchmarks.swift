import Benchmark
import DifferentiableOperators
import Differentiation

/// Compares the same element-wise expression computed four ways:
/// - chained differentiable operators (multiple passes, per-operator pullbacks)
/// - `differentiableZipWith` (one pass, per-element AD, pullback closures stored)
/// - `fusedZipWith` (one pass, per-element AD, partials extracted eagerly)
/// - `fusedZipWithPartials` (one pass, caller-supplied analytic partials, no per-element AD)
///
/// `regular` measures the value only; `gradient` measures valueWithPullback plus one pullback
/// call. Array size is fixed — scaling behavior lives in the CollectionsBenchmark target.

private let count = 65536

// MARK: - arity 4: (a * b + c) / d

@differentiable(reverse)
private func operatorsExpression(_ a: [Double], _ b: [Double], _ c: [Double], _ d: [Double]) -> [Double] {
    (a .* b .+ c) ./ d
}

@differentiable(reverse)
private func zipWithExpression(_ a: [Double], _ b: [Double], _ c: [Double], _ d: [Double]) -> [Double] {
    differentiableZipWith(a, b, c, d) { a, b, c, d in (a * b + c) / d }
}

@differentiable(reverse)
private func fusedExpression(_ a: [Double], _ b: [Double], _ c: [Double], _ d: [Double]) -> [Double] {
    fusedZipWith(a, b, c, d) { a, b, c, d in (a * b + c) / d }
}

// (a·b + c)/d with hand-supplied partials:
// ∂/∂a = b/d, ∂/∂b = a/d, ∂/∂c = 1/d, ∂/∂d = -(a·b + c)/d² = -value/d
@differentiable(reverse)
private func partialsExpression(_ a: [Double], _ b: [Double], _ c: [Double], _ d: [Double]) -> [Double] {
    fusedZipWithPartials(a, b, c, d) { a, b, c, d in
        let invD = 1.0 / d
        let value = (a * b + c) * invD
        return (value, (b * invD, a * invD, invD, -value * invD))
    }
}

// MARK: - arity 2: a * b

@differentiable(reverse)
private func operatorsExpression2(_ a: [Double], _ b: [Double]) -> [Double] {
    a .* b
}

@differentiable(reverse)
private func zipWithExpression2(_ a: [Double], _ b: [Double]) -> [Double] {
    differentiableZipWith(a, b) { a, b in a * b }
}

@differentiable(reverse)
private func fusedExpression2(_ a: [Double], _ b: [Double]) -> [Double] {
    fusedZipWith(a, b) { a, b in a * b }
}

@differentiable(reverse)
private func partialsExpression2(_ a: [Double], _ b: [Double]) -> [Double] {
    fusedZipWithPartials(a, b) { a, b in (a * b, (b, a)) }
}

// MARK: - Benchmarks

let benchmarks: @Sendable () -> Void = {
    Benchmark.defaultConfiguration = .init(
        metrics: [.wallClock, .mallocCountTotal, .peakMemoryResident, .throughput],
        maxDuration: .seconds(2)
    )

    // Values stay in 0.5 ... 2.0 so the element-wise division can't blow up or produce subnormals.
    func makeInput() -> [Double] {
        (0 ..< count).map { _ in Double.random(in: 0.5 ... 2.0) }
    }

    let a = makeInput()
    let b = makeInput()
    let c = makeInput()
    let d = makeInput()
    let seed = Array.DifferentiableView([Double](repeating: 1, count: count))

    // MARK: arity 2

    Benchmark("arity2 operators regular") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(operatorsExpression2(a, b))
        }
    }

    Benchmark("arity2 differentiableZipWith regular") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(zipWithExpression2(a, b))
        }
    }

    Benchmark("arity2 fusedZipWith regular") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(fusedExpression2(a, b))
        }
    }

    Benchmark("arity2 fusedZipWithPartials regular") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(partialsExpression2(a, b))
        }
    }

    Benchmark("arity2 operators gradient") { benchmark in
        for _ in benchmark.scaledIterations {
            let (value, pullback) = valueWithPullback(at: a, b, of: operatorsExpression2)
            blackHole(value)
            blackHole(pullback(seed))
        }
    }

    Benchmark("arity2 differentiableZipWith gradient") { benchmark in
        for _ in benchmark.scaledIterations {
            let (value, pullback) = valueWithPullback(at: a, b, of: zipWithExpression2)
            blackHole(value)
            blackHole(pullback(seed))
        }
    }

    Benchmark("arity2 fusedZipWith gradient") { benchmark in
        for _ in benchmark.scaledIterations {
            let (value, pullback) = valueWithPullback(at: a, b, of: fusedExpression2)
            blackHole(value)
            blackHole(pullback(seed))
        }
    }

    Benchmark("arity2 fusedZipWithPartials gradient") { benchmark in
        for _ in benchmark.scaledIterations {
            let (value, pullback) = valueWithPullback(at: a, b, of: partialsExpression2)
            blackHole(value)
            blackHole(pullback(seed))
        }
    }

    // MARK: arity 4

    Benchmark("arity4 operators regular") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(operatorsExpression(a, b, c, d))
        }
    }

    Benchmark("arity4 differentiableZipWith regular") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(zipWithExpression(a, b, c, d))
        }
    }

    Benchmark("arity4 fusedZipWith regular") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(fusedExpression(a, b, c, d))
        }
    }

    Benchmark("arity4 fusedZipWithPartials regular") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(partialsExpression(a, b, c, d))
        }
    }

    Benchmark("arity4 operators gradient") { benchmark in
        for _ in benchmark.scaledIterations {
            let (value, pullback) = valueWithPullback4(at: a, b, c, d, of: operatorsExpression)
            blackHole(value)
            blackHole(pullback(seed))
        }
    }

    Benchmark("arity4 differentiableZipWith gradient") { benchmark in
        for _ in benchmark.scaledIterations {
            let (value, pullback) = valueWithPullback4(at: a, b, c, d, of: zipWithExpression)
            blackHole(value)
            blackHole(pullback(seed))
        }
    }

    Benchmark("arity4 fusedZipWith gradient") { benchmark in
        for _ in benchmark.scaledIterations {
            let (value, pullback) = valueWithPullback4(at: a, b, c, d, of: fusedExpression)
            blackHole(value)
            blackHole(pullback(seed))
        }
    }

    Benchmark("arity4 fusedZipWithPartials gradient") { benchmark in
        for _ in benchmark.scaledIterations {
            let (value, pullback) = valueWithPullback4(at: a, b, c, d, of: partialsExpression)
            blackHole(value)
            blackHole(pullback(seed))
        }
    }
}
