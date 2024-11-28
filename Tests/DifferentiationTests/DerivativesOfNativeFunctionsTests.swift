#if canImport(_Differentiation)

@testable import PLDifferentiation
import XCTest

final class NativeFunctionDerivativesTests: XCTestCase {

    func testMin() {
        // I'm using this container because the compiler can't quite determine
        // the type of a top-level min() function passed into gradient(at:of:).
        @differentiable(reverse)
        func minContainer(_ lhs: Float, _ rhs: Float) -> Float {
            return min(lhs, rhs)
        }

        let gradLessThan = gradient(at: 2.0, 3.0, of: minContainer)
        XCTAssertEqual(gradLessThan.0, 1.0, accuracy: 0.001)
        XCTAssertEqual(gradLessThan.1, 0.0, accuracy: 0.001)
        let gradGreaterThan = gradient(at: 20.0, -2.0, of: minContainer)
        XCTAssertEqual(gradGreaterThan.0, 0.0, accuracy: 0.001)
        XCTAssertEqual(gradGreaterThan.1, 1.0, accuracy: 0.001)
    }

    func testMax() {
        // I'm using this container because the compiler can't quite determine
        // the type of a top-level min() function passed into gradient(at:of:).
        @differentiable(reverse)
        func maxContainer(_ lhs: Float, _ rhs: Float) -> Float {
            return max(lhs, rhs)
        }

        let gradLessThan = gradient(at: 2.0, 3.0, of: maxContainer)
        XCTAssertEqual(gradLessThan.0, 0.0, accuracy: 0.001)
        XCTAssertEqual(gradLessThan.1, 1.0, accuracy: 0.001)
        let gradGreaterThan = gradient(at: 20.0, -2.0, of: maxContainer)
        XCTAssertEqual(gradGreaterThan.0, 1.0, accuracy: 0.001)
        XCTAssertEqual(gradGreaterThan.1, 0.0, accuracy: 0.001)
    }

    func testAbs() {
        // I'm using this container because the compiler can't quite determine
        // the type of a top-level abs() function passed into gradient(at:of:).
        @differentiable(reverse)
        func absContainer(_ value: Float) -> Float {
            return abs(value)
        }

        let gradPositive = gradient(at: 4.0, of: absContainer)
        XCTAssertEqual(gradPositive, 1.0, accuracy: 0.001)

        let gradNegative = gradient(at: -4.0, of: absContainer)
        XCTAssertEqual(gradNegative, -1.0, accuracy: 0.001)

    }
}

#endif
