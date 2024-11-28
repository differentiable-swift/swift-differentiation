#if canImport(_Differentiation)

import Differentiation
import Testing

@Suite("Sequence+MinMaxVJPs")
struct SequenceMinMaxVJPs {

    let inputArray = [2.0, 1.0, 3.0]

    @Test
    func testDifferentiableMin() throws {
        @differentiable(reverse)
        func wrapper(_ value: [Double]) -> Double {
            var newValue: Double = 0
            if let unwrappedVal = value.min() {
                newValue = 5.0 * unwrappedVal * unwrappedVal
            }
            return newValue
        }

        let (value, gradient) = valueWithGradient(at: inputArray, of: wrapper)
        #expect(value == 5.0)
        #expect(gradient == [0.0, 10.0, 0.0])
    }

    @Test
    func testDifferentiableMax() throws {
        @differentiable(reverse)
        func wrapper(_ value: [Double]) -> Double {
            var newValue: Double = 0
            if let unwrappedVal = value.max() {
                newValue = 5.0 * unwrappedVal * unwrappedVal
            }
            return newValue
        }

        let (value, gradient) = valueWithGradient(at: inputArray, of: wrapper)
        #expect(value == 45.0)
        #expect(gradient == [0.0, 0.0, 30.0])
    }
}

#endif
