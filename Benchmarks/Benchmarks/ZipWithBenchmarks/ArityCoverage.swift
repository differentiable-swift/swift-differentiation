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

func registerFusedArityCoverageBenchmarks() {
    let n = 100000

    Benchmark("zipWith3.fused.value.n=\(n)") { benchmark, input in
        for _ in benchmark.scaledIterations {
            blackHole(zipWith3_fused(input))
        }
    } setup: { Inputs3(n: n) }

    Benchmark("zipWith3.fused.valueWithPullback.n=\(n)") { benchmark, input in
        for _ in benchmark.scaledIterations {
            blackHole(valueWithPullback(at: input, of: zipWith3_fused))
        }
    } setup: { Inputs3(n: n) }

    Benchmark("zipWith3.fused.pullback.n=\(n)") { benchmark, input in
        let (pullback, seed) = input
        for _ in benchmark.scaledIterations {
            blackHole(pullback(seed))
        }
    } setup: { () -> (([Float].TangentVector) -> Inputs3.TangentVector, [Float].TangentVector) in
        let pullback = valueWithPullback(at: Inputs3(n: n), of: zipWith3_fused).pullback
        return (pullback, [Float].TangentVector([Float](repeating: 1, count: n)))
    }

    Benchmark("zipWith3.fused.gradient.n=\(n)") { benchmark, input in
        let (inputs, seed) = input
        for _ in benchmark.scaledIterations {
            let (value, pullback) = valueWithPullback(at: inputs, of: zipWith3_fused)
            blackHole(value)
            blackHole(pullback(seed))
        }
    } setup: { () -> (Inputs3, [Float].TangentVector) in
        (Inputs3(n: n), [Float].TangentVector([Float](repeating: 1, count: n)))
    }

    Benchmark("zipWith4.fused.value.n=\(n)") { benchmark, input in
        for _ in benchmark.scaledIterations {
            blackHole(zipWith4_fused(input))
        }
    } setup: { Inputs4(n: n) }

    Benchmark("zipWith4.fused.valueWithPullback.n=\(n)") { benchmark, input in
        for _ in benchmark.scaledIterations {
            blackHole(valueWithPullback(at: input, of: zipWith4_fused))
        }
    } setup: { Inputs4(n: n) }

    Benchmark("zipWith4.fused.pullback.n=\(n)") { benchmark, input in
        let (pullback, seed) = input
        for _ in benchmark.scaledIterations {
            blackHole(pullback(seed))
        }
    } setup: { () -> (([Float].TangentVector) -> Inputs4.TangentVector, [Float].TangentVector) in
        let pullback = valueWithPullback(at: Inputs4(n: n), of: zipWith4_fused).pullback
        return (pullback, [Float].TangentVector([Float](repeating: 1, count: n)))
    }

    Benchmark("zipWith4.fused.gradient.n=\(n)") { benchmark, input in
        let (inputs, seed) = input
        for _ in benchmark.scaledIterations {
            let (value, pullback) = valueWithPullback(at: inputs, of: zipWith4_fused)
            blackHole(value)
            blackHole(pullback(seed))
        }
    } setup: { () -> (Inputs4, [Float].TangentVector) in
        (Inputs4(n: n), [Float].TangentVector([Float](repeating: 1, count: n)))
    }

    Benchmark("zipWith14.fused.value.n=\(n)") { benchmark, input in
        for _ in benchmark.scaledIterations {
            blackHole(zipWith14_fused(input))
        }
    } setup: { Inputs14(n: n) }

    Benchmark("zipWith14.fused.valueWithPullback.n=\(n)") { benchmark, input in
        for _ in benchmark.scaledIterations {
            blackHole(valueWithPullback(at: input, of: zipWith14_fused))
        }
    } setup: { Inputs14(n: n) }

    Benchmark("zipWith14.fused.pullback.n=\(n)") { benchmark, input in
        let (pullback, seed) = input
        for _ in benchmark.scaledIterations {
            blackHole(pullback(seed))
        }
    } setup: { () -> (([Float].TangentVector) -> Inputs14.TangentVector, [Float].TangentVector) in
        let pullback = valueWithPullback(at: Inputs14(n: n), of: zipWith14_fused).pullback
        return (pullback, [Float].TangentVector([Float](repeating: 1, count: n)))
    }

    Benchmark("zipWith14.fused.gradient.n=\(n)") { benchmark, input in
        let (inputs, seed) = input
        for _ in benchmark.scaledIterations {
            let (value, pullback) = valueWithPullback(at: inputs, of: zipWith14_fused)
            blackHole(value)
            blackHole(pullback(seed))
        }
    } setup: { () -> (Inputs14, [Float].TangentVector) in
        (Inputs14(n: n), [Float].TangentVector([Float](repeating: 1, count: n)))
    }
}

func registerCliffBisectionBenchmarks() {
    let n = 100000

    Benchmark("zipWith10.canonical.valueWithPullback.n=\(n)") { benchmark, input in
        for _ in benchmark.scaledIterations {
            blackHole(valueWithPullback(at: input, of: zipWith10_canonical))
        }
    } setup: { Inputs10(n: n) }

    Benchmark("zipWith10.canonical.pullback.n=\(n)") { benchmark, input in
        let (pullback, seed) = input
        for _ in benchmark.scaledIterations {
            blackHole(pullback(seed))
        }
    } setup: { () -> (([Float].TangentVector) -> Inputs10.TangentVector, [Float].TangentVector) in
        let pullback = valueWithPullback(at: Inputs10(n: n), of: zipWith10_canonical).pullback
        return (pullback, [Float].TangentVector([Float](repeating: 1, count: n)))
    }

    Benchmark("zipWith10.fused.valueWithPullback.n=\(n)") { benchmark, input in
        for _ in benchmark.scaledIterations {
            blackHole(valueWithPullback(at: input, of: zipWith10_fused))
        }
    } setup: { Inputs10(n: n) }

    Benchmark("zipWith10.fused.pullback.n=\(n)") { benchmark, input in
        let (pullback, seed) = input
        for _ in benchmark.scaledIterations {
            blackHole(pullback(seed))
        }
    } setup: { () -> (([Float].TangentVector) -> Inputs10.TangentVector, [Float].TangentVector) in
        let pullback = valueWithPullback(at: Inputs10(n: n), of: zipWith10_fused).pullback
        return (pullback, [Float].TangentVector([Float](repeating: 1, count: n)))
    }

    Benchmark("zipWith12.canonical.valueWithPullback.n=\(n)") { benchmark, input in
        for _ in benchmark.scaledIterations {
            blackHole(valueWithPullback(at: input, of: zipWith12_canonical))
        }
    } setup: { Inputs12(n: n) }

    Benchmark("zipWith12.canonical.pullback.n=\(n)") { benchmark, input in
        let (pullback, seed) = input
        for _ in benchmark.scaledIterations {
            blackHole(pullback(seed))
        }
    } setup: { () -> (([Float].TangentVector) -> Inputs12.TangentVector, [Float].TangentVector) in
        let pullback = valueWithPullback(at: Inputs12(n: n), of: zipWith12_canonical).pullback
        return (pullback, [Float].TangentVector([Float](repeating: 1, count: n)))
    }

    Benchmark("zipWith12.fused.valueWithPullback.n=\(n)") { benchmark, input in
        for _ in benchmark.scaledIterations {
            blackHole(valueWithPullback(at: input, of: zipWith12_fused))
        }
    } setup: { Inputs12(n: n) }

    Benchmark("zipWith12.fused.pullback.n=\(n)") { benchmark, input in
        let (pullback, seed) = input
        for _ in benchmark.scaledIterations {
            blackHole(pullback(seed))
        }
    } setup: { () -> (([Float].TangentVector) -> Inputs12.TangentVector, [Float].TangentVector) in
        let pullback = valueWithPullback(at: Inputs12(n: n), of: zipWith12_fused).pullback
        return (pullback, [Float].TangentVector([Float](repeating: 1, count: n)))
    }
}
