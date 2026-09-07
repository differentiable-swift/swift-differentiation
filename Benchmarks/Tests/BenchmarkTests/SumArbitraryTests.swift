@testable import Benchmarks
import Differentiation
import Foundation
import Testing

@Suite
struct SumArbitraryTests {
    @Test
    func arraySumArbitrary() {
        let a: [Float] = [1, 2, 3, 4, 5]
        let result = a.sumArbitrary(indices: [0, 2, 4])
        #expect(result == 9) // 1 + 3 + 5
    }

    @Test
    func arraySumArbitraryVWPB() {
        let a: [Float] = [1, 2, 3, 4, 5]

        let vwpb = valueWithPullback(at: a, of: { $0.sumArbitrary(indices: [0, 2, 4]) })
        #expect(vwpb.value == 9) // 1 + 3 + 5

        // Gradient should be 1 at indices 0, 2, 4 and 0 elsewhere
        #expect(vwpb.pullback(1.0) == [1, 0, 1, 0, 1])

        // Scaled gradient
        #expect(vwpb.pullback(2.0) == [2, 0, 2, 0, 2])
    }

    @Test
    func arraySumArbitraryRepeatedIndices() {
        let a: [Float] = [1, 2, 3, 4, 5]

        // Index 1 appears twice
        let vwpb = valueWithPullback(at: a, of: { $0.sumArbitrary(indices: [1, 1, 3]) })
        #expect(vwpb.value == 8) // 2 + 2 + 4

        // Gradient at index 1 should be 2 (appears twice)
        #expect(vwpb.pullback(1.0) == [0, 2, 0, 1, 0])
    }

    @Test
    func arraySumArbitraryEmptyIndices() {
        let a: [Float] = [1, 2, 3, 4, 5]

        let vwpb = valueWithPullback(at: a, of: { $0.sumArbitrary(indices: []) })
        #expect(vwpb.value == 0)
        #expect(vwpb.pullback(1.0) == [0, 0, 0, 0, 0])
    }

    @Test
    func arraySumArbitraryAllIndices() {
        let a: [Float] = [1, 2, 3, 4, 5]

        let vwpb = valueWithPullback(at: a, of: { $0.sumArbitrary(indices: [0, 1, 2, 3, 4]) })
        #expect(vwpb.value == 15) // sum of all
        #expect(vwpb.pullback(1.0) == [1, 1, 1, 1, 1])
    }
}
