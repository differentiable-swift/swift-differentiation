import Differentiation
import Testing

@Suite
struct RunWithoutDerivativeTests {
    @Test
    func reserveCapacity() {
        @differentiable(reverse)
        func f(x: Double) -> [Double] {
            var array: [Double] = []
            let capacity = 3

            runWithoutDerivative {
                array.reserveCapacity(capacity)
            }

            for _ in 0 ..< capacity {
                array.append(x)
            }

            return array
        }

        #expect(f(x: 5.0) == [5.0, 5.0, 5.0])
    }

    @Test
    func ignoreSquaredContribution() {
        @differentiable(reverse)
        func f(x: Double) -> Double {
            x + runWithoutDerivative { x * x }
        }

        let (value, gradient) = valueWithGradient(at: 2.0, of: f)
        #expect(value == 6.0)
        #expect(gradient == 1.0) // instead of the normally expected 5.0
    }
}
