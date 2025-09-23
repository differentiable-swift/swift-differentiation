import CollectionsBenchmark
import Differentiation
import Foundation

fileprivate let benchmarkTitle = "mapReduce"

extension Array where Element == Float {
    static func addMapReduceBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            input: Array<Float>.self,
            regular: { input in
                { timer in
                    blackHole(input.differentiableMap{ sin($0) }.differentiableReduce(Float.zero, +))
                }
            },
            forward: { input in
                { timer in
                    blackHole(valueWithPullback(at: input, of: { $0.differentiableMap{ sin($0) }.differentiableReduce(Float.zero, +) }).value)
                }
            },
            reverse: { input in
                let pullback = valueWithPullback(
                    at: input, of: { $0.differentiableMap { sin($0) }.differentiableReduce(Float.zero, +) }
                ).pullback
                return { timer in
                    blackHole(pullback(Float(1.0)))
                }
            }
        )
    }
}

extension ConstantTimeAccessor where Element == Float {
    static func addMapReduceBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            input: Array<Float>.self,
            regular: { input in
                let input = ConstantTimeAccessor(input)
                return { timer in
                    blackHole(input.differentiableMap { sin($0) }.differentiableReduce(Float.zero, +))
                }
            },
            forward: { input in
                let input = ConstantTimeAccessor(input)
                return { timer in
                    let input = input
                    blackHole(valueWithPullback(
                        at: input,
                        of: {
                            $0.differentiableMap{ sin($0) }.differentiableReduce(Float.zero, +)
                        }
                    ).value)
                }
            },
            reverse: { input in
                let input = ConstantTimeAccessor(input)
                let pullback = valueWithPullback(
                    at: input,
                    of: {
                        $0.differentiableMap{ sin($0) }.differentiableReduce(Float.zero, +)
                    }
                ).pullback
                return { timer in
                    blackHole(pullback(Float(1.0)))
                }
            }
        )
    }
}

extension DCTA where Element == Float {
    static func addMapReduceBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            input: Array<Float>.self,
            regular: { input in
                let input = DCTA(input)
                return { timer in
                    blackHole(input.differentiableMap { sin($0) }.differentiableReduce(Float.zero, +))
                }
            },
            forward: { input in
                let input = DCTA(input)
                return { timer in
                    let input = input
                    blackHole(
                        valueWithPullback(
                            at: input,
                            of: {
                                $0.differentiableMap{ sin($0) }.differentiableReduce(Float.zero, +)
                            }
                        ).value
                    )
                }
            },
            reverse: { input in
                let input = DCTA(input)
                let pullback = valueWithPullback(
                    at: input,
                    of: {
                        $0.differentiableMap{ sin($0) }.differentiableReduce(Float.zero, +)
                    }
                ).pullback
                return { timer in
                    blackHole(pullback(Float(1.0)))
                }
            }
        )
    }
}
