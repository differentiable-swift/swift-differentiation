import CollectionsBenchmark
import Differentiation
import Foundation

// MARK: Array.meanSquaredError

extension Array where Element == Float {
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
    public mutating func meanSquaredError(to target: ConstantTimeAccessor<Float>) -> Float {
        // precondition(self.count == target.count)
        var mse: Float = 0
        var target = target
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
