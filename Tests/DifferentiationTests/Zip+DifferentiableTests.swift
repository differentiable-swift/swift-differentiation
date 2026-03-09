@testable import Differentiation
import Testing

#if canImport(_Differentiation)

@Suite
struct ZipDifferentiableTests {
    @Test
    func zipCall() {
        let a: [Double] = [1, 2, 3]
        let b: [Double] = [5, 6, 7]

        let (value, pullback) = valueWithPullback(at: a, b, of: { s1, s2 in
            differentiableZip(s1, s2)
        })

        #expect(value.map(\.0) == a)
        #expect(value.map(\.1) == b)

        let va: [Double].DifferentiableView = [1, 0, 0]
        let vb: [Double].DifferentiableView = [0, 0, 0]

        let gradient = pullback(Zip2SequenceDifferentiable.TangentVector(va, vb))
        #expect(gradient == ([1, 0, 0], [0, 0, 0]))
    }

    @Test
    func zipMapAdd() {
        let a: [Double] = [1, 2, 3]
        let b: [Double] = [5, 6, 7]

        let (value, pullback) = valueWithPullback(at: a, b, of: { s1, s2 in
            differentiableZip(s1, s2).differentiableMap { $0 + $1 }
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
            differentiableZip(s1, s2).differentiableMap { $0 * $1 }
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

        let expectedValue = 24.0
        let expectedGradient: ([Double].TangentVector, [Double].TangentVector) = ([1.0, 1.0, 1.0], [1.0, 1.0, 1.0])

        let (zipValue, zipPullback) = valueWithPullback(at: a, b, of: { s1, s2 in
            differentiableZip(s1, s2).differentiableMap { $0 + $1 }.differentiableReduce(0.0) { $0 + $1 }
        })

        #expect(zipValue == expectedValue)

        let gradient = zipPullback(1.0)
        #expect(gradient.0 == expectedGradient.0)

        let (value1, pullback1) = valueWithPullback(at: a, b, of: { s1, s2 in
            var result = 0.0
            for i in 0 ..< withoutDerivative(at: s1.count) {
                result += s1[i] + s2[i]
            }

            return result
        })

        #expect(value1 == expectedValue)

        let gradient1 = pullback1(1.0)
        #expect(gradient1 == expectedGradient)
    }

    @Test
    func arity3Zip() {
        let a: [Double] = [1, 2, 3]
        let b: [Double] = [4, 5, 6]
        let c: [Double] = [7, 8, 9]

        let expectedValue = 45.0
        let expectedGradient: ([Double].TangentVector, [Double].TangentVector, [Double].TangentVector) = (
            [1.0, 1.0, 1.0],
            [1.0, 1.0, 1.0],
            [1.0, 1.0, 1.0]
        )

        let (zipValue, zipPullback) = valueWithPullback(at: a, b, c, of: { (s1: [Double], s2: [Double], s3: [Double]) in
            differentiableZip(s1, s2, s3).differentiableMap { $0 + $1 + $2 }.differentiableReduce(0.0) { $0 + $1 }
        })

        #expect(zipValue == expectedValue)

        let gradient = zipPullback(1.0)
        #expect(gradient.0 == expectedGradient.0)

        let (value1, pullback1) = valueWithPullback(at: a, b, c, of: { s1, s2, s3 in
            var result = 0.0
            for i in 0 ..< withoutDerivative(at: s1.count) {
                result += s1[i] + s2[i] + s3[i]
            }

            return result
        })

        #expect(value1 == expectedValue)

        let gradient1 = pullback1(1.0)
        #expect(gradient1 == expectedGradient)
    }

    @Test
    func arity5() {
        let a: [Double] = [1, 2, 3]
        let b: [Double] = [4, 5, 6]
        let c: [Double] = [7, 8, 9]
        let d: [Double] = [10, 11, 12]
        let e: [Double] = [13, 14, 15]

        let result = differentiableZip(a, b, c, d, e).differentiableMap { $0 + $1 + $2 + $3 + $4 }
        #expect(result == [35, 40, 45])
    }

    @Test
    func arity5With() {
        let a: [Double] = [1, 2, 3]
        let b: [Double] = [4, 5, 6]
        let c: [Double] = [7, 8, 9]
        let d: [Double] = [10, 11, 12]
        let e: [Double] = [13, 14, 15]

        let result = differentiableZipWith(a, b, c, d, e) { $0 + $1 + $2 + $3 + $4 }
        #expect(result == [35, 40, 45])
    }

    @Test
    func arity5WithInout() {
        var a: [Double] = [1, 2, 3]
        let b: [Double] = [4, 5, 6]
        let c: [Double] = [7, 8, 9]
        let d: [Double] = [10, 11, 12]
        let e: [Double] = [13, 14, 15]

        differentiableZipWith(&a, b, c, d, e) { $0 + $1 + $2 + $3 + $4 }
        #expect(a == [35, 40, 45])
    }

    @Test
    func arity3() {
        let a: [Double] = [1, 2, 3]
        let b: [Double] = [4, 5, 6]
        let c: [Double] = [7, 8, 9]

        @differentiable(reverse)
        func thing(a: [Double], b: [Double], c: [Double]) -> [Double] {
            differentiableZip(a, b, c).differentiableMap { $0 * $1 * $2 }
        }

        let (value, pullback) = valueWithPullback(at: a, b, c) { a, b, c in
            thing(a: a, b: b, c: c)
        }

        #expect(value == [28, 80, 162])
        let gradient = pullback([0, 1, 0])
        #expect(gradient.0.base == [0, 40, 0])
        #expect(gradient.1.base == [0, 16, 0])
        #expect(gradient.2.base == [0, 10, 0])
    }

    @Test
    func arity3With() {
        let a: [Double] = [1, 2, 3]
        let b: [Double] = [4, 5, 6]
        let c: [Double] = [7, 8, 9]

        @differentiable(reverse)
        func thing(a: [Double], b: [Double], c: [Double]) -> [Double] {
            differentiableZipWith(a, b, c) { $0 * $1 * $2 }
        }

        let (value, pullback) = valueWithPullback(at: a, b, c) { a, b, c in
            thing(a: a, b: b, c: c)
        }

        #expect(value == [28, 80, 162])
        let gradient = pullback([0, 1, 0])
        #expect(gradient.0.base == [0, 40, 0])
        #expect(gradient.1.base == [0, 16, 0])
        #expect(gradient.2.base == [0, 10, 0])
    }

    @Test
    func arity3WithInout() {
        let a: [Double] = [1, 2, 3]
        let b: [Double] = [4, 5, 6]
        let c: [Double] = [7, 8, 9]

        @differentiable(reverse)
        func thing(a: inout [Double], b: [Double], c: [Double]) {
            differentiableZipWith(&a, b, c) { $0 * $1 * $2 }
        }

        let (value, pullback) = valueWithPullback(at: a, b, c) { a, b, c in
            var a = a
            thing(a: &a, b: b, c: c)
            return a
        }

        #expect(value == [28, 80, 162])
        let gradient = pullback([0, 1, 0])
        #expect(gradient.0.base == [0, 40, 0])
        #expect(gradient.1.base == [0, 16, 0])
        #expect(gradient.2.base == [0, 10, 0])
    }

    @Test
    func zipContiguousArrayCall() {
        let a: ContiguousArray<Double> = [1, 2, 3]
        let b: [Double] = [5, 6, 7]

        let (value, pullback) = valueWithPullback(at: a, b, of: { s1, s2 in
            differentiableZip(s1, s2)
        })

        #expect(value.map(\.0) == Array(a))
        #expect(value.map(\.1) == b)

        let va: ContiguousArray<Double>.DifferentiableView = [1, 0, 0]
        let vb: [Double].DifferentiableView = [0, 0, 0]

        let gradient = pullback(Zip2SequenceDifferentiable.TangentVector(va, vb))
        #expect(gradient == ([1, 0, 0], [0, 0, 0]))
    }

    @Test
    func zipArraySliceCall() {
        let aArray: [Double] = [1, 2, 3, 4, 5]
        let a = aArray[1 ..< 4]
        let b: [Double] = [5, 6, 7]

        let (value, pullback) = valueWithPullback(at: a, b, of: { s1, s2 in
            differentiableZip(s1, s2)
        })

        #expect(value.map(\.0) == Array(a))
        #expect(value.map(\.1) == b)

        let va: ArraySlice<Double>.DifferentiableView = [1, 0, 0]
        let vb: [Double].DifferentiableView = [0, 0, 0]

        let gradient = pullback(Zip2SequenceDifferentiable.TangentVector(va, vb))
        #expect(gradient == ([1, 0, 0], [0, 0, 0]))
    }

    // MARK: Currently not supported due to language limitations (requires Tuples to be able to conform to `AdditiveArithmetic`)

//    @Test
//    func nestedZip() {
//        let a: [Double] = [1, 2, 3]
//        let b: [Double] = [5, 6, 7]
//        let c: [Double] = [9, 8, 7]
//
//        let (value, pullback) = valueWithPullback(at: a, b, c, of: { s1, s2, s3 in
//            differentiableZip(
//                s1,
//                differentiableZip(
//                    s2,
//                    s3
//                )
//            ).differentiableMap { pair in pair.a + pair.b.a + pair.b.b }
//        })
//    }
}

#endif
