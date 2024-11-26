#if canImport(_Differentiation)

import PLDifferentiation
import XCTest

final class DifferentiableMinMaxTests: XCTestCase {
    let inputArray = [2.0, 1.0, 3.0]

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
        XCTAssertEqual(value, 5.0, "Result of \(value) did not match expected value of 5.0")
        XCTAssertEqual(gradient, [0.0, 10.0, 0.0], "Gradient of \(gradient) did not match expected value of [0.0, 10.0, 0.0]")
    }

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
        XCTAssertEqual(value, 45.0, "Result of \(value) did not match expected value of 45.0")
        XCTAssertEqual(gradient, [0.0, 0.0, 30.0], "Gradient of \(gradient) did not match expected value of [0.0, 0.0, 30.0]")
    }
}

#endif
