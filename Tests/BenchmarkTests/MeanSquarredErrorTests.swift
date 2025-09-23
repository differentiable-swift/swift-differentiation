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
    func ctaMeanSquaredError() {
        var a: ConstantTimeAccessor<Float> = [1, 2, 3, 4, 5]
        let b: ConstantTimeAccessor<Float> = [5, 4, 3, 2, 1]
        #expect(a.meanSquaredError(to: b) == 40.0)
    }
    
    @Test
    func dctaMeanSquaredError() {
        var a: DCTA<Float> = [1, 2, 3, 4, 5]
        let b: DCTA<Float> = [5, 4, 3, 2, 1]
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
    
    @Test
    func ctaMeanSquaredErrorVWPB() {
        let a: ConstantTimeAccessor<Float> = [1, 2, 3, 4, 5]
        let b: ConstantTimeAccessor<Float> = [5, 4, 3, 2, 1]
        
        let vwpb = valueWithPullback(at: a, of: { a in
            var a = a
            return a.meanSquaredError(to: b)
        })
        #expect(vwpb.value == 40.0)
        #expect(vwpb.pullback(1.0) == [-8, -4, 0, 4, 8])
    }
    
    @Test
    func dctaMeanSquaredErrorVWPB() {
        let a: DCTA<Float> = [1, 2, 3, 4, 5]
        let b: DCTA<Float> = [5, 4, 3, 2, 1]
        
        let vwpb = valueWithPullback(at: a, of: { a in
            var a = a
            return a.meanSquaredError(to: b)
        })
        #expect(vwpb.value == 40.0)
        #expect(vwpb.pullback(1.0) == [-8, -4, 0, 4, 8])
    }
}
