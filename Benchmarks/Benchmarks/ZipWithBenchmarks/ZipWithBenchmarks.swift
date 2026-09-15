import Benchmark
import Differentiation
import ZipWithVariants

// Fixed-size runs of the differentiableZipWith implementation variants, tracking allocation
// counts and memory besides wall clock. The size-swept wall-clock charts for the same kernels
// live in the swift-collections-benchmark target (Sources/Benchmarks).
//
// Inputs are deterministic (makeInput / Inputs8, no RNG) so baselines are comparable across runs.
// Pullbacks are built in `setup:` so the `.pullback` cases time only pullback application.
//
// Kernels are passed as function parameters, not stored in collections: storing
// `@differentiable(reverse)` function values in tuple arrays crashes the current toolchain.

typealias Pullback2 = ([Float].TangentVector) -> ([Float].TangentVector, [Float].TangentVector)
typealias Pullback8 = ([Float].TangentVector) -> Inputs8.TangentVector

// Reference point: the concrete [Float] overload compiled (non-inlinable) inside the library —
// its whole body, including the internal Pair-packing valueWithPullback, is specialized there.

let benchmarks: @Sendable () -> Void = {
    Benchmark.defaultConfiguration = .init(
        metrics: [.wallClock, .throughput, .mallocCountTotal, .peakMemoryResident],
        scalingFactor: .one,
        maxDuration: .seconds(3)
    )

    func addArity2(
        _ name: String,
        n: Int,
        kernel: @escaping @differentiable(reverse) ([Float], [Float]) -> [Float]
    ) {
        Benchmark("zipWith2.\(name).value.n=\(n)") { benchmark, input in
            let (lhs, rhs) = input
            for _ in benchmark.scaledIterations {
                blackHole(kernel(lhs, rhs))
            }
        } setup: {
            (makeInput(n), makeInput(n, seed: 2))
        }

        Benchmark("zipWith2.\(name).valueWithPullback.n=\(n)") { benchmark, input in
            let (lhs, rhs) = input
            for _ in benchmark.scaledIterations {
                blackHole(valueWithPullback(at: lhs, rhs, of: kernel))
            }
        } setup: {
            (makeInput(n), makeInput(n, seed: 2))
        }

        Benchmark("zipWith2.\(name).pullback.n=\(n)") { benchmark, input in
            let (pullback, seed) = input
            for _ in benchmark.scaledIterations {
                blackHole(pullback(seed))
            }
        } setup: { () -> (Pullback2, [Float].TangentVector) in
            let pullback = valueWithPullback(
                at: makeInput(n), makeInput(n, seed: 2), of: kernel
            ).pullback
            let seed = [Float].TangentVector([Float](repeating: 1, count: n))
            return (pullback, seed)
        }
    }

    func addArity8(
        _ name: String,
        n: Int,
        kernel: @escaping @differentiable(reverse) (Inputs8) -> [Float]
    ) {
        Benchmark("zipWith8.\(name).value.n=\(n)") { benchmark, input in
            for _ in benchmark.scaledIterations {
                blackHole(kernel(input))
            }
        } setup: {
            Inputs8(n: n)
        }

        Benchmark("zipWith8.\(name).valueWithPullback.n=\(n)") { benchmark, input in
            for _ in benchmark.scaledIterations {
                blackHole(valueWithPullback(at: input, of: kernel))
            }
        } setup: {
            Inputs8(n: n)
        }

        Benchmark("zipWith8.\(name).pullback.n=\(n)") { benchmark, input in
            let (pullback, seed) = input
            for _ in benchmark.scaledIterations {
                blackHole(pullback(seed))
            }
        } setup: { () -> (Pullback8, [Float].TangentVector) in
            let pullback = valueWithPullback(at: Inputs8(n: n), of: kernel).pullback
            let seed = [Float].TangentVector([Float](repeating: 1, count: n))
            return (pullback, seed)
        }
    }

    func addArity2Gradient(
        _ name: String,
        n: Int,
        kernel: @escaping @differentiable(reverse) ([Float], [Float]) -> [Float]
    ) {
        Benchmark("zipWith2.\(name).gradient.n=\(n)") { benchmark, input in
            let (lhs, rhs, seed) = input
            for _ in benchmark.scaledIterations {
                let (value, pullback) = valueWithPullback(at: lhs, rhs, of: kernel)
                blackHole(value)
                blackHole(pullback(seed))
            }
        } setup: { () -> ([Float], [Float], [Float].TangentVector) in
            (makeInput(n), makeInput(n, seed: 2), [Float].TangentVector([Float](repeating: 1, count: n)))
        }
    }

    func addArity8Gradient(
        _ name: String,
        n: Int,
        kernel: @escaping @differentiable(reverse) (Inputs8) -> [Float]
    ) {
        Benchmark("zipWith8.\(name).gradient.n=\(n)") { benchmark, input in
            let (inputs, seed) = input
            for _ in benchmark.scaledIterations {
                let (value, pullback) = valueWithPullback(at: inputs, of: kernel)
                blackHole(value)
                blackHole(pullback(seed))
            }
        } setup: { () -> (Inputs8, [Float].TangentVector) in
            (Inputs8(n: n), [Float].TangentVector([Float](repeating: 1, count: n)))
        }
    }

    registerArityCoverageBenchmarks()
    registerFusedArityCoverageBenchmarks()
    registerCliffBisectionBenchmarks()

    for n in [1000, 100000] {
        addArity2("canonical", n: n, kernel: zipWith2_canonical)
        addArity8("canonical", n: n, kernel: zipWith8_canonical)
        addArity2("fused", n: n, kernel: zipWith2_fused)
        addArity8("fused", n: n, kernel: zipWith8_fused)
        addArity2Gradient("canonical", n: n, kernel: zipWith2_canonical)
        addArity8Gradient("canonical", n: n, kernel: zipWith8_canonical)
        addArity2Gradient("fused", n: n, kernel: zipWith2_fused)
        addArity8Gradient("fused", n: n, kernel: zipWith8_fused)
    }
}
