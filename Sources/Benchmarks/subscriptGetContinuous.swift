import CollectionsBenchmark
import Differentiation
import Foundation

fileprivate let benchmarkTitle = "subscriptGetContinuous"

extension Array where Element == Float {
    static func addSubscriptGetContinuousBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            input: Array<Float>.self,
            regular: { input in
                { timer in
                    var result: Float = 0
                    for i in 0..<input.count {
                        result += input[i]
                    }
                    blackHole(result)
                }
            },
            forward: { input in
                { timer in
                    blackHole(
                        valueWithPullback(
                            at: input,
                            of: { input in
                                var result: Float = 0
                                for i in withoutDerivative(at: 0..<input.count) {
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
                        for i in withoutDerivative(at: 0..<input.count) {
                            result += input[i]
                        }
                        return result
                    }
                ).pullback
                return { timer in
                    blackHole(pullback(Float(1.0)))
                }
            }
        )
    }
}

extension ConstantTimeAccessor where Element == Float {
    static func addSubscriptGetContinuousBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            input: Array<Float>.self,
            regular: { input in
                var input = ConstantTimeAccessor(input)
                return { timer in
                    var result: Float = 0
                    for i in 0..<input.count {
                        input.accessElement(at: i)
                        result += input.accessed
                    }
                    blackHole(result)
                }
            },
            forward: { input in
                let input = ConstantTimeAccessor(input)
                return { timer in
                    blackHole(
                        valueWithPullback(
                            at: input,
                            of: { input in
                                var input = input // we unfortunately have to make a copy due to the mutable nature of subscript read
                                var result: Float = 0
                                for i in withoutDerivative(at: 0..<input.count) {
                                    input.accessElement(at: i)
                                    result += input.accessed
                                }
                                return result
                            }
                        ).value
                    )
                }
            },
            reverse: { input in
                let input = ConstantTimeAccessor(input)
                let pullback = valueWithPullback(
                    at: input,
                    of: { input in
                        var input = input
                        var result: Float = 0
                        for i in withoutDerivative(at: 0..<input.count) {
                            input.accessElement(at: i)
                            result += input.accessed
                        }
                        return result
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
    static func addSubscriptGetContinuousBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            input: Array<Float>.self,
            regular: { input in
                var input = DCTA(input)
                return { timer in
                    var result: Float = 0
                    for i in 0..<input.count {
                        result += input[i]
                    }
                    blackHole(result)
                }
            },
            forward: { input in
                let input = DCTA(input)
                return { timer in
                    blackHole(
                        valueWithPullback(
                            at: input,
                            of: { input in
                                var input = input // we unfortunately have to make a copy due to the mutable nature of subscript read
                                var result: Float = 0
                                for i in withoutDerivative(at: 0..<input.count) {
                                    result += input[i]
                                }
                                return result
                            }
                        ).value
                    )
                }
            },
            reverse: { input in
                let input = DCTA(input)
                let pullback = valueWithPullback(
                    at: input,
                    of: { input in
                        var input = input
                        var result: Float = 0
                        for i in withoutDerivative(at: 0..<input.count) {
                            result += input[i]
                        }
                        return result
                    }
                ).pullback
                return { timer in
                    blackHole(pullback(Float(1.0)))
                }
            }
        )
    }
}
