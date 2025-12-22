import Testing

#if canImport(_Differentiation)
import _Differentiation
#endif

import Differentiation

#if canImport(_Differentiation)

// MARK: - Small helpers

private func asArray(_ x: ContiguousArray<Double>) -> [Double] { Array(x) }
private func asArray(_ x: ContiguousArray<Double>.TangentVector) -> [Double] { Array(x) }

private func expectAllClose(_ actual: [Double], _ expected: [Double], accuracy: Double = 1E-12) {
    #expect(actual.count == expected.count, "Count mismatch: actual=\(actual.count), expected=\(expected.count)")
    for i in 0 ..< min(actual.count, expected.count) {
        #expect(
            abs(actual[i] - expected[i]) <= accuracy,
            "Mismatch at index: \(i), actual: \(actual[i]), expected: \(expected[i])"
        )
    }
}

/// Asserts a tangent vector is “zero-like” by verifying it does not change `base` when applied via `move(by:)`.
private func expectActsLikeZeroTangent(
    base: ContiguousArray<Double>,
    tangent: ContiguousArray<Double>.TangentVector
) {
    var copy = base
    copy.move(by: tangent)
    #expect(copy == base, "Expected tangent to have no effect when applied via move(by:)")
}

// MARK: - A nontrivial Differentiable element (fixes the Box.value error)

private struct Box: Differentiable, Equatable {
    var value: Double

    // IMPORTANT: Must have stored property `value` so that access to `Box.value` is differentiable.
    struct TangentVector: Differentiable, AdditiveArithmetic, Equatable {
        var value: Double

        static var zero: Self { .init(value: 0) }
        static func + (lhs: Self, rhs: Self) -> Self { .init(value: lhs.value + rhs.value) }
        static func - (lhs: Self, rhs: Self) -> Self { .init(value: lhs.value - rhs.value) }

        mutating func move(by offset: Self) {
            value += offset.value
        }
    }

    mutating func move(by offset: TangentVector) {
        value += offset.value
    }
}

// MARK: - Suites

@Suite("ContiguousArray: Differentiable (gradients + move(by:))")
struct ContiguousArrayDifferentiableTests {
    @Test("gradient of sum of squares is elementwise 2*x")
    func gradient_sumOfSquares_is2x() {
        let f: @differentiable(reverse) (ContiguousArray<Double>) -> Double = { x in
            var s: Double = 0
            for i in withoutDerivative(at: x.indices) { s += x[i] * x[i] }
            return s
        }

        let x: ContiguousArray<Double> = [1.0, -2.0, 3.5]
        let g = gradient(at: x, of: f)

        expectAllClose(asArray(g), [2.0, -4.0, 7.0])
    }

    @Test("subscript VJP produces a basis-vector tangent")
    func gradient_subscript_isBasisVector() {
        let i = 1
        let f: @differentiable(reverse) (ContiguousArray<Double>) -> Double = { x in
            x[i]
        }

        let x: ContiguousArray<Double> = [10.0, 20.0, 30.0]
        let g = gradient(at: x, of: f)

        // Should be [0, 1, 0] with same length as x.
        expectAllClose(asArray(g), [0.0, 1.0, 0.0])
    }

    @Test("init(repeating:count:) VJP reduces element tangents back into the repeated value")
    func gradient_initRepeatingCount_isCount() {
        let n = 5
        let f: @differentiable(reverse) (Double) -> Double = { a in
            let v = ContiguousArray<Double>(repeating: a, count: n)
            var s: Double = 0
            for i in withoutDerivative(at: v.indices) { s += v[i] }
            return s
        }

        let g = gradient(at: 3.0, of: f)
        #expect(g == Double(n))
    }

    @Test("init(repeating:count:) with count 0 has zero gradient")
    func gradient_initRepeatingCountZero_isZero() {
        let n = 0
        let f: @differentiable(reverse) (Double) -> Double = { a in
            let v = ContiguousArray<Double>(repeating: a, count: n)
            var s: Double = 0
            for i in withoutDerivative(at: v.indices) { s += v[i] }
            return s
        }

        let g = gradient(at: 3.0, of: f)
        #expect(g == 0.0)
    }

    @Test("move(by: .zero) is a no-op (your zero tangent is empty)")
    func moveBy_zeroIsNoOp() {
        var x: ContiguousArray<Double> = [1.0, 2.0, -3.0]
        let before = x

        x.move(by: .zero)
        #expect(x == before)
    }

    @Test("move(by:) applies elementwise offsets when tangent has matching count")
    func moveBy_appliesOffsets() {
        var x: ContiguousArray<Double> = [1.0, 2.0, -3.0]
        let offset: ContiguousArray<Double>.TangentVector = [0.5, -1.0, 2.0]

        x.move(by: offset)

        let expected: ContiguousArray<Double> = [1.5, 1.0, -1.0]
        #expect(x == expected)
    }
}

@Suite("Custom derivative: update(at:with:)")
struct ContiguousArrayUpdateDerivativeTests {
    @Test("update blocks gradient to the replaced element (d/dx[i] == 0)")
    func gradient_throughUpdate_wrtX_hasZeroAtReplacedIndex() {
        let i = 1
        let y = 10.0

        // f(x) = sum(x with x[i] replaced by y)
        let f: @differentiable(reverse) (ContiguousArray<Double>) -> Double = { x in
            var z = x
            z.update(at: i, with: y)

            var s: Double = 0
            for i in withoutDerivative(at: z.indices) { s += z[i] }
            return s
        }

        let x: ContiguousArray<Double> = [1.0, 2.0, 3.0]
        let dx = gradient(at: x, of: f)

        // d/dx = [1, 0, 1]
        expectAllClose(asArray(dx), [1.0, 0.0, 1.0])
    }

    @Test("update forwards gradient to the newValue (d/dy == 1 for sum)")
    func gradient_throughUpdate_wrtY_isOne() {
        let i = 1
        let xConst: ContiguousArray<Double> = [1.0, 2.0, 3.0]

        // g(y) = sum(xConst with xConst[i] replaced by y) = y + sum(other elements)
        let g: @differentiable(reverse) (Double, ContiguousArray<Double>) -> Double = { y, z in
            var z = z
            z.update(at: i, with: y)

            var s: Double = 0
            for i in withoutDerivative(at: z.indices) { s += z[i] }
            return s
        }

        let dy = gradient(at: 10.0, xConst, of: g)
        #expect(dy.0 == 1.0)
        #expect(dy.1 == [1.0, 0.0, 1.0])
    }

    @Test("update derivative handles a zero upstream tangent (no crash, gradients are zero-like)")
    func update_withConstantReturn_producesZeroGradients() {
        let i = 1
        let y = 10.0

        let f: @differentiable(reverse) (ContiguousArray<Double>) -> Double = { x in
            var z = x
            z.update(at: i, with: y)
            return 42.0
        }

        let x: ContiguousArray<Double> = [1.0, 2.0, 3.0]
        let dx = gradient(at: x, of: f)

        // We may represent “zero tangent” as empty OR as a full zero vector.
        // We accept either by checking it is a no-op when applied.
        expectActsLikeZeroTangent(base: x, tangent: dx)
    }
}

@Suite("ContiguousArray.DifferentiableView: Collection & AdditiveArithmetic")
struct DifferentiableViewBehaviorTests {
    @Test("Array-literal init + RangeReplaceableCollection basics")
    func arrayLiteralAndRRC() {
        var v: ContiguousArray<Double>.DifferentiableView = [1.0, 2.0]
        v.append(3.0)
        #expect(Array(v) == [1.0, 2.0, 3.0])

        v.replaceSubrange(0 ..< 1, with: [10.0, 11.0])
        #expect(Array(v) == [10.0, 11.0, 2.0, 3.0])

        v[1] = 99.0
        #expect(Array(v) == [10.0, 99.0, 2.0, 3.0])
    }

    @Test("AdditiveArithmetic: zero is empty, and acts as identity in + and -")
    func additiveArithmeticIdentityRules() {
        let v: ContiguousArray<Double>.DifferentiableView = [1.0, -2.0, 0.5]

        // Your `.zero` is an empty view.
        #expect(Array(ContiguousArray<Double>.DifferentiableView.zero).isEmpty)

        #expect(v + .zero == v)
        #expect(.zero + v == v)
        #expect(v - .zero == v)
    }

    @Test("AdditiveArithmetic: subtraction when lhs is empty negates rhs (and keeps rhs length)")
    func additiveArithmetic_zeroMinusV_isNegation() {
        let v: ContiguousArray<Double>.DifferentiableView = [1.0, -2.0, 0.5]
        let neg = ContiguousArray<Double>.DifferentiableView.zero - v

        #expect(Array(neg).count == Array(v).count)
        #expect(Array(neg) == Array(v).map { 0.0 - $0 })
    }

    @Test("AdditiveArithmetic: v - v yields a same-length all-zero vector (not necessarily .zero)")
    func additiveArithmetic_vMinusV_isAllZerosWithSameLength() {
        let v: ContiguousArray<Double>.DifferentiableView = [1.0, -2.0, 0.5]
        let diff = v - v
        let arr = Array(diff)

        #expect(arr.count == 3)
        #expect(arr.allSatisfy { $0 == 0.0 })
        #expect(diff != .zero) // with `.zero == []`, this should be true
    }

    @Test("DifferentiableView.move(by:) is elementwise and treats empty offset as no-op")
    func differentiableView_moveBy() {
        var v: ContiguousArray<Double>.DifferentiableView = [1.0, 2.0, -3.0]
        let before = v

        v.move(by: .zero)
        #expect(v == before)

        let offset: ContiguousArray<Double>.DifferentiableView.TangentVector = [0.5, -1.0, 2.0]
        v.move(by: offset)
        #expect(Array(v) == [1.5, 1.0, -1.0])
    }
}

@Suite("ContiguousArray with nontrivial Element.TangentVector (Box)")
struct ContiguousArrayCustomElementTangentTests {
    @Test("gradient over Box.value works and returns Box.TangentVector elements")
    func gradient_boxValue_sumOfSquares() {
        let f: @differentiable(reverse) (ContiguousArray<Box>) -> Double = { x in
            var s: Double = 0
            for i in withoutDerivative(at: x.indices) {
                s += x[i].value * x[i].value
            }
            return s
        }

        let x: ContiguousArray<Box> = [Box(value: 1.0), Box(value: -2.0), Box(value: 0.5)]
        let g = gradient(at: x, of: f)

        // Each element is Box.TangentVector; inspect its `.value`.
        let gv = Array(g).map(\.value)
        expectAllClose(gv, [2.0, -4.0, 1.0])
    }

    @Test("subscript VJP works for Box and produces a basis vector in Box.TangentVector")
    func gradient_boxSubscript_isBasisVector() {
        let i = 1
        let f: @differentiable(reverse) (ContiguousArray<Box>) -> Double = { x in
            x[i].value
        }

        let x: ContiguousArray<Box> = [Box(value: 10.0), Box(value: 20.0), Box(value: 30.0)]
        let g = gradient(at: x, of: f)

        let gv = Array(g).map(\.value)
        expectAllClose(gv, [0.0, 1.0, 0.0])
    }

    @Test("move(by:) works for Box arrays using the computed tangent")
    func moveBy_boxArray_appliesTangent() {
        let f: @differentiable(reverse) (ContiguousArray<Box>) -> Double = { x in
            var s: Double = 0
            for i in withoutDerivative(at: x.indices) { s += x[i].value * x[i].value }
            return s
        }

        var x: ContiguousArray<Box> = [Box(value: 1.0), Box(value: -2.0), Box(value: 0.5)]
        let g = gradient(at: x, of: f)

        x.move(by: g)
        let xv = x.map(\.value)
        expectAllClose(xv, [3.0, -6.0, 1.5])
    }
}

#endif
