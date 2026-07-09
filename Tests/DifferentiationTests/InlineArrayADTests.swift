import Differentiation
import Testing

#if swift(>=6.2)

/// High-level differentiation tests for the `ad:` accessor on `InlineArray`.
///
/// The getter is non-mutating (fixed compile-time size → no lazy tangent allocation), so it reads
/// directly off an immutable value. The tangent is itself an `InlineArray<count, Element.TangentVector>`.
@Suite
struct InlineArrayADTests {
    @Test
    @available(macOS 26, iOS 26, *)
    func getGradient() {
        let arr: InlineArray<3, Double> = [2, 3, 4]
        // Non-mutating getter: usable on the immutable closure parameter directly.
        let (value, pb) = valueWithPullback(at: arr, of: { $0[ad: 1] * $0[ad: 1] })
        #expect(value == 9)
        let g = pb(1)
        // d/d a[1] (a[1]^2) = 2 * 3 = 6; reading the same index twice accumulates.
        #expect(g[0] == 0)
        #expect(g[1] == 6)
        #expect(g[2] == 0)
    }

    @Test
    @available(macOS 26, iOS 26, *)
    func setGradient() {
        let arr: InlineArray<3, Double> = [2, 3, 4]
        func f(_ a: InlineArray<3, Double>) -> Double {
            var a = a
            a[ad: 0] = a[ad: 1] * a[ad: 1]
            return a[ad: 0]
        }
        let (value, pb) = valueWithPullback(at: arr, of: f)
        #expect(value == 9) // a[1]^2
        let g = pb(1)
        // d/d a[1] = 2 * 3 = 6; a[0] is overwritten so its incoming gradient is consumed.
        #expect(g[0] == 0)
        #expect(g[1] == 6)
        #expect(g[2] == 0)
    }
}

#endif
