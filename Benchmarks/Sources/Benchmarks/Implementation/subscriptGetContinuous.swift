import CollectionsBenchmark
import Differentiation
import Foundation

private let benchmarkTitle = "subscriptGetContinuous"

extension Array where Element == Float {
    static func addSubscriptGetContinuousBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            regular: { input in
                { _ in
                    var result: Float = 0
                    for i in 0 ..< input.count {
                        result += input[i]
                    }
                    blackHole(result)
                }
            },
            forward: { input in
                { _ in
                    blackHole(
                        valueWithPullback(
                            at: input,
                            of: { input in
                                var result: Float = 0
                                for i in withoutDerivative(at: 0 ..< input.count) {
                                    result += input[i]
                                }
                                return result
                            }
                        )
                    )
                }
            },
            reverse: { input in
                let pullback = valueWithPullback(
                    at: input,
                    of: { input in
                        var result: Float = 0
                        for i in withoutDerivative(at: 0 ..< input.count) {
                            result += input[i]
                        }
                        return result
                    }
                ).pullback
                return { _ in
                    blackHole(pullback(Float(1.0)))
                }
            }
        )
    }
}
