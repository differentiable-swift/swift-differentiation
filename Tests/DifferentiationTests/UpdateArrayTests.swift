#if canImport(_Differentiation)

import PLDifferentiation
import XCTest

final class UpdateArrayTests: XCTestCase {
    func testUpdateWithValue() throws {
        // let's test a function of an array where we modify the array elements
        // using a mutating closure
        @differentiable(reverse)
        func fOfArray(array: [Double]) -> Double {
            var array = array
            var result: Double = 0
            for index in withoutDerivative(at: 0 ..< array.count) {
                let multiplier = 1.0 + Double(index)
                array.update(at: index, with: multiplier * array[index])
                result += array[index]
            }
            return result
        }

        let array = [Double](repeating: 1.0, count: 3)
        let expectedGradientOfFOfArray = [1.0, 2.0, 3.0]
        let obtainedGradientOfFOfArray = gradient(at: array, of: fOfArray).base
        // using XCTAssertTrue instead of XCTAssertEqual so that it uses a nicely formatted message
        XCTAssertEqual(
            obtainedGradientOfFOfArray,
            expectedGradientOfFOfArray,
            "While differentiating fOfArray, expected \(expectedGradientOfFOfArray) for the gradient but got \(obtainedGradientOfFOfArray) ! "
        )
    }
}

#endif
