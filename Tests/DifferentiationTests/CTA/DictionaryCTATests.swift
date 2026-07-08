import Differentiation
import Testing

/// High-level differentiation tests for the `cta:` accessor on `Dictionary`.
///
/// The tangent is `[Key: Value.TangentVector]` and the pullback accumulates sparsely in place, so
/// gradients only contain entries for keys that were actually touched.
@Suite("Dictionary cta: accessors")
struct DictionaryCTATests {
    // MARK: - get

    @Test func getGradient() {
        @differentiable(reverse)
        func f(_ d: [String: Double]) -> Double {
            var d = d
            let v = d[cta: "a"]!
            return v * v
        }
        // d/d a (a^2) = 2 * a = 6; "b" is untouched, so it is absent from the sparse gradient.
        #expect(gradient(at: ["a": 3, "b": 5], of: f) == ["a": 6])
    }

    @Test func getAccumulatesRepeatedReads() {
        @differentiable(reverse)
        func f(_ d: [String: Double]) -> Double {
            var d = d
            return d[cta: "a"]! + d[cta: "a"]!
        }
        // Reading the same key twice must accumulate in place → gradient 2, not 1.
        #expect(gradient(at: ["a": 3], of: f) == ["a": 2])
    }

    // MARK: - set

    @Test func setGradient() {
        @differentiable(reverse)
        func f(_ d: [String: Double], _ newA: Double) -> Double {
            var d = d
            d[cta: "a"] = newA
            return d[cta: "a"]! * 3
        }
        // result = 3 * newA; d/d newA = 3; "a" is overwritten so its incoming gradient is consumed.
        let g = gradient(at: ["a": 1], 5, of: f)
        #expect(g.0 == ["a": 0])
        #expect(g.1 == 3)
    }
}
