import Differentiation
import Testing

#if canImport(_Differentiation)

@Suite
struct InlineArrayTests {
    // Test that the zero additive arithmetic gives an array of zeros
    @Test("zero produces repeating zero elements")
    @available(macOS 26, *)
    func zeroProducesZeros() {
        let z = InlineArray<2, Double>.zero
        #expect(z[0] == 0.0)
        #expect(z[1] == 0.0)
    }

    // Test + and - work elementwise
    @Test("additive arithmetic + and − are elementwise")
    @available(macOS 26, *)
    func additiveArithmeticAddSubtract() {
        let a = InlineArray<2, Double>(repeating: 1.5) // [1.5, 1.5]
        let b: InlineArray<2, Double> = [2.0, 3.0]
        let sum = a + b
        #expect(sum[0] == 3.5)
        #expect(sum[1] == 4.5)
        let diff = b - a
        #expect(diff[0] == 0.5)
        #expect(diff[1] == 1.5)
    }

    // Test differentiable init(repeating:)
    @Test("vjp of init(repeating:) aggregates tangent inputs correctly")
    @available(macOS 26, *)
    func testVJPInitRepeating() {
        // For differentiable init(repeating:), the pullback should sum all elements of the tangent vector
        let repeated = InlineArray<2, Double>(repeating: 4.0)
        // forward run
        // Now test pullback: apply VJP
        // The API for using VJP: call `valueWithPullback` or similar
        let (value, pullback) = valueWithPullback(at: 4.0, of: { value in InlineArray<2, Double>(repeating: value) })
        // value should equal what init(repeating:) produces
        #expect(value == repeated)

        // construct some tangent vector
        let tv: InlineArray<2, Double> = [10.0, 20.0]
        // apply pullback
        let back = pullback(tv)
        // Should equal sum of elements, i.e. 10 + 20 == 30, as Double’s tangent
        #expect(back == 30.0)
    }

    @Test("vjp of read is correct")
    @available(macOS 26, *)
    func testVJPRead() {
        let arr: InlineArray<2, Double> = [5.0, 7.0]
        let index = 1
        let (value, pullback) = valueWithPullback(at: arr, of: { value in value.read(index) })
        #expect(value == 7.0)
        // Tangent vector for output
        let outTangent = 3.0
        let backVec = pullback(outTangent) // this returns a T2
        // It should have zero except at that index where it's outTangent
        #expect(backVec[0] == 0.0)
        #expect(backVec[1] == 3.0)
    }

    @Test("vjp of update mutating works")
    @available(macOS 26, *)
    func testVJPUpdate() {
        let arr: InlineArray<2, Double> = [1.0, 2.0]
        let index = 0
        let newValue = 100.0

        // Apply the derivative via VJP of update
        // Because update is mutating, the pullback signature is a bit different
        // Use the manual _vjpUpdate
        let (value, pullback) = valueWithPullback(
            at: arr, newValue,
            of: { arr, newValue in
                var arr = arr
                arr.update(at: index, with: newValue)
                return arr
            }
        )
        // After update, arr[0] should be newValue
        #expect(value[0] == 100.0)
        #expect(value[1] == 2.0)

        // Suppose we have a tangent vector v for the whole array
        let tangent: InlineArray<2, Double> = [10.0, 20.0]
        // Pullback should take and zero out the tangent component at `index`, returning the old tangent at that index
        let result = pullback(tangent)
        #expect(result.1 == 10.0)
        // After pullback, tangent[0] should be zero, tangent[1] remains 20
        #expect(result.0[0] == 0.0)
        #expect(result.0[1] == 20.0)
    }

    // You could test move(by:) on the tangent vector space
    @Test("move(by:) translates elements correctly")
    @available(macOS 26, *)
    func testMoveBy() {
        var arr: InlineArray<2, Double> = [1.0, 2.0]
        let offset: InlineArray<2, Double> = [1.0, 2.0]
        arr.move(by: offset)
        // After move, arr should be [1+1, 2+2] == [2,4]
        #expect(arr[0] == 2.0)
        #expect(arr[1] == 4.0)
    }
}

#endif
