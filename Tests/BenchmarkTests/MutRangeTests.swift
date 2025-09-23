@testable import Benchmarks
import Differentiation
import Foundation
import Testing

@Suite
struct MutRangeTests {
    @Test
    func arrayMutRange() {
        var a: Array<Float> = [1, 2, 3, 4, 5]
        a.mutRange(start: 0, end: 3, { $0 + 1 })
        #expect(a == [2, 3, 4, 4, 5])
    }
    
    @Test
    func ctaMutRange() {
        var a: ConstantTimeAccessor<Float> = [1, 2, 3, 4, 5]
        a.mutRange(start: 0, end: 3, { $0 + 1 })
        #expect(a == ConstantTimeAccessor([2, 3, 4, 4, 5], accessed: 3))
    }
    
    @Test
    func dctaMutRange() {
        var a: DCTA<Float> = [1, 2, 3, 4, 5]
        a.mutRange(start: 0, end: 3, { $0 + 1 })
        #expect(a == [2, 3, 4, 4, 5])
    }
    
    @Test
    func arrayMutRangeVWPB() {
        let a: Array<Float> = [1, 2, 3, 4, 5]
        
        let vwpb = valueWithPullback(at: a, of: { a in
            var a = a
            a.mutRange(start: 0, end: 3, { $0 * $0 })
            return a
        })
        #expect(vwpb.value == [1, 4, 9, 4, 5])
        #expect(vwpb.pullback([1, 0, 0, 0, 0]) == [2, 0, 0, 0, 0])
        #expect(vwpb.pullback([0, 0, 0, 0, 1]) == [0, 0, 0, 0, 1])
    }
    
    @Test
    func ctaMutRangeVWPB() {
        let a: ConstantTimeAccessor<Float> = [1, 2, 3, 4, 5]
        
        let vwpb = valueWithPullback(at: a, of: { a in
            var a = a
            a.mutRange(start: 0, end: 3, { $0 * $0 })
            return a
        })
        #expect(vwpb.value == ConstantTimeAccessor([1, 4, 9, 4, 5], accessed: 3))
        #expect(vwpb.pullback([1, 0, 0, 0, 0]) == [2, 0, 0, 0, 0])
        #expect(vwpb.pullback([0, 0, 0, 0, 1]) == [0, 0, 0, 0, 1])
    }
    
    @Test
    func dctaMutRangeVWPB() {
        let a: DCTA<Float> = [1, 2, 3, 4, 5]
        
        let vwpb = valueWithPullback(at: a, of: { a in
            var a = a
            a.mutRange(start: 0, end: 3, { $0 * $0 })
            return a
        })
        #expect(vwpb.value == [1, 4, 9, 4, 5])
        #expect(vwpb.pullback([1, 0, 0, 0, 0]) == [2, 0, 0, 0, 0])
        #expect(vwpb.pullback([0, 0, 0, 0, 1]) == [0, 0, 0, 0, 1])
    }
}
