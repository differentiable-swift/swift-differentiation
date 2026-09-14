import Differentiation
import Testing
import ZipWithVariants

/// fusedZip must match differentiableZipWith exactly: same values, and same pullback results
/// for all-ones, one-hot, and empty tangent seeds.
@Suite
struct FusedZipTests {
    @Test
    func arity2MatchesZipWith() {
        let cases: [(lhs: [Float], rhs: [Float])] = [
            ([], []),
            ([2], [3]),
            (makeInput(5), makeInput(5, seed: 2)),
            (makeInput(5), makeInput(3, seed: 2)),
            (makeInput(3), makeInput(5, seed: 2)),
        ]

        for (lhs, rhs) in cases {
            let expected = valueWithPullback(at: lhs, rhs, of: zipWith2_canonical)
            let actual = valueWithPullback(at: lhs, rhs, of: zipWith2_fused)
            let n = expected.value.count

            #expect(actual.value == expected.value, "value, n=\(n)")

            var seeds: [[Float]] = [[Float](repeating: 1, count: n), []]
            if n > 0 {
                var oneHot = [Float](repeating: 0, count: n)
                oneHot[0] = 1
                seeds.append(oneHot)
            }

            for seed in seeds {
                let seedVector = [Float].DifferentiableView(seed)
                let expectedTangents = expected.pullback(seedVector)
                let actualTangents = actual.pullback(seedVector)
                #expect(actualTangents.0.base == expectedTangents.0.base, "lhs tangent, n=\(n), seed count \(seed.count)")
                #expect(actualTangents.1.base == expectedTangents.1.base, "rhs tangent, n=\(n), seed count \(seed.count)")
            }
        }
    }

    @Test
    func arity8MatchesZipWith() {
        for n in [0, 1, 5] {
            let inputs = Inputs8(n: n)
            let expected = valueWithPullback(at: inputs, of: zipWith8_canonical)
            let actual = valueWithPullback(at: inputs, of: zipWith8_fused)

            #expect(actual.value == expected.value, "value, n=\(n)")

            var seeds: [[Float]] = [[Float](repeating: 1, count: n), []]
            if n > 0 {
                var oneHot = [Float](repeating: 0, count: n)
                oneHot[0] = 1
                seeds.append(oneHot)
            }

            for seed in seeds {
                let seedVector = [Float].DifferentiableView(seed)
                #expect(actual.pullback(seedVector) == expected.pullback(seedVector), "tangent, n=\(n), seed count \(seed.count)")
            }
        }
    }
}
