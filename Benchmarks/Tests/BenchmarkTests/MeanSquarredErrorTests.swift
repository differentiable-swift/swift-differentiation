@testable import Benchmarks
import Differentiation
import Testing

@Suite
struct MeanSquarredErrorTests {
    @Test
    func arrayMeanSquaredError() {
        let a: Array<Float> = [1, 2, 3, 4, 5]
        let b: Array<Float> = [5, 4, 3, 2, 1]
        #expect(a.meanSquaredError(to: b) == 40.0)
    }

    @Test
    func arrayMeanSquaredErrorVWPB() {
        let a: Array<Float> = [1, 2, 3, 4, 5]
        let b: Array<Float> = [5, 4, 3, 2, 1]

        let vwpb = valueWithPullback(at: a, of: { a in
            a.meanSquaredError(to: b)
        })
        #expect(vwpb.value == 40.0)
        #expect(vwpb.pullback(1.0) == [-8, -4, 0, 4, 8])
    }
}
