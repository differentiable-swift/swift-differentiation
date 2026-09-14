import CollectionsBenchmark
import Differentiation
import Foundation
import ZipWithVariants

// Size-swept wall-clock comparison of the differentiableZipWith implementation variants in the
// ZipWithVariants module. Fixed-size allocation/memory metrics for the same kernels live in the
// ordo-one target (Benchmarks/ZipWithBenchmarks).
//
// Kernels are passed as function parameters, not stored in collections: storing
// `@differentiable(reverse)` function values in tuple arrays crashes the current toolchain.

extension Array where Element == Float {
    static func addZipWithVariantBenchmarks(_ benchmark: inout Benchmark) {
        addZipWith2Variant(&benchmark, name: "canonical", kernel: zipWith2_canonical)
        addZipWith8Variant(&benchmark, name: "canonical", kernel: zipWith8_canonical)
        addZipWith2Variant(&benchmark, name: "fused", kernel: zipWith2_fused)
        addZipWith8Variant(&benchmark, name: "fused", kernel: zipWith8_fused)
    }

    private static func addZipWith2Variant(
        _ benchmark: inout Benchmark,
        name: String,
        kernel: @escaping @differentiable(reverse) ([Float], [Float]) -> [Float]
    ) {
        benchmark.add(
            title: "zipWith2.\(name)",
            type: Self.self,
            regular: { lhs, rhs in
                { _ in
                    blackHole(kernel(lhs, rhs))
                }
            },
            forward: { lhs, rhs in
                { _ in
                    blackHole(valueWithPullback(at: lhs, rhs, of: kernel).value)
                }
            },
            reverse: { lhs, rhs in
                let pullback = valueWithPullback(at: lhs, rhs, of: kernel).pullback
                let seed = Array.DifferentiableView([Float](repeating: 1, count: lhs.count))
                return { _ in
                    blackHole(pullback(seed))
                }
            }
        )
    }

    private static func addZipWith8Variant(
        _ benchmark: inout Benchmark,
        name: String,
        kernel: @escaping @differentiable(reverse) (Inputs8) -> [Float]
    ) {
        benchmark.addImplementation(
            title: "zipWith8.\(name)",
            type: Self.self,
            input: [Float].self,
            regular: { input in
                let inputs = Inputs8(base: input)
                return { _ in
                    blackHole(kernel(inputs))
                }
            },
            forward: { input in
                let inputs = Inputs8(base: input)
                return { _ in
                    blackHole(valueWithPullback(at: inputs, of: kernel).value)
                }
            },
            reverse: { input in
                let inputs = Inputs8(base: input)
                let pullback = valueWithPullback(at: inputs, of: kernel).pullback
                let seed = Array.DifferentiableView([Float](repeating: 1, count: input.count))
                return { _ in
                    blackHole(pullback(seed))
                }
            }
        )
    }
}
