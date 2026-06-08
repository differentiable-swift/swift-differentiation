import CollectionsBenchmark
import Differentiation
import Foundation

// MARK: Benchmarks

private let benchmarkTitle = "meanSquaredError"

extension DifferentiableArray where Element == Float {
    static func addMeanSquaredErrorBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            regular: { input, target in
                { _ in
                    blackHole(input.meanSquaredError(to: target))
                }
            },
            forward: { input, target in
                { _ in
                    blackHole(valueWithPullback(at: input, of: { $0.meanSquaredError(to: target) }))
                }
            },
            reverse: { input, target in
                let pullback = valueWithPullback(at: input, of: { $0.meanSquaredError(to: target) })
                    .pullback
                return { _ in
                    blackHole(pullback(Float(1.0)))
                }
            }
        )
    }
}
