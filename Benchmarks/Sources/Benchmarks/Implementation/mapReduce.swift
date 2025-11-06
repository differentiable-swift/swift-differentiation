import CollectionsBenchmark
import Differentiation
import Foundation

private let benchmarkTitle = "mapReduce"

extension Array where Element == Float {
    static func addMapReduceBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            regular: { input in
                { _ in
                    blackHole(input.differentiableMap { sin($0) }.differentiableReduce(Float.zero, +))
                }
            },
            forward: { input in
                { _ in
                    blackHole(valueWithPullback(at: input, of: { $0.differentiableMap { sin($0) }.differentiableReduce(Float.zero, +) })
                        .value
                    )
                }
            },
            reverse: { input in
                let pullback = valueWithPullback(
                    at: input, of: { $0.differentiableMap { sin($0) }.differentiableReduce(Float.zero, +) }
                ).pullback
                return { _ in
                    blackHole(pullback(Float(1.0)))
                }
            }
        )
    }
}
