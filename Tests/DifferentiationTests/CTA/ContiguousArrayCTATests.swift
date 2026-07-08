import Differentiation
import Testing

/// High-level differentiation tests for the `cta:` accessors on `ContiguousArray`.
///
/// Like `Array`, `ContiguousArray` is always zero-based, so the range-get pullback is correct
/// (no `startIndex` offset to account for). `ContiguousArray.TangentVector` is
/// `ExpressibleByArrayLiteral` + `Equatable`, so gradients compare directly against a literal.
@Suite("ContiguousArray cta: accessors")
struct ContiguousArrayCTATests {
    // MARK: - scalar get

    @Test func scalarGetGradient() {
        @differentiable(reverse)
        func f(_ ca: ContiguousArray<Float>) -> Float {
            var ca = ca
            let v = ca[cta: 1]
            return v * v
        }
        // d/dx (ca[1]^2) = 2 * ca[1] = 6 at index 1, zero elsewhere.
        #expect(gradient(at: [2, 3, 4] as ContiguousArray<Float>, of: f) == [0, 6, 0])
    }

    @Test func scalarGetAccumulatesRepeatedReads() {
        @differentiable(reverse)
        func f(_ ca: ContiguousArray<Float>) -> Float {
            var ca = ca
            return ca[cta: 1] + ca[cta: 1]
        }
        // Reading the same index twice must accumulate into the existing tangent.
        #expect(gradient(at: [2, 3, 4] as ContiguousArray<Float>, of: f) == [0, 2, 0])
    }

    // MARK: - scalar set

    @Test func scalarSetGradient() {
        @differentiable(reverse)
        func f(_ ca: ContiguousArray<Float>) -> Float {
            var ca = ca
            ca[cta: 1] = ca[cta: 0] * ca[cta: 0]
            return ca[cta: 1]
        }
        // result = ca[0]^2 (index 1 overwritten); d/d ca[0] = 2 * ca[0] = 4.
        #expect(gradient(at: [2, 3, 4] as ContiguousArray<Float>, of: f) == [4, 0, 0])
    }

    @Test func zeroSeedProducesZeroTangent() {
        func f(_ ca: ContiguousArray<Float>) -> Float {
            var ca = ca
            return ca[cta: 1]
        }
        let (_, pb) = valueWithPullback(at: [1, 2, 3] as ContiguousArray<Float>, of: f)
        #expect(pb(.zero).base.allSatisfy { $0 == .zero })
    }

    // MARK: - range get

    @Test func rangeGetGradient() {
        @differentiable(reverse)
        func f(_ ca: ContiguousArray<Float>) -> Float {
            var ca = ca
            return ca[cta: 1 ..< 3].differentiableReduce(0) { $0 + $1 }
        }
        // Sum of elements 1 and 2 resulting in the unit gradient on those indices, zero elsewhere.
        #expect(gradient(at: [10, 20, 30, 40] as ContiguousArray<Float>, of: f) == [0, 1, 1, 0])
    }
}
