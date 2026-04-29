import CollectionsBenchmark
import Differentiation
import Foundation

// MARK: Array.meanSquaredError

extension Array where Element == Float {
    @inlinable
    @differentiable(reverse, wrt: self)
    public mutating func meanSquaredErrorCTA(to target: inout Array<Float>) -> Float {
        var mse: Float = 0
        for i in 0 ..< withoutDerivative(at: self.count) {
            let d: Float = self[cta: i] - target[cta: i]
            mse += d * d
        }
        return mse
    }

    @inlinable
    @differentiable(reverse, wrt: self)
    public func meanSquaredError(to target: Array<Float>) -> Float {
        // precondition(self.count == target.count)
        var mse: Float = 0
        for i in 0 ..< withoutDerivative(at: self.count) {
            let d = self[i] - target[i]
            mse += d * d
        }
        return mse
    }
    
    @inlinable
    @differentiable(reverse, wrt: self)
    public func meanSquaredErrorCombinator(to target: Array<Float>) -> Float {
        differentiableZipWith(self, target, with: doThing).differentiableReduce(0.0, addThing)
    }
}

extension Array where Element == Float {
    
}

@inlinable
@differentiable(reverse)
public func doThing(_ x: Float, _ y: Float) -> Float {
    let d = x - y
    return d * d
}

@inlinable
@differentiable(reverse)
public func addThing(_ x: Float, _ y: Float) -> Float {
    x + y
}

extension DArray where Element == Float {
    @inlinable
    @differentiable(reverse, wrt: self)
    public func meanSquaredError(to target: DArray<Float>) -> Float {
        // precondition(self.count == target.count)
        var mse: Float = 0
        for i in 0 ..< withoutDerivative(at: self.count) {
            let d = self[i] - target[i]
            mse += d * d
        }
        return mse
    }
}

// MARK: ConstantTimeAccessor<Float>.meanSquaredError

extension ConstantTimeAccessor where Element == Float {
    @inlinable
    @differentiable(reverse, wrt: self)
    public mutating func meanSquaredError(to target: inout ConstantTimeAccessor<Float>) -> Float {
        // precondition(self.count == target.count)
        var mse: Float = 0
        for i in 0 ..< withoutDerivative(at: self.count) {
            self.accessElement(at: i)
            target.accessElement(at: i)
            let d = self.accessed - target.accessed
            mse += d * d
        }
        return mse
    }
}

// MARK: DCTA<Float>.meanSquaredError

extension DCTA where Element == Float {
    @inlinable
    @differentiable(reverse, wrt: self)
    public mutating func meanSquaredError(to target: DCTA<Float>) -> Float {
        // precondition(self.count == target.count)
        var mse: Float = 0
        var target = target
        for i in 0 ..< withoutDerivative(at: self.count) {
            let d = self[i] - target[i]
            mse += d * d
        }
        return mse
    }
}

// MARK: Benchmarks

private let benchmarkTitle = "meanSquaredError"

extension Array where Element == Float {
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
        
        benchmark.add(
            title: benchmarkTitle + "combinator",
            type: Self.self,
            regular: { input, target in
                { _ in
                    blackHole(input.meanSquaredErrorCombinator(to: target))
                }
            },
            forward: { input, target in
                { _ in
                    blackHole(valueWithPullback(at: input, of: { $0.meanSquaredErrorCombinator(to: target) }))
                }
            },
            reverse: { input, target in
                let pullback = valueWithPullback(at: input, of: { $0.meanSquaredErrorCombinator(to: target) })
                    .pullback
                return { _ in
                    blackHole(pullback(Float(1.0)))
                }
            }
        )
        
        benchmark.add(
            title: benchmarkTitle + "cta",
            type: Self.self,
            regular: { input, target in
                { _ in
                    var input = input
                    var target = target
                    blackHole(input.meanSquaredErrorCTA(to: &target))
                }
            },
            forward: { input, target in
                { _ in
                    blackHole(
                        valueWithPullback(
                            at: input,
                            of: {
                                var input = $0
                                var target = target
                                return input.meanSquaredErrorCTA(to: &target)
                            }
                        )
                    )
                }
            },
            reverse: { input, target in
                let pullback = valueWithPullback(
                    at: input,
                    of: {
                        var input = $0
                        var target = target
                        return input.meanSquaredErrorCTA(to: &target)
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
    static func addMeanSquaredErrorBenchmarks(_ benchmark: inout CollectionsBenchmark.Benchmark) {
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

extension ConstantTimeAccessor where Element == Float {
    static func addMeanSquaredErrorBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            regular: { input, target in
                var input = input
                var target = target
                return { _ in
                    blackHole(input.meanSquaredError(to: &target))
                }
            },
            forward: { input, target in
                { _ in
                    blackHole(valueWithPullback(
                        at: input,
                        of: {
                            var input = $0
                            var target = target
                            return input.meanSquaredError(to: &target)
                        }
                    ))
                }
            },
            reverse: { input, target in
                let pullback = valueWithPullback(
                    at: input,
                    of: {
                        var x0 = $0
                        var target = target
                        return x0.meanSquaredError(to: &target)
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
    static func addMeanSquaredErrorBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            regular: { input, target in
                var input = input
                return { _ in
                    blackHole(input.meanSquaredError(to: target))
                }
            },
            forward: { input, target in
                { _ in
                    blackHole(valueWithPullback(
                        at: input,
                        of: {
                            var input = $0
                            return input.meanSquaredError(to: target)
                        }
                    ))
                }
            },
            reverse: { input, target in
                let pullback = valueWithPullback(
                    at: input,
                    of: {
                        var x0 = $0
                        return x0.meanSquaredError(to: target)
                    }
                ).pullback
                return { _ in
                    blackHole(pullback(Float(1.0)))
                }
            }
        )
    }
}
