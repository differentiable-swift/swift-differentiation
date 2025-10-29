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

extension DArray where Element == Float {
    static func addSubscriptGetContinuousBenchmarks(_ benchmark: inout CollectionsBenchmark.Benchmark) {
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

extension ConstantTimeAccessor where Element == Float {
    static func addSubscriptGetContinuousBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            regular: { input in
                var input = input
                return { _ in
                    var result: Float = 0
                    for i in 0 ..< input.count {
                        input.accessElement(at: i)
                        result += input.accessed
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
                                var input = input // we unfortunately have to make a copy due to the mutable nature of subscript read
                                var result: Float = 0
                                for i in withoutDerivative(at: 0 ..< input.count) {
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
                let pullback = valueWithPullback(
                    at: input,
                    of: { input in
                        var input = input
                        var result: Float = 0
                        for i in withoutDerivative(at: 0 ..< input.count) {
                            input.accessElement(at: i)
                            result += input.accessed
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

extension DCTA where Element == Float {
    static func addSubscriptGetContinuousBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            regular: { input in
                var input = input
                return { _ in
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
                                var input = input // we unfortunately have to make a copy due to the mutable nature of subscript read
                                var result: Float = 0
                                for i in withoutDerivative(at: 0 ..< input.count) {
                                    result += input[i]
                                }
                                return result
                            }
                        ).value
                    )
                }
            },
            reverse: { input in
                let pullback = valueWithPullback(
                    at: input,
                    of: { input in
                        var input = input
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
