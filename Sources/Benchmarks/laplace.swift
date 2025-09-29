import CollectionsBenchmark
import Differentiation
import Foundation

protocol HasLaplaceBenchmark {
    associatedtype Index
    associatedtype Element
    func laplace() -> Self
    static func addLaplaceBenchmarks(_ benchmark: inout Benchmark)
}

extension HasLaplaceBenchmark {
    static func addLaplaceBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            input: Array<Float>.self,
            regular: { input in
                { timer in
                    blackHole(input.laplace())
                }
            },
            forward: { input in
                { timer in
                    blackHole(valueWithPullback(at: input, of: { $0.laplace() }))
                }
            },
            reverse: { input in
                let pullback = valueWithPullback(
                    at: input, of: { $0.laplace() }
                ).pullback
                var tangent = Array<Float>.TangentVector(
                    repeating: 0, count: input.count)
                tangent[0] = 1.0
                return { timer in
                    blackHole(pullback(tangent))
                }
            }
        )
    }
}

// MARK: laplace 1D/three-point-stencil
extension Array where Element == Float {
    @inlinable
    @differentiable(reverse)
    func laplace(_ i: Index) -> Element {
        return self[i - 1] - (2 * self[i]) + self[i + 1]
    }

    @inlinable
    @differentiable(reverse)
    func laplace() -> Self {
        let n = self.count
        var result = self
        guard n > 2 else {
            return result
        }
        for i in withoutDerivative(at: 1..<n - 1) {
            result[i] = self.laplace(i)
        }
        return result
    }
}

extension DArray where Element == Float {
    @inlinable
    @differentiable(reverse)
    func laplace(_ i: Index) -> Element {
        return self[i - 1] - (2 * self[i]) + self[i + 1]
    }

    @inlinable
    @differentiable(reverse)
    func laplace() -> Self {
        let n = self.count
        var result = self
        guard n > 2 else {
            return result
        }
        for i in withoutDerivative(at: 1..<n - 1) {
            result[i] = self.laplace(i)
        }
        return result
    }
}

// MARK: stencil/laplace
extension ConstantTimeAccessor where Element == Float {
    @inlinable
    @differentiable(reverse)
    mutating func laplace(_ i: Int) -> Element {
        self.accessElement(at: i - 1)
        let prev = self.accessed
        self.accessElement(at: i)
        let mid = self.accessed
        self.accessElement(at: i + 1)
        let next = self.accessed
        return prev + next - 2 * mid
    }
}


// MARK: stencil/laplace
extension DCTA where Element == Float {
    @inlinable
    @differentiable(reverse)
    mutating func laplace(_ i: Int) -> Element {
        return self[i-1] - 2 * self[i] + self[i+1]
    }
}

extension ConstantTimeAccessor where Element == Float {
    @inlinable
    @differentiable(reverse)
    mutating func laplace() -> Self {
        let n = self.count
        var result = self
        guard n > 2 else {
            return result
        }
        for i in withoutDerivative(at: 1..<n - 1) {
            result.update(at: i, with: self.laplace(i))
        }
        return result
    }
}

extension DCTA where Element == Float {
    @inlinable
    @differentiable(reverse)
    mutating func laplace() -> Self {
        let n = self.count
        var result = self
        guard n > 2 else {
            return result
        }
        for i in withoutDerivative(at: 1..<n - 1) {
            result[i] = self.laplace(i)
        }
        return result
    }
}

fileprivate let benchmarkTitle = "laplace"

extension ConstantTimeAccessor where Element == Float {
    static func addLaplaceBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: DArray<Float>.self,
            input: Array<Float>.self,
            regular: { input in
                var input = ConstantTimeAccessor(input)
                return { timer in
                    blackHole(input.laplace())
                }
            },
            forward: { input in
                let input = ConstantTimeAccessor(input)
                return { timer in
                    blackHole(
                        valueWithPullback(
                            at: input,
                            of: {
                                var input = $0
                                return input.laplace()
                            }
                        ).value
                    )
                }
            },
            reverse: { input in
                let input = ConstantTimeAccessor(input)
                let pullback = valueWithPullback(
                    at: input,
                    of: {
                        var input = $0
                        return input.laplace()
                    }
                ).pullback
                var tangent = ConstantTimeAccessor([Float](repeating: .zero, count: input.count))
                tangent.update(at: 0, with: 1.0)
                return { timer in
                    blackHole(pullback(tangent))
                }
            }
        )
    }
}

extension DCTA where Element == Float {
    static func addLaplaceBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            input: Array<Float>.self,
            regular: { input in
                var input = DCTA(input)
                return { timer in
                    blackHole(input.laplace())
                }
            },
            forward: { input in
                let input = DCTA(input)
                return { timer in
                    blackHole(
                        valueWithPullback(
                            at: input,
                            of: {
                                var input = $0
                                return input.laplace()
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
                        var input = $0
                        return input.laplace()
                    }
                ).pullback
                var tangent = DCTA([Float](repeating: .zero, count: input.count))
                tangent[0] = 1.0
                return { timer in
                    blackHole(pullback(tangent))
                }
            }
        )
    }
}
