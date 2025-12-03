import _Differentiation
@testable import Differentiation
import Testing

@Suite
struct RepeatedDifferentiableTests {
    @Test
    func repeatedZip() {
        let a: [Double] = [1, 2, 3]
        let b: Repeated<Double> = repeatElement(2.0, count: 3)

        let (value, pullback) = valueWithPullback(at: a, b, of: { s1, s2 in
            differentiableZip(s1, s2)
        })
        
        let thing = value.map(\.1)
        

        #expect(value.map(\.0) == a)
        #expect(thing == b.map { $0 })

        let va: [Double].DifferentiableView = [1, 0, 0]
        let vb: Repeated<Double>.DifferentiableView = .init(base: repeatElement(1.0, count: 3))
                
        let gradient = pullback(Zip2SequenceDifferentiable<[Double], Repeated<Double>>.TangentVector.init(va, vb))
        print(gradient)
        #expect(gradient.0 == [1, 0, 0])
        #expect(gradient.1.base.repeatedValue == 1.0) // not sure if correct yet
        #expect(gradient.1.count == 3)
    }
    
    @Test
    func repeatedZipMap() {
        let a: [Double] = [1, 2, 3]
        let b: Repeated<Double> = repeatElement(2.0, count: 3)
        
        let (value, pullback) = valueWithPullback(at: a, b, of: { s1, s2 in
            differentiableZip(s1, s2).differentiableMap { e1, e2 in e1 * e2 }
        })
        
        #expect(value == [2.0, 4.0, 6.0])
        let gradient1 = pullback([1.0, 0.0, 0.0])
        #expect(gradient1.0 == [2.0, 0.0, 0.0])
        #expect(gradient1.1.base.repeatedValue == 1.0)
        #expect(gradient1.1.count == 3)
        
        let gradient2 = pullback([0.0, 1.0, 0.0])
        #expect(gradient2.0 == [0.0, 2.0, 0.0])
        #expect(gradient2.1.base.repeatedValue == 2.0)
        #expect(gradient2.1.count == 3)
    }
}
