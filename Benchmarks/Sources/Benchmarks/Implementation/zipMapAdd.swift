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
                    blackHole(differentiableZip(lhs, rhs).differentiableMap { $0 + $1 })
                }
            },
            forward: { lhs, rhs in
                { _ in
                    blackHole(valueWithPullback(at: lhs, rhs, of: { differentiableZip($0, $1).differentiableMap { $0 + $1 } }).value)
                }
            },
            reverse: { lhs, rhs in
                let pullback = valueWithPullback(
                    at: lhs, rhs, of: { differentiableZip($0, $1).differentiableMap { $0 + $1 } }
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
                    at: lhs, rhs, of: { differentiableZip($0, $1).differentiableMap { $0 + $1 } }
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

extension DArray where Element == Float {
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
            title: benchmarkTitle + "+Naive",
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
                                withoutDerivative {
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
                        withoutDerivative {
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

extension ConstantTimeAccessor where Element == Float {
    static func addZipMapAddBenchmarks(_ benchmark: inout Benchmark) {
//        benchmark.add(
//            title: benchmarkTitle,
//            type: Self.self,
//            regular: { lhs, rhs in
//                return { timer in
//                    blackHole(zip(lhs, rhs).differentiableMap { $0 + $1 })
//                }
//            },
//            forward: { lhs, rhs in
//                return { timer in
//                    blackHole(valueWithPullback(
//                        at: lhs, rhs,
//                        of: {
//                            zip($0, $1).differentiableMap{ $0 + $1 }
//                        }
//                    ).value)
//                }
//            },
//            reverse: { lhs, rhs in
//                let pullback = valueWithPullback(
//                    at: lhs, rhs,
//                    of: {
//                        zip($0, $1).differentiableMap{ $0 + $1 }
//                    }
//                ).pullback
//                var basisVector = Array.DifferentiableView([Float](repeating: 0, count: lhs.count))
//                basisVector.base[0] = 1
//                return { timer in
//                    blackHole(pullback(basisVector))
//                }
//            }
//        )

        benchmark.add(
            title: benchmarkTitle + "+Naive",
            type: Self.self,
            regular: { lhs, rhs in
                var lhs = lhs
                var rhs = rhs
                return { _ in
                    var result: [Float] = []
                    result.reserveCapacity(lhs.count)
                    for i in 0 ..< lhs.count {
                        lhs.accessElement(at: i)
                        rhs.accessElement(at: i)
                        result.append(lhs.accessed + rhs.accessed)
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
                                var lhs = lhs
                                var rhs = rhs
                                var results: [Float] = []
                                withoutDerivative {
                                    results.reserveCapacity(lhs.count)
                                }
                                for i in 0 ..< withoutDerivative(at: lhs.count) {
                                    lhs.accessElement(at: i)
                                    rhs.accessElement(at: i)
                                    results.append(lhs.accessed + rhs.accessed)
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
                        var lhs = lhs
                        var rhs = rhs
                        var results: [Float] = []
                        withoutDerivative {
                            results.reserveCapacity(lhs.count)
                        }
                        for i in 0 ..< withoutDerivative(at: lhs.count) {
                            lhs.accessElement(at: i)
                            rhs.accessElement(at: i)
                            results.append(lhs.accessed + rhs.accessed)
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

        benchmark.add(
            title: "\(ConstantTimeAccessor.self).\(benchmarkTitle)+Naive - total",
            input: (ConstantTimeAccessor<Float>, ConstantTimeAccessor<Float>).self
        ) { lhs, rhs in
            var tangent = Array<Float>.DifferentiableView(repeating: 0, count: lhs.count)
            tangent[0] = 1.0
            return { _ in
                let pullback = valueWithPullback(
                    at: lhs, rhs, of: { lhs, rhs in
                        var lhs = lhs
                        var rhs = rhs
                        var results: [Float] = []
                        withoutDerivative {
                            results.reserveCapacity(lhs.count)
                        }
                        for i in 0 ..< withoutDerivative(at: lhs.count) {
                            lhs.accessElement(at: i)
                            rhs.accessElement(at: i)
                            results.append(lhs.accessed + rhs.accessed)
                        }
                        return results
                    }
                ).pullback

                let gradient = pullback(tangent)

                blackHole(gradient)
            }
        }
    }
}

extension DCTA where Element == Float {
    static func addZipMapAddBenchmarks(_ benchmark: inout Benchmark) {
//        benchmark.add(
//            title: benchmarkTitle,
//            type: Self.self,
//            regular: { lhs, rhs in
//                return { timer in
//                    blackHole(zip(lhs, rhs).differentiableMap { $0 + $1 })
//                }
//            },
//            forward: { lhs, rhs in
//                return { timer in
//                    blackHole(
//                        valueWithPullback(
//                            at: lhs, rhs,
//                            of: {
//                                zip($0, $1).differentiableMap{ $0 + $1 }
//                            }
//                        ).value
//                    )
//                }
//            },
//            reverse: { lhs, rhs in
//                let pullback = valueWithPullback(
//                    at: lhs, rhs,
//                    of: {
//                        zip($0, $1).differentiableMap{ $0 + $1 }
//                    }
//                ).pullback
//                return { timer in
//                    blackHole(pullback(Float(1.0)))
//                }
//            }
//        )

        benchmark.add(
            title: benchmarkTitle + "+Naive",
            type: Self.self,
            regular: { lhs, rhs in
                var lhs = lhs
                var rhs = rhs
                return { _ in
                    var result: [Float] = []
                    result.reserveCapacity(lhs.count)
                    for i in 0 ..< lhs.count {
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
                                var lhs = lhs
                                var rhs = rhs
                                var results: [Float] = []
                                withoutDerivative {
                                    results.reserveCapacity(lhs.count)
                                }
                                for i in 0 ..< withoutDerivative(at: lhs.count) {
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
                        var lhs = lhs
                        var rhs = rhs
                        var results: [Float] = []
                        withoutDerivative {
                            results.reserveCapacity(lhs.count)
                        }
                        for i in 0 ..< withoutDerivative(at: lhs.count) {
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
