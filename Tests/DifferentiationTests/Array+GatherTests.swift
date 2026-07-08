import Differentiation
import Testing

struct ArrayGatherTests {
    @Test func gather() {
        let array: [Float] = [1.0, 2.0, 3.0, 4.0]

        // Forward: reads self[indices[i]] for every i.
        #expect(array.gather(at: [2, 0, 2]) == [3.0, 1.0, 3.0])
        #expect(array.gather(at: []) == [])
    }

    @Test func vjpGather() {
        let array: [Float] = [1.0, 2.0, 3.0, 4.0]

        // Test differentiation directly through the VJP.
        let (value, pullback) = array._vjpGather(at: [2, 0, 2])
        #expect(value == [3.0, 1.0, 3.0])

        // Output tangent scatters back into the source's tangent. Index 2 appears
        // twice, so its incoming tangents accumulate.
        let outTangent: [Float].TangentVector = [10.0, 20.0, 30.0]
        let dBase = pullback(outTangent)
        #expect(dBase.count == 4)
        #expect(dBase == [20.0, 0.0, 40.0, 0.0])
    }

    @Test func differentiableGather() {
        @differentiable(reverse)
        func sumGathered(_ array: [Float]) -> Float {
            let gathered = array.gather(at: [2, 0, 2])
            return gathered[0] + gathered[1] + gathered[2]
        }

        let testArray: [Float] = [1.0, 2.0, 3.0, 4.0]

        let vwpb = valueWithPullback(at: testArray, of: sumGathered)
        #expect(vwpb.value == 7.0)

        // d/darray of (array[2] + array[0] + array[2]) => index 0: 1, index 2: 2.
        let gradient = vwpb.pullback(1.0)
        #expect(gradient == [1.0, 0.0, 2.0, 0.0])
    }
}
