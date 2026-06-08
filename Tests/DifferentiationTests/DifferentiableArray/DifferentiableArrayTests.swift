#if canImport(_Differentiation)

import Differentiation
import Testing

@Suite("DifferentiableArray")
struct DifferentiableArrayTests {

    // MARK: - TangentVector arithmetic

    @Test("zero is additive identity")
    func zeroIsIdentity() {
        let t = DifferentiableArrayTangentVector<Float>(.oneHot(index: 2, value: 5.0, count: 5))
        #expect(t + .zero == t)
        #expect(.zero + t == t)
    }

    @Test("oneHot + oneHot same index stays compact")
    func oneHotPlusOneHotSameIndex() {
        let a = DifferentiableArrayTangentVector<Float>(.oneHot(index: 1, value: 3.0, count: 4))
        let b = DifferentiableArrayTangentVector<Float>(.oneHot(index: 1, value: 7.0, count: 4))
        let result = a + b
        #expect(result == DifferentiableArrayTangentVector<Float>(.oneHot(index: 1, value: 10.0, count: 4)))
    }

    @Test("oneHot + oneHot different indices materializes to full")
    func oneHotPlusOneHotDifferentIndices() {
        let a = DifferentiableArrayTangentVector<Float>(.oneHot(index: 0, value: 3.0, count: 3))
        let b = DifferentiableArrayTangentVector<Float>(.oneHot(index: 2, value: 7.0, count: 3))
        let result = a + b
        #expect(result.asArray(count: 3) == [3.0, 0.0, 7.0])
    }

    @Test("oneHot + full adds into existing entry")
    func oneHotPlusFull() {
        let hot = DifferentiableArrayTangentVector<Float>(.oneHot(index: 1, value: 2.0, count: 3))
        let full = DifferentiableArrayTangentVector<Float>(.full([10.0, 20.0, 30.0]))
        let result = hot + full
        #expect(result.asArray(count: 3) == [10.0, 22.0, 30.0])
    }

    @Test("asArray materializes all cases")
    func asArray() {
        let z = DifferentiableArrayTangentVector<Float>.zero
        #expect(z.asArray(count: 3) == [0.0, 0.0, 0.0])

        let h = DifferentiableArrayTangentVector<Float>(.oneHot(index: 1, value: 5.0, count: 3))
        #expect(h.asArray(count: 3) == [0.0, 5.0, 0.0])

        let f = DifferentiableArrayTangentVector<Float>(.full([1.0, 2.0, 3.0]))
        #expect(f.asArray(count: 3) == [1.0, 2.0, 3.0])
    }

    // MARK: - Subscript gradient

    @Test("subscript pullback returns oneHot")
    func subscriptPullback() {
        let a: DifferentiableArray<Float> = [1, 2, 3, 4, 5]
        let (value, pullback) = valueWithPullback(at: a) { $0[2] }
        #expect(value == 3.0)
        let grad = pullback(1.0)
        #expect(grad == DifferentiableArrayTangentVector<Float>(.oneHot(index: 2, value: 1.0, count: 5)))
    }

    // MARK: - Mean squared error gradient

    @Test("meanSquaredError value")
    func meanSquaredErrorValue() {
        let a: DifferentiableArray<Float> = [1, 2, 3, 4, 5]
        let b: DifferentiableArray<Float> = [5, 4, 3, 2, 1]
        #expect(a.meanSquaredError(to: b) == 40.0)
    }

    @Test("meanSquaredError gradient")
    func meanSquaredErrorGradient() {
        let a: DifferentiableArray<Float> = [1, 2, 3, 4, 5]
        let b: DifferentiableArray<Float> = [5, 4, 3, 2, 1]

        let (value, pullback) = valueWithPullback(at: a) { $0.meanSquaredError(to: b) }
        #expect(value == 40.0)
        let grad = pullback(1.0).asArray(count: a.count)
        #expect(grad == [-8, -4, 0, 4, 8])
    }
}

#endif
