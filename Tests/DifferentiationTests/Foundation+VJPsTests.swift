#if canImport(_Differentiation)

import Differentiation
import Foundation
import Testing

@Suite("Derivatives of native functions")
struct FoundationVJPsTests {
    @Test
    func testAtan2() {
        // I'm using this container because the compiler can't quite determine
        // the type of a top-level min() function passed into gradient(at:of:).
        @differentiable(reverse)
        func atan2Container(_ p1: Double, _ p2: Double) -> Double {
            return atan2(p1, p2)
        }
        let vwg = valueWithGradient(at: 1.0, 1.0, of: atan2Container)
        #expect(vwg.value == .pi / 4)
        #expect(vwg.gradient == (0.5, -0.5))
    }
}

#endif
