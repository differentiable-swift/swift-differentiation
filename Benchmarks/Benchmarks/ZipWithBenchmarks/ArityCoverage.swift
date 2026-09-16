import Benchmark
import Differentiation
import ZipWithVariants

// Arity-coverage cases for verifying the VJP shape decision across all arities.
func registerArityCoverageBenchmarks() {
    let n = 100000

    Benchmark("zipWith3.canonical.value.n=\(n)") { benchmark, input in
        for _ in benchmark.scaledIterations {
            blackHole(zipWith3_canonical(input))
        }
    } setup: { Inputs3(n: n) }

    Benchmark("zipWith3.canonical.valueWithPullback.n=\(n)") { benchmark, input in
        for _ in benchmark.scaledIterations {
            blackHole(valueWithPullback(at: input, of: zipWith3_canonical))
        }
    } setup: { Inputs3(n: n) }

    Benchmark("zipWith3.canonical.pullback.n=\(n)") { benchmark, input in
        let (pullback, seed) = input
        for _ in benchmark.scaledIterations {
            blackHole(pullback(seed))
        }
    } setup: { () -> (([Float].TangentVector) -> Inputs3.TangentVector, [Float].TangentVector) in
        let pullback = valueWithPullback(at: Inputs3(n: n), of: zipWith3_canonical).pullback
        return (pullback, [Float].TangentVector([Float](repeating: 1, count: n)))
    }

    Benchmark("zipWith3.canonical.gradient.n=\(n)") { benchmark, input in
        let (inputs, seed) = input
        for _ in benchmark.scaledIterations {
            let (value, pullback) = valueWithPullback(at: inputs, of: zipWith3_canonical)
            blackHole(value)
            blackHole(pullback(seed))
        }
    } setup: { () -> (Inputs3, [Float].TangentVector) in
        (Inputs3(n: n), [Float].TangentVector([Float](repeating: 1, count: n)))
    }

    Benchmark("zipWith4.canonical.value.n=\(n)") { benchmark, input in
        for _ in benchmark.scaledIterations {
            blackHole(zipWith4_canonical(input))
        }
    } setup: { Inputs4(n: n) }

    Benchmark("zipWith4.canonical.valueWithPullback.n=\(n)") { benchmark, input in
        for _ in benchmark.scaledIterations {
            blackHole(valueWithPullback(at: input, of: zipWith4_canonical))
        }
    } setup: { Inputs4(n: n) }

    Benchmark("zipWith4.canonical.pullback.n=\(n)") { benchmark, input in
        let (pullback, seed) = input
        for _ in benchmark.scaledIterations {
            blackHole(pullback(seed))
        }
    } setup: { () -> (([Float].TangentVector) -> Inputs4.TangentVector, [Float].TangentVector) in
        let pullback = valueWithPullback(at: Inputs4(n: n), of: zipWith4_canonical).pullback
        return (pullback, [Float].TangentVector([Float](repeating: 1, count: n)))
    }

    Benchmark("zipWith4.canonical.gradient.n=\(n)") { benchmark, input in
        let (inputs, seed) = input
        for _ in benchmark.scaledIterations {
            let (value, pullback) = valueWithPullback(at: inputs, of: zipWith4_canonical)
            blackHole(value)
            blackHole(pullback(seed))
        }
    } setup: { () -> (Inputs4, [Float].TangentVector) in
        (Inputs4(n: n), [Float].TangentVector([Float](repeating: 1, count: n)))
    }

    Benchmark("zipWith14.canonical.value.n=\(n)") { benchmark, input in
        for _ in benchmark.scaledIterations {
            blackHole(zipWith14_canonical(input))
        }
    } setup: { Inputs14(n: n) }

    Benchmark("zipWith14.canonical.valueWithPullback.n=\(n)") { benchmark, input in
        for _ in benchmark.scaledIterations {
            blackHole(valueWithPullback(at: input, of: zipWith14_canonical))
        }
    } setup: { Inputs14(n: n) }

    Benchmark("zipWith14.canonical.pullback.n=\(n)") { benchmark, input in
        let (pullback, seed) = input
        for _ in benchmark.scaledIterations {
            blackHole(pullback(seed))
        }
    } setup: { () -> (([Float].TangentVector) -> Inputs14.TangentVector, [Float].TangentVector) in
        let pullback = valueWithPullback(at: Inputs14(n: n), of: zipWith14_canonical).pullback
        return (pullback, [Float].TangentVector([Float](repeating: 1, count: n)))
    }

    Benchmark("zipWith14.canonical.gradient.n=\(n)") { benchmark, input in
        let (inputs, seed) = input
        for _ in benchmark.scaledIterations {
            let (value, pullback) = valueWithPullback(at: inputs, of: zipWith14_canonical)
            blackHole(value)
            blackHole(pullback(seed))
        }
    } setup: { () -> (Inputs14, [Float].TangentVector) in
        (Inputs14(n: n), [Float].TangentVector([Float](repeating: 1, count: n)))
    }
}
