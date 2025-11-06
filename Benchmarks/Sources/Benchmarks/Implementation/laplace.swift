import CollectionsBenchmark
import Differentiation
import Foundation

// MARK: laplace 1D/three-point-stencil

extension Array where Element == Float {
    @inlinable
    @differentiable(reverse)
    func laplace(_ i: Index) -> Element {
        self[i - 1] - (2 * self[i]) + self[i + 1]
    }

    @inlinable
    @differentiable(reverse)
    func laplace() -> Self {
        let n = self.count
        var result = self
        guard n > 2 else {
            return result
        }
        for i in withoutDerivative(at: 1 ..< n - 1) {
            result.update(at: i, with: self.laplace(i))
        }
        return result
    }
}

private let benchmarkTitle = "laplace"

extension Array where Element == Float {
    static func addLaplaceBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            regular: { input in
                { _ in
                    blackHole(input.laplace())
                }
            },
            forward: { input in
                { _ in
                    blackHole(valueWithPullback(at: input, of: { $0.laplace() }))
                }
            },
            reverse: { input in
                let pullback = valueWithPullback(
                    at: input, of: { $0.laplace() }
                ).pullback
                var tangent = Array<Float>.TangentVector(
                    repeating: 0, count: input.count
                )
                tangent[0] = 1.0
                return { _ in
                    blackHole(pullback(tangent))
                }
            }
        )
    }
}
