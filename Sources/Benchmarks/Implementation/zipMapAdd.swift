import CollectionsBenchmark
import Differentiation
import Foundation

private let benchmarkTitle = "zipMapAddNew"

extension Array where Element == Float {
    static func addZipMapAddBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            regular: { lhs, rhs in
                { _ in
                    blackHole(zip(lhs, rhs).differentiableMap { $0 + $1 })
                }
            },
            forward: { lhs, rhs in
                { _ in
                    blackHole(valueWithPullback(at: lhs, rhs, of: { zip($0, $1).differentiableMap { $0 + $1 } }).value)
                }
            },
            reverse: { lhs, rhs in
                let pullback = valueWithPullback(
                    at: lhs, rhs, of: { zip($0, $1).differentiableMap { $0 + $1 } }
                ).pullback

                var basisVector = Array.DifferentiableView([Float](repeating: 0, count: lhs.count))
                basisVector.base[0] = 1
                return { _ in
                    blackHole(pullback(basisVector))
                }
            }
        )

        benchmark.add(
            title: "\(Array.self).\(benchmarkTitle) - total",
            input: (Array<Float>, Array<Float>).self
        ) { lhs, rhs in
            var tangent = Array<Float>.DifferentiableView(repeating: 0, count: lhs.count)
            tangent[0] = 1.0
            return { _ in
                let pullback = valueWithPullback(
                    at: lhs, rhs, of: { zip($0, $1).differentiableMap { $0 + $1 } }
                ).pullback

                let gradient = pullback(tangent)

                blackHole(gradient)
            }
        }

        benchmark.add(
            title: benchmarkTitle + " using for loop",
            type: Self.self,
            regular: { lhs, rhs in
                { _ in
                    var result: [Float] = []
                    result.reserveCapacity(lhs.count)
                    for i in lhs.indices {
                        result.append(lhs[i] + rhs[i])
                    }
                    blackHole(result)
                }
            },
            forward: { lhs, rhs in
                { _ in
                    blackHole(
                        valueWithPullback(
                            at: lhs, rhs,
                            of: { lhs, rhs in
                                var results: [Float] = []
                                runWithoutDerivative {
                                    results.reserveCapacity(lhs.count)
                                }
                                for i in withoutDerivative(at: lhs.indices) {
                                    results.append(lhs[i] + rhs[i])
                                }
                                return results
                            }
                        ).value
                    )
                }
            },
            reverse: { lhs, rhs in
                let pullback = valueWithPullback(
                    at: lhs, rhs, of: { lhs, rhs in
                        var results: [Float] = []
                        runWithoutDerivative {
                            results.reserveCapacity(lhs.count)
                        }
                        for i in withoutDerivative(at: lhs.indices) {
                            results.append(lhs[i] + rhs[i])
                        }
                        return results
                    }
                ).pullback

                var basisVector = Array.DifferentiableView([Float](repeating: 0, count: lhs.count))
                basisVector.base[0] = 1
                return { _ in
                    blackHole(pullback(basisVector))
                }
            }
        )
    }
}
