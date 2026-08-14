import CollectionsBenchmark
import Differentiation
import Foundation

// MARK: 1D finite difference/two-point-stencil

extension Array where Element == Float {
    @inlinable
    @differentiable(reverse)
    func finiteDifference() -> Self {
        let n = withoutDerivative(at: self.count)
        guard n > 1 else {
            return []
        }
        var result = Self(repeating: 0.0, count: n - 1)
        for i in withoutDerivative(at: 0 ..< (n - 1)) {
            result.update(at: i, with: self[i + 1] - self[i])
        }
        return result
    }

    @inlinable
    @derivative(of: finiteDifference)
    func _vjpFiniteDifference() -> (value: Self, pullback: (TangentVector) -> TangentVector) {
        let value = self.finiteDifference()
        return (value, { v in
            let n = self.count
            guard n > 1 else {
                return TangentVector(repeating: 0, count: n)
            }
            var grad = TangentVector(repeating: 0, count: n)

            // Transpose of the 2-point stencil
            // Forward: result[j] = self[j+1] - self[j]
            // Transpose: grad[j] += -v[j], grad[j+1] += v[j]
            grad[0] = -v[0]
            for j in 1 ..< n - 1 {
                grad[j] = v[j - 1] - v[j]
            }
            grad[n - 1] = v[n - 2]

            return grad
        })
    }
}

private let benchmarkTitle = "finiteDifference"

extension Array where Element == Float {
    static func addFiniteDifferenceBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            regular: { input in
                { _ in
                    blackHole(input.finiteDifference())
                }
            },
            forward: { input in
                { _ in
                    blackHole(valueWithPullback(at: input, of: { $0.finiteDifference() }))
                }
            },
            reverse: { input in
                let (value, pullback) = valueWithPullback(
                    at: input, of: { $0.finiteDifference() }
                )
                var tangent = Array<Float>.TangentVector(
                    repeating: 0, count: value.count
                )
                if !tangent.isEmpty {
                    tangent[0] = 1.0
                }
                return { _ in
                    blackHole(pullback(tangent))
                }
            }
        )
    }
}
