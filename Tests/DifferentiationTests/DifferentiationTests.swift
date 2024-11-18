import Testing
@testable import Differentiation

@Suite("Basic Differentiation") struct BasicDifferentiationTests {
    @differentiable(reverse)
    private func xSquared(x: Double) -> Double {
        return x * x
    }

    private struct Vector2: Differentiable {
        var x: Double
        var y: Double
    }

    private func selfDotProduct(of vector: Vector2) -> Double {
        return (vector.x * vector.x) + (vector.y * vector.y)
    }

    @Test func simpleFunctionDerivative() {
        #expect(gradient(at: 3, of: xSquared) == 6.0)
    }

    @Test func simpleStructDerivative() {
        let gradientOfDotProduct = gradient(at: Vector2(x: 5.0, y: 5.0), of: selfDotProduct)
        #expect(gradientOfDotProduct == Vector2.TangentVector(x: 10.0, y: 10.0))
    }

}
