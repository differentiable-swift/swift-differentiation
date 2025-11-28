import _Differentiation
@testable import Differentiation
import Testing

@Suite
struct ZipDifferentiableTests {
    @Test
    func zipCall() {
        let a: [Double] = [1, 2, 3]
        let b: [Double] = [5, 6, 7]

        let (value, pullback) = valueWithPullback(at: a, b, of: { s1, s2 in
            zip(s1, s2)
        })

        #expect(value.map(\.0) == a)
        #expect(value.map(\.1) == b)

        let va: [Double].DifferentiableView = [1, 0, 0]
        let vb: [Double].DifferentiableView = [0, 0, 0]

        let gradient = pullback(Zip2Sequence.TangentVector(va, vb))
        #expect(gradient == ([1, 0, 0], [0, 0, 0]))
    }

    @Test
    func zipMapAdd() {
        let a: [Double] = [1, 2, 3]
        let b: [Double] = [5, 6, 7]

        let (value, pullback) = valueWithPullback(at: a, b, of: { s1, s2 in
            zip(s1, s2).differentiableMap { $0 + $1 }
        })

        #expect(value == [6, 8, 10])

        let gradient = pullback([1, 0, 0])
        #expect(gradient == ([1, 0, 0], [1, 0, 0]))
    }

    @Test
    func zipMapMultiply() {
        let a: [Double] = [1, 2, 3]
        let b: [Double] = [5, 6, 7]

        let (value, pullback) = valueWithPullback(at: a, b, of: { s1, s2 in
            zip(s1, s2).differentiableMap { $0 * $1 }
        })

        #expect(value == [5, 12, 21])

        let gradient1 = pullback([1, 0, 0])
        #expect(gradient1 == ([5, 0, 0], [1, 0, 0]))

        let gradient2 = pullback([0, 1, 0])
        #expect(gradient2 == ([0, 6, 0], [0, 2, 0]))
    }

    @Test
    func zipMapReduce() {
        let a: [Double] = [1, 2, 3]
        let b: [Double] = [5, 6, 7]

        let (value, pullback) = valueWithPullback(at: a, b, of: { s1, s2 in
            zip(s1, s2).differentiableMap { $0 + $1 }.differentiableReduce(0.0) { $0 + $1 }
        })

        #expect(value == 24.0)

        let gradient = pullback(1.0)
        #expect(gradient == ([1.0, 1.0, 1.0], [1.0, 1.0, 1.0]))
    }

    @Test
    func zipReduceAdd() {
        let a: [Double] = [1, 2, 3]
        let b: [Double] = [5, 6, 7]

        let (value, pullback) = valueWithPullback(at: a, b, of: { s1, s2 in
            zip(s1, s2).differentiableReduce(0.0) { $0 + $1 + $2 }
        })

        #expect(value == 24)

        let gradient = pullback(1.0)
        #expect(gradient == ([1, 1, 1], [1, 1, 1]))
    }

    @Test
    func zipReduceMultiply() {
        let a: [Double] = [1, 2, 3]
        let b: [Double] = [5, 6, 7]

        let (value, pullback) = valueWithPullback(at: a, b, of: { s1, s2 in
            zip(s1, s2).differentiableReduce(1.0) { $0 * $1 * $2 }
        })

        #expect(value == 1260)

        let gradient = pullback(1.0)
        #expect(gradient == ([1260, 630, 420], [252, 210, 180]))
    }
}
