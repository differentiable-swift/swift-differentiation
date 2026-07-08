import Differentiation
import Testing

/// High-level differentiation tests for the `cta:` accessors on `Array`.
///
/// `Array` is always zero-based, so no `startIndex` offset is involved — these are the
/// straightforward baseline against which the `ArraySlice` suite is compared.
@Suite("Array cta: accessors")
struct ArrayCTATests {
    // MARK: - scalar get

    @Test func scalarGetGradient() {
        @differentiable(reverse)
        func f(_ array: [Float]) -> Float {
            var array = array
            let v = array[cta: 1]
            return v * v
        }
        // d/dx (array[1]^2) = 2 * array[1] = 6 at index 1, zero elsewhere.
        #expect(gradient(at: [2, 3, 4], of: f) == [0, 6, 0])
    }

    @Test func scalarGetAccumulatesRepeatedReads() {
        @differentiable(reverse)
        func f(_ array: [Float]) -> Float {
            var array = array
            return array[cta: 1] + array[cta: 1]
        }
        // Reading the same index twice must accumulate into the existing tangent.
        #expect(gradient(at: [2, 3, 4], of: f) == [0, 2, 0])
    }

    // MARK: - scalar set

    @Test func scalarSetGradient() {
        @differentiable(reverse)
        func f(_ array: [Float]) -> Float {
            var array = array
            array[cta: 1] = array[cta: 0] * array[cta: 0]
            return array[cta: 1]
        }
        // result = array[0]^2 (index 1 is overwritten, so its incoming tangent is consumed).
        // d/d array[0] = 2 * array[0] = 4; indices 1 and 2 contribute nothing.
        #expect(gradient(at: [2, 3, 4], of: f) == [4, 0, 0])
    }

    @Test func zeroSeedProducesZeroTangent() {
        func f(_ array: [Float]) -> Float {
            var array = array
            return array[cta: 1]
        }
        let (_, pb) = valueWithPullback(at: [1, 2, 3], of: f)
        #expect(pb(.zero).base.allSatisfy { $0 == .zero })
    }

    // MARK: - range get

    @Test func rangeGetGradient() {
        @differentiable(reverse)
        func f(_ array: [Float]) -> Float {
            var array = array
            return array[cta: 1 ..< 3].differentiableReduce(0) { $0 + $1 }
        }
        // Sum of elements 1 and 2 resulting in the unit gradient at those indices and zero elsewhere.
        #expect(gradient(at: [10, 20, 30, 40], of: f) == [0, 1, 1, 0])
    }
}
