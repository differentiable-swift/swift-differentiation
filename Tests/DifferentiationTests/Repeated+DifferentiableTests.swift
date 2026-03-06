@testable import Differentiation
import Testing

#if canImport(_Differentiation)

@Suite
struct RepeatedDifferentiableTests {
    @Test
    func repeatedReduce() {
        let a = repeatElement(1.0, count: 10)
        let b = repeatElement(2.0, count: 10)
        let (value, pullback) = valueWithPullback(at: a, b, of: { a, b in
            differentiableZip(a, b).differentiableMap { $0 + $1 }.differentiableReduce(0.0, { result, v in result + v })
        })

        #expect(value == 30.0)
        let gradient = pullback(1.0)
        #expect(gradient.0 == Repeated<Double>.TangentVector(base: repeatElement(10.0, count: 10)))
        #expect(gradient.1 == Repeated<Double>.TangentVector(base: repeatElement(10.0, count: 10)))
    }

    @Test
    func repeatedZip() {
        let a: [Double] = [1, 2, 3]
        let b: Repeated<Double> = repeatElement(2.0, count: 3)

        let (value, pullback) = valueWithPullback(at: a, b, of: { s1, s2 in
            differentiableZip(s1, s2)
        })

        let thing = value.map(\.1)

        #expect(value.map(\.0) == a)
        #expect(thing == b.map(\.self))

        let va: [Double].DifferentiableView = [1, 0, 0]
        let vb: Repeated<Double>.DifferentiableView = .init(base: repeatElement(2.0, count: 3))

        let gradient = pullback(Zip2SequenceDifferentiable<[Double], Repeated<Double>>.TangentVector(va, vb))
        print(gradient)
        #expect(gradient.0 == [1, 0, 0])
        #expect(gradient.1.base.repeatedValue == 2.0)
        #expect(gradient.1.count == 3)
    }

    @Test
    func repeatedZipMap() {
        let a: [Double] = [1, 2, 3]
        let b: Repeated<Double> = repeatElement(2.0, count: 3)

        let expectedValue = [2.0, 4.0, 6.0]

        let (value0, pullback0) = valueWithPullback(at: a, b, of: { s1, s2 in
            differentiableZip(s1, s2).differentiableMap { e1, e2 in e1 * e2 }
        })

        #expect(value0 == expectedValue)
        let gradient01 = pullback0([1.0, 0.0, 0.0])
        #expect(gradient01.0 == [2.0, 0.0, 0.0])
        #expect(gradient01.1.base.repeatedValue == 1.0)
        #expect(gradient01.1.count == 3)

        let gradient02 = pullback0([0.0, 1.0, 0.0])
        #expect(gradient02.0 == [0.0, 2.0, 0.0])
        #expect(gradient02.1.base.repeatedValue == 2.0)
        #expect(gradient02.1.count == 3)

        let (value1, pullback1) = valueWithPullback(at: a, b, of: { s1, s2 in
            var results: [Double] = []
            for i in 0 ..< withoutDerivative(at: s1.count) {
                let value = s1[i] * s2[i]
                results.append(value)
            }
            return results
        })

        #expect(value1 == expectedValue)
        let gradient11 = pullback1([1.0, 0.0, 0.0])
        #expect(gradient11.0 == [2.0, 0.0, 0.0])
        #expect(gradient11.1.base.repeatedValue == 1.0)
        #expect(gradient11.1.count == 3)

        let gradient12 = pullback1([0.0, 1.0, 0.0])
        #expect(gradient12.0 == [0.0, 2.0, 0.0])
        #expect(gradient12.1.base.repeatedValue == 2.0)
        #expect(gradient12.1.count == 3)
    }

    @Test
    func captureScalarArgument() {
        @differentiable(reverse)
        func f(a: Double, b: [Double]) -> [Double] {
            let count = withoutDerivative(at: b.count)
            let repeatedA = repeatElement(a, count: count)

            return differentiableZip(repeatedA, b).differentiableMap(*)
        }

        let a = 2.0
        let b: [Double] = [1, 2, 3]

        let expected: [Double] = [2, 4, 6]

        let (value, pullback) = valueWithPullback(at: a, b, of: f)
        #expect(value == expected)
        let gradient = pullback([0.0, 1.0, 0.0])
        #expect(gradient.0 == 2.0)
        #expect(gradient.1 == [0.0, 2.0, 0.0])
    }

    @Test
    func movingRepeatedTangentByZeroTangent() {
        var someTangent = Repeated<Double>.TangentVector(base: repeatElement(2.0, count: 5))
        let zeroTangent: Repeated<Double>.TangentVector = .zero

        someTangent.move(by: zeroTangent)

        #expect(someTangent == .init(base: repeatElement(2.0, count: 5)))
    }

    @Test
    func movingRepeatedByZeroTangent() {
        var someValue: Repeated<Double> = repeatElement(2.0, count: 5)
        let zeroTangent: Repeated<Double>.TangentVector = .zero

        someValue.move(by: zeroTangent)

        #expect(someValue.repeatedValue == 2.0)
        #expect(someValue.count == 5)
    }
}

#endif
