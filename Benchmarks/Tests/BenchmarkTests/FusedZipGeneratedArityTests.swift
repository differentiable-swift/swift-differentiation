
import Differentiation
import Testing
import ZipWithVariants

/// Generated fusedZip arities must match differentiableZipWith exactly.
@Suite
struct FusedZipGeneratedArityTests {
    func check<T: Differentiable>(
        _ inputs: T, _ fused: @differentiable(reverse) (T) -> [Float],
        _ canonical: @differentiable(reverse) (T) -> [Float], n: Int
    ) where T.TangentVector: Equatable {
        let expected = valueWithPullback(at: inputs, of: canonical)
        let actual = valueWithPullback(at: inputs, of: fused)
        #expect(actual.value == expected.value)
        var seeds: [[Float]] = [[Float](repeating: 1, count: n), []]
        if n > 0 {
            var oneHot = [Float](repeating: 0, count: n)
            oneHot[0] = 1
            seeds.append(oneHot)
        }
        for seed in seeds {
            let sv = [Float].DifferentiableView(seed)
            #expect(actual.pullback(sv) == expected.pullback(sv), "seed count \(seed.count)")
        }
    }

    @Test func arity3() { for n in [0, 1, 5] { check(Inputs3(n: n), zipWith3_fused, zipWith3_canonical, n: n) } }
    @Test func arity4() { for n in [0, 1, 5] { check(Inputs4(n: n), zipWith4_fused, zipWith4_canonical, n: n) } }
    @Test func arity10() { for n in [0, 1, 5] { check(Inputs10(n: n), zipWith10_fused, zipWith10_canonical, n: n) } }
    @Test func arity12() { for n in [0, 1, 5] { check(Inputs12(n: n), zipWith12_fused, zipWith12_canonical, n: n) } }

    @Test func arity14() { for n in [0, 1, 5] { check(Inputs14(n: n), zipWith14_fused, zipWith14_canonical, n: n) } }
}
