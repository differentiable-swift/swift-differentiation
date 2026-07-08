import Differentiation
import Testing

/// High-level differentiation tests for the `cta:` accessors on `ArraySlice`.
///
/// Unlike `Array`/`ContiguousArray`, an `ArraySlice` can have a non-zero `startIndex`. Its
/// pullbacks build a *zero-based* tangent buffer of `count` elements, so absolute slice indices
/// must be mapped back with `- startIndex`. These tests deliberately exercise slices built via
/// `base[k...]` (`startIndex == k`) to cover that mapping.
///
/// `ArraySlice.DifferentiableView` equality is element-wise (`base == base`, indices ignored) and
/// the tangent buffer is always zero-based, so gradients compare directly against a literal.
@Suite("ArraySlice cta: accessors")
struct ArraySliceCTATests {
    // MARK: - scalar get

    @Test func scalarGetGradient() {
        @differentiable(reverse)
        func f(_ s: ArraySlice<Float>) -> Float {
            var s = s
            let v = s[cta: 1]
            return v * v
        }
        #expect(gradient(at: ArraySlice<Float>([2, 3, 4]), of: f) == [0, 6, 0])
    }

    /// Non-zero `startIndex`: proves the scalar getter's `index - lowerBound` mapping is correct.
    @Test func scalarGetGradientNonZeroStartIndex() {
        let base: [Float] = [0, 10, 20, 30]
        let slice = base[1...] // startIndex 1, elements [10, 20, 30]
        let idx = slice.startIndex + 1 // absolute index 2, second element of the slice
        @differentiable(reverse)
        func f(_ s: ArraySlice<Float>) -> Float {
            var s = s
            let v = s[cta: idx]
            return v * v
        }
        // Reads the second slice element (value 20) resulting in gradient 2*20 = 40 at zero-based position 1.
        #expect(gradient(at: slice, of: f) == [0, 40, 0])
    }

    // MARK: - scalar set

    @Test func scalarSetGradient() {
        @differentiable(reverse)
        func f(_ s: ArraySlice<Float>) -> Float {
            var s = s
            s[cta: 1] = s[cta: 0] * s[cta: 0]
            return s[cta: 1]
        }
        #expect(gradient(at: ArraySlice<Float>([2, 3, 4]), of: f) == [4, 0, 0])
    }

    /// Non-zero `startIndex`: proves the scalar setter's `index - lowerBound` mapping is correct.
    @Test func scalarSetGradientNonZeroStartIndex() {
        let base: [Float] = [0, 2, 3, 4]
        let slice = base[1...] // startIndex 1, elements [2, 3, 4]
        let lo = slice.startIndex // absolute index 1, first element of the slice
        let hi = slice.startIndex + 1 // absolute index 2, second element of the slice
        @differentiable(reverse)
        func f(_ s: ArraySlice<Float>) -> Float {
            var s = s
            s[cta: hi] = s[cta: lo] * s[cta: lo]
            return s[cta: hi]
        }
        // result = slice[0]^2 = 2^2; d/d slice[0] = 2*2 = 4 at zero-based position 0.
        #expect(gradient(at: slice, of: f) == [4, 0, 0])
    }

    // MARK: - range get

    @Test func rangeGetGradient() {
        @differentiable(reverse)
        func f(_ s: ArraySlice<Float>) -> Float {
            var s = s
            return s[cta: 0 ..< 2].differentiableReduce(0) { $0 + $1 }
        }
        #expect(gradient(at: ArraySlice<Float>([10, 20, 30]), of: f) == [1, 1, 0])
    }

    @Test func rangeGetGradientNonZeroStartIndex() {
        let base: [Float] = [10, 20, 30, 40]
        let slice = base[2...] // startIndex 2, elements [30, 40]
        @differentiable(reverse)
        func f(_ s: ArraySlice<Float>) -> Float {
            var s = s
            return s[cta: 2 ..< 4].differentiableReduce(0) { $0 + $1 }
        }
        // Sum over both slice elements resulting in the unit gradient on element.
        #expect(gradient(at: slice, of: f) == [1, 1])
    }
}
