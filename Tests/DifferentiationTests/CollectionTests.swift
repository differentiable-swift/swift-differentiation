import _Differentiation
import Testing

// MARK: - ArraySlice

@Suite("ArraySlice Differentiable")
struct ArraySliceDifferentiableTests {
    @Suite("DifferentiableView")
    struct DifferentiableViewTests {
        @Test("base round-trips through DifferentiableView")
        func baseRoundTrip() {
            let slice: ArraySlice<Float> = [1, 2, 3]
            let view = ArraySlice<Float>.DifferentiableView(slice)
            #expect(view.base.elementsEqual(slice))
        }

        @Test("Element .zero is accessible through DifferentiableView")
        func elementZero() {
            let view = ArraySlice<Float>.DifferentiableView([.zero, .zero, .zero])
            #expect(view.base.allSatisfy { $0 == .zero })
        }

        @Test("DifferentiableView move(by:) applies offset correctly")
        func moveBy() {
            var view = ArraySlice<Float>.DifferentiableView([1, 2, 3])
            let tangent = ArraySlice<Float>.DifferentiableView([0.1, 0.2, 0.3])
            view.move(by: tangent)
            let expected: [Float] = [1.1, 2.2, 3.3]
            for (result, exp) in zip(view.base, expected) {
                #expect(abs(result - exp) < 1E-6)
            }
        }

        @Test("DifferentiableView equality after move")
        func equalityAfterMove() {
            var a = ArraySlice<Float>.DifferentiableView([1, 2, 3])
            var b = ArraySlice<Float>.DifferentiableView([1, 2, 3])
            let tangent = ArraySlice<Float>.DifferentiableView([1, 1, 1])
            a.move(by: tangent)
            b.move(by: tangent)
            #expect(a.base.elementsEqual(b.base))
        }
    }

    @Suite("AdditiveArithmetic")
    struct AdditiveArithmeticTests {
        @Test("adding empty view to non-empty view returns non-empty")
        func addEmptyToNonEmpty() {
            let nonEmpty = ArraySlice<Float>.DifferentiableView([1, 2, 3])
            let empty = ArraySlice<Float>.DifferentiableView([])
            #expect((nonEmpty + empty).base.elementsEqual([1, 2, 3]))
            #expect((empty + nonEmpty).base.elementsEqual([1, 2, 3]))
        }

        @Test("adding view to .zero returns same view")
        func addZero() {
            let view = ArraySlice<Float>.DifferentiableView([1, 2, 3])
            #expect((view + .zero).base.elementsEqual([1, 2, 3]))
            #expect((ArraySlice<Float>.DifferentiableView.zero + view).base.elementsEqual([1, 2, 3]))
        }

        @Test("subtracting view from another")
        func subtractViews() {
            let a = ArraySlice<Float>.DifferentiableView([4, 6, 8])
            let b = ArraySlice<Float>.DifferentiableView([1, 2, 3])
            #expect((a - b).base.elementsEqual([3, 4, 5]))
        }

        @Test("subtracting .zero from view returns same view")
        func subtractZero() {
            let view = ArraySlice<Float>.DifferentiableView([1, 2, 3])
            #expect((view - .zero).base.elementsEqual([1, 2, 3]))
            #expect((ArraySlice<Float>.DifferentiableView.zero - view).base.elementsEqual([-1, -2, -3]))
        }

        @Test("subtracting empty view from non-empty view returns non-empty")
        func subtractEmpty() {
            let nonEmpty = ArraySlice<Float>.DifferentiableView([1, 2, 3])
            let empty = ArraySlice<Float>.DifferentiableView([])
            #expect((nonEmpty - empty).base.elementsEqual([1, 2, 3]))
        }

        @Test("v - v yields same-length all-zero view, not .zero")
        func subtractSelf() {
            let v = ArraySlice<Float>.DifferentiableView([1, -2, 0.5])
            let result = v - v
            #expect(result.base.count == 3)
            #expect(result.base.allSatisfy { $0 == 0 })
            #expect(result != .zero)
        }
    }

    @Suite("Differentiability")
    struct DifferentiabilityTests {
        @Test("gradient of sum over ArraySlice elements")
        func gradientOfSum() {
            func f(_ s: ArraySlice<Float>) -> Float { s.differentiableReduce(0) { $0 + $1 } }
            let (value, pb) = valueWithPullback(at: [1, 2, 3], of: f)
            #expect(value == 6)
            #expect(pb(1).base.allSatisfy { $0 == 1 })
        }

        @Test("gradient of sum of squares over ArraySlice elements")
        func gradientOfSumOfSquares() {
            func f(_ s: ArraySlice<Float>) -> Float {
                var result: Float = 0
                for i in withoutDerivative(at: s.indices) { result += s[i] * s[i] }
                return result
            }
            let (value, pb) = valueWithPullback(at: [1, -2, 3] as ArraySlice<Float>, of: f)
            #expect(value == 14)
            let expected: [Float] = [2, -4, 6]
            for (g, e) in zip(pb(1).base, expected) { #expect(abs(g - e) < 1E-6) }
        }

        @Test("subscript VJP produces a basis-vector tangent")
        func gradientOfSubscript() {
            let i = 1
            func f(_ s: ArraySlice<Float>) -> Float { s[i] }
            let (_, pb) = valueWithPullback(at: [10, 20, 30] as ArraySlice<Float>, of: f)
            let expected: [Float] = [0, 1, 0]
            for (g, e) in zip(pb(1).base, expected) { #expect(abs(g - e) < 1E-6) }
        }

        @Test("gradient of product over ArraySlice elements")
        func gradientOfProduct() {
            func f(_ s: ArraySlice<Float>) -> Float { s.differentiableReduce(1) { $0 * $1 } }
            let (value, pb) = valueWithPullback(at: [2, 3, 4], of: f)
            #expect(value == 24)
            let expected: [Float] = [12, 8, 6]
            for (g, e) in zip(pb(1).base, expected) { #expect(abs(g - e) < 1E-6) }
        }

        @Test("ArraySlice move(by:) shifts values")
        func moveBy() {
            var slice: ArraySlice<Float> = [0, 0, 0]
            slice.move(by: .init([1, 2, 3]))
            #expect(slice.elementsEqual([1, 2, 3]))
        }

        @Test("pullback of sum produces .zero tangent for zero seed")
        func zeroSeedPullback() {
            func f(_ s: ArraySlice<Float>) -> Float { s.differentiableReduce(0) { $0 + $1 } }
            let (_, pb) = valueWithPullback(at: [1, 2, 3] as ArraySlice<Float>, of: f)
            #expect(pb(.zero).base.allSatisfy { $0 == .zero })
        }
    }
}

// MARK: - ContiguousArray

@Suite("ContiguousArray Differentiable")
struct ContiguousArrayDifferentiableTests {
    @Suite("DifferentiableView")
    struct DifferentiableViewTests {
        @Test("base round-trips through DifferentiableView")
        func baseRoundTrip() {
            let ca: ContiguousArray<Float> = [1, 2, 3]
            let view = ContiguousArray<Float>.DifferentiableView(ca)
            #expect(view.base.elementsEqual(ca))
        }

        @Test("Element .zero is accessible through DifferentiableView")
        func elementZero() {
            let view = ContiguousArray<Float>.DifferentiableView([.zero, .zero, .zero])
            #expect(view.base.allSatisfy { $0 == .zero })
        }

        @Test("DifferentiableView move(by:) applies offset correctly")
        func moveBy() {
            var view = ContiguousArray<Float>.DifferentiableView([1, 2, 3])
            let tangent = ContiguousArray<Float>.DifferentiableView([0.1, 0.2, 0.3])
            view.move(by: tangent)
            let expected: [Float] = [1.1, 2.2, 3.3]
            for (result, exp) in zip(view.base, expected) {
                #expect(abs(result - exp) < 1E-6)
            }
        }

        @Test("DifferentiableView equality after move")
        func equalityAfterMove() {
            var a = ContiguousArray<Float>.DifferentiableView([1, 2, 3])
            var b = ContiguousArray<Float>.DifferentiableView([1, 2, 3])
            let tangent = ContiguousArray<Float>.DifferentiableView([1, 1, 1])
            a.move(by: tangent)
            b.move(by: tangent)
            #expect(a.base.elementsEqual(b.base))
        }
    }

    @Suite("AdditiveArithmetic")
    struct AdditiveArithmeticTests {
        @Test("adding empty view to non-empty view returns non-empty")
        func addEmptyToNonEmpty() {
            let nonEmpty = ContiguousArray<Float>.DifferentiableView([1, 2, 3])
            let empty = ContiguousArray<Float>.DifferentiableView([])
            #expect((nonEmpty + empty).base.elementsEqual([1, 2, 3]))
            #expect((empty + nonEmpty).base.elementsEqual([1, 2, 3]))
        }

        @Test("adding view to .zero returns same view")
        func addZero() {
            let view = ContiguousArray<Float>.DifferentiableView([1, 2, 3])
            #expect((view + .zero).base.elementsEqual([1, 2, 3]))
            #expect((ContiguousArray<Float>.DifferentiableView.zero + view).base.elementsEqual([1, 2, 3]))
        }

        @Test("subtracting view from another")
        func subtractViews() {
            let a = ContiguousArray<Float>.DifferentiableView([4, 6, 8])
            let b = ContiguousArray<Float>.DifferentiableView([1, 2, 3])
            #expect((a - b).base.elementsEqual([3, 4, 5]))
        }

        @Test("subtracting .zero from view returns same view")
        func subtractZero() {
            let view = ContiguousArray<Float>.DifferentiableView([1, 2, 3])
            #expect((view - .zero).base.elementsEqual([1, 2, 3]))
            #expect((ContiguousArray<Float>.DifferentiableView.zero - view).base.elementsEqual([-1, -2, -3]))
        }

        @Test("subtracting empty view from non-empty view returns non-empty")
        func subtractEmpty() {
            let nonEmpty = ContiguousArray<Float>.DifferentiableView([1, 2, 3])
            let empty = ContiguousArray<Float>.DifferentiableView([])
            #expect((nonEmpty - empty).base.elementsEqual([1, 2, 3]))
        }
    }

    @Suite("Differentiability")
    struct DifferentiabilityTests {
        @Test("gradient of sum over ContiguousArray elements")
        func gradientOfSum() {
            func f(_ ca: ContiguousArray<Float>) -> Float { ca.differentiableReduce(0) { $0 + $1 } }
            let (value, pb) = valueWithPullback(at: [1, 2, 3], of: f)
            #expect(value == 6)
            #expect(pb(1).base.allSatisfy { $0 == 1 })
        }

        @Test("gradient of sum of squares over ContiguousArray elements")
        func gradientOfSumOfSquares() {
            func f(_ ca: ContiguousArray<Float>) -> Float {
                var result: Float = 0
                for i in withoutDerivative(at: ca.indices) { result += ca[i] * ca[i] }
                return result
            }
            let (value, pb) = valueWithPullback(at: [1, -2, 3] as ContiguousArray<Float>, of: f)
            #expect(value == 14)
            let expected: [Float] = [2, -4, 6]
            for (g, e) in zip(pb(1).base, expected) { #expect(abs(g - e) < 1E-6) }
        }

        @Test("subscript VJP produces a basis-vector tangent")
        func gradientOfSubscript() {
            let i = 1
            func f(_ ca: ContiguousArray<Float>) -> Float { ca[i] }
            let (_, pb) = valueWithPullback(at: [10, 20, 30] as ContiguousArray<Float>, of: f)
            let expected: [Float] = [0, 1, 0]
            for (g, e) in zip(pb(1).base, expected) { #expect(abs(g - e) < 1E-6) }
        }

        @Test("gradient of product over ContiguousArray elements")
        func gradientOfProduct() {
            func f(_ ca: ContiguousArray<Float>) -> Float { ca.differentiableReduce(1) { $0 * $1 } }
            let (value, pb) = valueWithPullback(at: [2, 3, 4], of: f)
            #expect(value == 24)
            let expected: [Float] = [12, 8, 6]
            for (g, e) in zip(pb(1).base, expected) { #expect(abs(g - e) < 1E-6) }
        }

        @Test("ContiguousArray move(by:) shifts values")
        func moveBy() {
            var ca: ContiguousArray<Float> = [0, 0, 0]
            ca.move(by: .init([1, 2, 3]))
            #expect(ca.elementsEqual([1, 2, 3]))
        }

        @Test("init(repeating:count:) VJP reduces element tangents into the scalar")
        func gradientOfInitRepeating() {
            let n = 5
            func f(_ a: Float) -> Float {
                let v = ContiguousArray<Float>(repeating: a, count: n)
                var result: Float = 0
                for i in withoutDerivative(at: v.indices) { result += v[i] }
                return result
            }
            let g = gradient(at: 3, of: f)
            #expect(g == Float(n))
        }

        @Test("init(repeating:count:) with count 0 has zero gradient")
        func gradientOfInitRepeatingZeroCount() {
            func f(_ a: Float) -> Float {
                let v = ContiguousArray<Float>(repeating: a, count: 0)
                var result: Float = 0
                for i in withoutDerivative(at: v.indices) { result += v[i] }
                return result
            }
            let g = gradient(at: 3, of: f)
            #expect(g == 0)
        }

        @Test("pullback of sum produces .zero tangent for zero seed")
        func zeroSeedPullback() {
            func f(_ ca: ContiguousArray<Float>) -> Float { ca.differentiableReduce(0) { $0 + $1 } }
            let (_, pb) = valueWithPullback(at: [1, 2, 3] as ContiguousArray<Float>, of: f)
            #expect(pb(.zero).base.allSatisfy { $0 == .zero })
        }
    }
}

// MARK: - Array

@Suite("Array Differentiable")
struct ArrayDifferentiableTests {
    @Suite("DifferentiableView")
    struct DifferentiableViewTests {
        @Test("base round-trips through DifferentiableView")
        func baseRoundTrip() {
            let arr: [Float] = [1, 2, 3]
            let view = Array<Float>.DifferentiableView(arr)
            #expect(view.base.elementsEqual(arr))
        }

        @Test("Element .zero is accessible through DifferentiableView")
        func elementZero() {
            let view = Array<Float>.DifferentiableView([.zero, .zero, .zero])
            #expect(view.base.allSatisfy { $0 == .zero })
        }

        @Test("DifferentiableView move(by:) applies offset correctly")
        func moveBy() {
            var view = Array<Float>.DifferentiableView([1, 2, 3])
            let tangent = Array<Float>.DifferentiableView([0.1, 0.2, 0.3])
            view.move(by: tangent)
            let expected: [Float] = [1.1, 2.2, 3.3]
            for (result, exp) in zip(view.base, expected) {
                #expect(abs(result - exp) < 1E-6)
            }
        }

        @Test("DifferentiableView equality after move")
        func equalityAfterMove() {
            var a = Array<Float>.DifferentiableView([1, 2, 3])
            var b = Array<Float>.DifferentiableView([1, 2, 3])
            let tangent = Array<Float>.DifferentiableView([1, 1, 1])
            a.move(by: tangent)
            b.move(by: tangent)
            #expect(a.base.elementsEqual(b.base))
        }
    }

    @Suite("AdditiveArithmetic")
    struct AdditiveArithmeticTests {
        @Test("adding empty view to non-empty view returns non-empty")
        func addEmptyToNonEmpty() {
            let nonEmpty = Array<Float>.DifferentiableView([1, 2, 3])
            let empty = Array<Float>.DifferentiableView([])
            #expect((nonEmpty + empty).base.elementsEqual([1, 2, 3]))
            #expect((empty + nonEmpty).base.elementsEqual([1, 2, 3]))
        }

        @Test("adding view to .zero returns same view")
        func addZero() {
            let view = Array<Float>.DifferentiableView([1, 2, 3])
            #expect((view + .zero).base.elementsEqual([1, 2, 3]))
            #expect((Array<Float>.DifferentiableView.zero + view).base.elementsEqual([1, 2, 3]))
        }

        @Test("subtracting view from another")
        func subtractViews() {
            let a = Array<Float>.DifferentiableView([4, 6, 8])
            let b = Array<Float>.DifferentiableView([1, 2, 3])
            #expect((a - b).base.elementsEqual([3, 4, 5]))
        }

        @Test("subtracting .zero from view returns same view")
        func subtractZero() {
            let view = Array<Float>.DifferentiableView([1, 2, 3])
            #expect((view - .zero).base.elementsEqual([1, 2, 3]))

            withKnownIssue("This should be fixed in 6.3") {
                #expect((Array<Float>.DifferentiableView.zero - view).base.elementsEqual([-1, -2, -3]))
            }
        }

        @Test("subtracting empty view from non-empty view returns non-empty")
        func subtractEmpty() {
            let nonEmpty = Array<Float>.DifferentiableView([1, 2, 3])
            let empty = Array<Float>.DifferentiableView([])
            #expect((nonEmpty - empty).base.elementsEqual([1, 2, 3]))
        }
    }

    @Suite("Differentiability")
    struct DifferentiabilityTests {
        @Test("gradient of sum over Array elements")
        func gradientOfSum() {
            func f(_ a: [Float]) -> Float { a.differentiableReduce(0) { $0 + $1 } }
            let (value, pb) = valueWithPullback(at: [1, 2, 3], of: f)
            #expect(value == 6)
            #expect(pb(1).base.allSatisfy { $0 == 1 })
        }

        @Test("gradient of sum of squares over Array elements")
        func gradientOfSumOfSquares() {
            func f(_ a: [Float]) -> Float {
                var result: Float = 0
                for i in withoutDerivative(at: a.indices) { result += a[i] * a[i] }
                return result
            }
            let (value, pb) = valueWithPullback(at: [1, -2, 3] as [Float], of: f)
            #expect(value == 14)
            let expected: [Float] = [2, -4, 6]
            for (g, e) in zip(pb(1).base, expected) { #expect(abs(g - e) < 1E-6) }
        }

        @Test("subscript VJP produces a basis-vector tangent")
        func gradientOfSubscript() {
            let i = 1
            func f(_ a: [Float]) -> Float { a[i] }
            let (_, pb) = valueWithPullback(at: [10, 20, 30] as [Float], of: f)
            let expected: [Float] = [0, 1, 0]
            for (g, e) in zip(pb(1).base, expected) { #expect(abs(g - e) < 1E-6) }
        }

        @Test("gradient of product over Array elements")
        func gradientOfProduct() {
            func f(_ a: [Float]) -> Float { a.differentiableReduce(1) { $0 * $1 } }
            let (value, pb) = valueWithPullback(at: [2, 3, 4], of: f)
            #expect(value == 24)
            let expected: [Float] = [12, 8, 6]
            for (g, e) in zip(pb(1).base, expected) { #expect(abs(g - e) < 1E-6) }
        }

        @Test("Array move(by:) shifts values")
        func moveBy() {
            var arr: [Float] = [0, 0, 0]
            arr.move(by: .init([1, 2, 3]))
            #expect(arr.elementsEqual([1, 2, 3]))
        }

        @Test("pullback of sum produces .zero tangent for zero seed")
        func zeroSeedPullback() {
            func f(_ a: [Float]) -> Float { a.differentiableReduce(0) { $0 + $1 } }
            let (_, pb) = valueWithPullback(at: [1, 2, 3], of: f)
            #expect(pb(.zero).base.allSatisfy { $0 == .zero })
        }
    }
}

// MARK: - Cross-type consistency

@Suite("Cross-type consistency")
struct CrossTypeConsistencyTests {
    @Test("Array, ArraySlice and ContiguousArray produce same gradients for sum")
    func sameSumGradient() {
        func sumArr(_ a: [Float]) -> Float { a.differentiableReduce(0) { $0 + $1 } }
        func sumSlice(_ s: ArraySlice<Float>) -> Float { s.differentiableReduce(0) { $0 + $1 } }
        func sumCA(_ ca: ContiguousArray<Float>) -> Float { ca.differentiableReduce(0) { $0 + $1 } }

        let input: [Float] = [1, 2, 3]
        let gradArr = valueWithPullback(at: Array(input), of: sumArr).1(1).base
        let gradSlice = valueWithPullback(at: ArraySlice(input), of: sumSlice).1(1).base
        let gradCA = valueWithPullback(at: ContiguousArray(input), of: sumCA).1(1).base
        #expect(gradArr.elementsEqual(gradSlice))
        #expect(gradArr.elementsEqual(gradCA))
    }

    @Test("Array, ArraySlice and ContiguousArray produce same gradients for product")
    func sameProductGradient() {
        func productArr(_ a: [Float]) -> Float { a.differentiableReduce(1) { $0 * $1 } }
        func productSlice(_ s: ArraySlice<Float>) -> Float { s.differentiableReduce(1) { $0 * $1 } }
        func productCA(_ ca: ContiguousArray<Float>) -> Float { ca.differentiableReduce(1) { $0 * $1 } }

        let input: [Float] = [2, 3, 4]
        let gradArr = valueWithPullback(at: Array(input), of: productArr).1(1).base
        let gradSlice = valueWithPullback(at: ArraySlice(input), of: productSlice).1(1).base
        let gradCA = valueWithPullback(at: ContiguousArray(input), of: productCA).1(1).base
        #expect(gradArr.elementsEqual(gradSlice))
        #expect(gradArr.elementsEqual(gradCA))
    }
}
