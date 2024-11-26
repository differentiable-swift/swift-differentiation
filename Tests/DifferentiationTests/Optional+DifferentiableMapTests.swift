#if canImport(_Differentiation)

import PLDifferentiation
import XCTest

final class OptionalDifferentiableMapTests: XCTestCase {
    func testOptionalDifferentiableMap() {
        @differentiable(reverse)
        func testFunc(_ x: Double?) -> Double? {
            x.differentiableMap { $0 * $0 * $0 }
        }
        XCTAssertEqual(pullback(at: 1.0, of: testFunc)(.init(1.0)), .init(3.0))
        XCTAssertEqual(pullback(at: nil, of: testFunc)(.init(1.0)), .init(0.0))
        XCTAssertEqual(pullback(at: 0.0, of: testFunc)(.init(1.0)), .init(0.0))
    }
}

#endif
