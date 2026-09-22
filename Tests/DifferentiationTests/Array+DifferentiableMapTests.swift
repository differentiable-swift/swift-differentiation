import Differentiation
import Testing

#if compiler(>=6.4)
@Suite
struct ArrayDifferentiableThrowingMapTests {
    struct NegativeInputError: Error, Equatable {}

    @Test
    func testDifferentiableThrowingMapNonThrowingPath() throws {
        @differentiable(reverse)
        func testFunc(_ x: [Double]) throws -> [Double] {
            try x.differentiableThrowingMap { $0 * $0 * $0 }
        }
        let (value, pullback) = try valueWithPullback(at: [1.0, 2.0, 3.0], of: testFunc)
        #expect(value == [1.0, 8.0, 27.0])
        #expect(pullback(.init([1.0, 1.0, 1.0])) == .init([3.0, 12.0, 27.0]))
    }

    @Test
    func testDifferentiableThrowingMapTypedThrowsPropagation() throws {
        @differentiable(reverse)
        func testFunc(_ x: [Double]) throws(NegativeInputError) -> [Double] {
            try x.differentiableThrowingMap { (v: Double) throws(NegativeInputError) -> Double in
                if v < 0 { throw NegativeInputError() }
                return v * v
            }
        }

        #expect(throws: NegativeInputError.self) {
            try valueWithPullback(at: [1.0, -2.0, 3.0], of: testFunc)
        }

        let (value, pullback) = try valueWithPullback(at: [1.0, 2.0], of: testFunc)
        #expect(value == [1.0, 4.0])
        #expect(pullback(.init([1.0, 1.0])) == .init([2.0, 4.0]))
    }

    @Test
    func testDifferentiableThrowingMapEmptyArray() throws {
        @differentiable(reverse)
        func testFunc(_ x: [Double]) throws -> [Double] {
            try x.differentiableThrowingMap { $0 * 2.0 }
        }
        let (value, pullback) = try valueWithPullback(at: [], of: testFunc)
        #expect(value == [])
        #expect(pullback(.init([])) == .init([]))
    }
}
#endif
