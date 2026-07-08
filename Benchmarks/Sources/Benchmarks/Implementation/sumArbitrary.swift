import CollectionsBenchmark
import Differentiation
import Foundation

// MARK: Array<Float>.sumArbitrary

extension Array where Element == Float {
    @inlinable
    @differentiable(reverse)
    func sumArbitrary(indices: [Index]) -> Float {
        var result: Element = 0
        for i in withoutDerivative(at: indices) {
            result += self[i]
        }
        return result
    }

    @inlinable
    @derivative(of: sumArbitrary)
    func _vjpSumArbitrary(indices: [Index]) -> (value: Float, pullback: (Float) -> TangentVector) {
        let value = self.sumArbitrary(indices: indices)
        return (value, { v in
            var grad = TangentVector(repeating: 0, count: self.count)
            for i in indices {
                grad[i] += v
            }
            return grad
        })
    }
}

private let benchmarkTitle = "sumArbitrary"

extension Array where Element == Float {
    static func addSumArbitraryBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            regular: { input in
                let indicesCount = Int(floor(Double(input.count) / Double(4)))
                let indices = (0 ..< indicesCount).map { _ in Int.random(in: 0 ..< input.count) }
                return { _ in
                    blackHole(input.sumArbitrary(indices: indices))
                }
            },
            forward: { input in
                let indicesCount = Int(floor(Double(input.count) / Double(4)))
                let indices = (0 ..< indicesCount).map { _ in Int.random(in: 0 ..< input.count) }
                return { _ in
                    blackHole(valueWithPullback(at: input, of: { $0.sumArbitrary(indices: indices) }))
                }
            },
            reverse: { input in
                let indicesCount = Int(floor(Double(input.count) / Double(4)))
                let indices = (0 ..< indicesCount).map { _ in Int.random(in: 0 ..< input.count) }
                let pullback = valueWithPullback(
                    at: input, of: { $0.sumArbitrary(indices: indices) }
                ).pullback
                return { _ in
                    blackHole(pullback(1.0))
                }
            }
        )
    }
}
