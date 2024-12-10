#if canImport(_Differentiation)

import Differentiation
import Testing

@Suite("Derivatives of native functions")
struct DerivativesOfNativeFunctionsTests {
    @Test
    func testMin() {
        // I'm using this container because the compiler can't quite determine
        // the type of a top-level min() function passed into gradient(at:of:).
        @differentiable(reverse)
        func minContainer(_ lhs: Float, _ rhs: Float) -> Float {
            min(lhs, rhs)
        }
        let vwgLessThan = valueWithGradient(at: 2.0, 3.0, of: minContainer)
        #expect(vwgLessThan.value == 2.0)
        #expect(vwgLessThan.gradient == (1.0, 0.0))
        let vwgGreaterThan = valueWithGradient(at: 20.0, -2.0, of: minContainer)
        #expect(vwgGreaterThan.value == -2.0)
        #expect(vwgGreaterThan.gradient == (0.0, 1.0))
    }

    @Test
    func testMax() {
        // I'm using this container because the compiler can't quite determine
        // the type of a top-level min() function passed into gradient(at:of:).
        @differentiable(reverse)
        func maxContainer(_ lhs: Float, _ rhs: Float) -> Float {
            max(lhs, rhs)
        }
        let vwgLessThan = valueWithGradient(at: 2.0, 3.0, of: maxContainer)
        #expect(vwgLessThan.value == 3.0)
        #expect(vwgLessThan.gradient == (0.0, 1.0))
        let vwgGreaterThan = valueWithGradient(at: 20.0, -2.0, of: maxContainer)
        #expect(vwgGreaterThan.value == 20.0)
        #expect(vwgGreaterThan.gradient == (1.0, 0.0))
    }

    @Test
    func testAbs() {
        // I'm using this container because the compiler can't quite determine
        // the type of a top-level abs() function passed into gradient(at:of:).
        @differentiable(reverse)
        func absContainer(_ value: Float) -> Float {
            abs(value)
        }

        let vwgPositive = valueWithGradient(at: 4.0, of: absContainer)
        #expect(vwgPositive.value == 4.0)
        #expect(vwgPositive.gradient == 1.0)

        let vwgNegative = valueWithGradient(at: -4.0, of: absContainer)
        #expect(vwgNegative.value == 4.0)
        #expect(vwgNegative.gradient == -1.0)
    }
}

#endif
