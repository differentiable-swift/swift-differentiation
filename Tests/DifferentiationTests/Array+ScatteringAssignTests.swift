import Differentiation
import Testing

struct ArrayScatteringAssignTests {
    @Test func scatteringAssign() {
        var array: [Float] = [1.0, 2.0, 3.0, 4.0]

        array.scatteringAssign(at: [0, 1], values: [7.0, 8.0])

        #expect(array == [7.0, 8.0, 3.0, 4.0])
    }

    @Test func vjpScatteringAssign() {
        var array: [Float] = [1.0, 2.0, 3.0, 4.0]

        // Test differentiation directly through the VJP.
        let (_, pullback) = array._vjpScatteringAssign(at: [2, 0], values: [7.0, 8.0])
        #expect(array == [8.0, 2.0, 7.0, 4.0])

        var outTangent: [Float].TangentVector = [1.0, 2.0, 3.0, 4.0]
        let dValues = pullback(&outTangent)

        // The written slots are gathered into the values cotangent...
        #expect(dValues == [3.0, 1.0])
        // ...and severed from the self cotangent.
        #expect(outTangent == [0.0, 2.0, 0.0, 4.0])
    }

    @Test func scatteringAssignSlicedIndices() {
        var array: [Float] = [1.0, 2.0, 3.0, 4.0]

        // A slice with a non-zero start index: elements [2, 0], but startIndex == 1.
        // Positional indexing (indices[0]) would trap or read the wrong element here.
        let backing = [9, 2, 0, 9]
        let indices = backing[1 ..< 3]
        #expect(indices.startIndex == 1)

        let (_, pullback) = array._vjpScatteringAssign(at: indices, values: [7.0, 8.0])
        #expect(array == [8.0, 2.0, 7.0, 4.0])

        var outTangent: [Float].TangentVector = [1.0, 2.0, 3.0, 4.0]
        let dValues = pullback(&outTangent)
        #expect(dValues == [3.0, 1.0])
        #expect(outTangent == [0.0, 2.0, 0.0, 4.0])
    }

    @Test func differentiableScatteringAssign() {
        @differentiable(reverse)
        func assignScattered(_ array: [Float], values: [Float]) -> [Float] {
            var array = array
            array.scatteringAssign(at: [2, 0], values: values)
            return array
        }

        let testArray: [Float] = [1.0, 2.0, 3.0, 4.0]

        let vwpb = valueWithPullback(at: testArray, [7.0, 8.0], of: assignScattered)
        #expect(vwpb.value == [8.0, 2.0, 7.0, 4.0])

        let unit0: [Float].TangentVector = [1.0, 0.0, 0.0, 0.0]
        let unit1: [Float].TangentVector = [0.0, 1.0, 0.0, 0.0]
        let unit2: [Float].TangentVector = [0.0, 0.0, 1.0, 0.0]
        let unit3: [Float].TangentVector = [0.0, 0.0, 0.0, 1.0]

        // Slot 0 was overwritten by values[1]: gradient goes to values, not to the array.
        let gradient0 = vwpb.pullback(unit0)
        #expect(gradient0.0 == [0.0, 0.0, 0.0, 0.0])
        #expect(gradient0.1 == [0.0, 1.0])

        // Slot 1 was untouched: gradient passes straight through to the array.
        let gradient1 = vwpb.pullback(unit1)
        #expect(gradient1.0 == unit1)
        #expect(gradient1.1 == [0.0, 0.0])

        // Slot 2 was overwritten by values[0].
        let gradient2 = vwpb.pullback(unit2)
        #expect(gradient2.0 == [0.0, 0.0, 0.0, 0.0])
        #expect(gradient2.1 == [1.0, 0.0])

        // Slot 3 was untouched.
        let gradient3 = vwpb.pullback(unit3)
        #expect(gradient3.0 == unit3)
        #expect(gradient3.1 == [0.0, 0.0])
    }

    @Test func scatteringAssignMatchesClearThenAdd() {
        // `scatteringAssign` replaces the clear-then-`scatteringAdd` idiom: zero out the written
        // slots, then add the new values. Both the value and the gradients must agree.
        let indices = [3, 1]

        @differentiable(reverse)
        func viaAssign(_ array: [Double], values: [Double]) -> [Double] {
            var array = array
            array.scatteringAssign(at: indices, values: values)
            return array
        }

        @differentiable(reverse)
        func viaClearThenAdd(_ array: [Double], values: [Double]) -> [Double] {
            var array = array
            // Clear the written slots by adding back their negated prior values, then scatter in
            // the new ones. Value-wise `x - x + v == v`, and the self-gradient at those slots
            // cancels to zero — exactly what `scatteringAssign` does in one pass.
            let prior = array.gather(at: indices)
            array.scatteringAdd(at: indices, values: prior.differentiableMap { -$0 })
            array.scatteringAdd(at: indices, values: values)
            return array
        }

        let testArray: [Double] = [1.0, 2.0, 3.0, 4.0, 5.0]
        let testValues: [Double] = [9.0, 8.0]

        let assigned = valueWithPullback(at: testArray, testValues, of: viaAssign)
        let cleared = valueWithPullback(at: testArray, testValues, of: viaClearThenAdd)
        #expect(assigned.value == cleared.value)

        let seed: [Double].TangentVector = [1.0, 2.0, 3.0, 4.0, 5.0]
        let assignedGradient = assigned.pullback(seed)
        let clearedGradient = cleared.pullback(seed)
        #expect(assignedGradient.0 == clearedGradient.0)
        #expect(assignedGradient.1 == clearedGradient.1)
    }

    @Test func vjpScatteringAssignDuplicateIndices() {
        var array: [Float] = [1.0, 2.0, 3.0, 4.0]

        // Slot 1 is written twice: the forward pass is last-write-wins, so values[1] survives
        // and values[0] never reaches the output.
        let (_, pullback) = array._vjpScatteringAssign(at: [1, 1], values: [5.0, 6.0])
        #expect(array == [1.0, 6.0, 3.0, 4.0])

        var outTangent: [Float].TangentVector = [1.0, 2.0, 3.0, 4.0]
        let dValues = pullback(&outTangent)

        // Only the surviving write earns the cotangent; the overwritten one gets zero.
        #expect(dValues == [0.0, 2.0])
        #expect(outTangent == [1.0, 0.0, 3.0, 4.0])
    }

    @Test func differentiableScatteringAssignDuplicateIndices() {
        // Same last-write-wins contract, but through the real AD path rather than the raw VJP.
        @differentiable(reverse)
        func assignScattered(_ array: [Double], values: [Double]) -> [Double] {
            var array = array
            array.scatteringAssign(at: [2, 0, 2], values: values)
            return array
        }

        let vwpb = valueWithPullback(at: [1.0, 2.0, 3.0, 4.0], [7.0, 8.0, 9.0], of: assignScattered)
        // values[0] writes slot 2 first, then values[2] overwrites it.
        #expect(vwpb.value == [8.0, 2.0, 9.0, 4.0])

        let gradient = vwpb.pullback([10.0, 20.0, 30.0, 40.0])
        // Slots 0 and 2 were written, so their self-gradient is severed; 1 and 3 pass through.
        #expect(gradient.0 == [0.0, 20.0, 0.0, 40.0])
        // values[0] was overwritten before it reached the output, so it earns nothing.
        #expect(gradient.1 == [0.0, 10.0, 30.0])
    }

    @Test func scatteringAssignDuplicatesMatchClearThenAdd() {
        // The clear-then-add reference has no notion of "last write", so spell the equivalent
        // out directly: assigning [a, b] to the same slot must match assigning just b.
        @differentiable(reverse)
        func twice(_ array: [Double], values: [Double]) -> [Double] {
            var array = array
            array.scatteringAssign(at: [1, 1], values: values)
            return array
        }

        @differentiable(reverse)
        func once(_ array: [Double], values: [Double]) -> [Double] {
            var array = array
            array.scatteringAssign(at: [1], values: [values[1]])
            return array
        }

        let testArray: [Double] = [1.0, 2.0, 3.0]
        let testValues: [Double] = [5.0, 6.0]

        let duplicated = valueWithPullback(at: testArray, testValues, of: twice)
        let single = valueWithPullback(at: testArray, testValues, of: once)
        #expect(duplicated.value == single.value)

        let seed: [Double].TangentVector = [1.0, 2.0, 3.0]
        #expect(duplicated.pullback(seed).0 == single.pullback(seed).0)
        #expect(duplicated.pullback(seed).1 == single.pullback(seed).1)
    }

    /// The defining property of a correct pullback for a linear operator: it is the transpose.
    /// `<A(s, v), y> == <s, ds> + <v, dv>` must hold for every seed, which pins the pullback
    /// exactly — including the back-to-front walk that duplicate indices depend on. Stronger than
    /// the hand-picked gradients above, since no choice of indices can satisfy it by accident.
    @Test func scatteringAssignPullbackIsTheTranspose() {
        func dot(_ a: [Double], _ b: [Double]) -> Double {
            zip(a, b).reduce(0) { $0 + $1.0 * $1.1 }
        }

        for indices in [[0, 2], [2, 0, 2], [1, 1], [3, 3, 3], [4, 3, 2, 1, 0], []] {
            let s: [Double] = [1.0, 2.0, 3.0, 4.0, 5.0]
            let v = (0 ..< indices.count).map { Double($0) * 10.0 + 7.0 }
            let y: [Double] = [0.5, -2.0, 3.0, 1.25, -0.75]

            var out = s
            out.scatteringAssign(at: indices, values: v)
            let lhs = dot(out, y)

            var array = s
            let (_, pullback) = array._vjpScatteringAssign(at: indices, values: v)
            var tv = [Double].TangentVector(y)
            let dValues = pullback(&tv)
            let rhs = dot(s, tv.base) + dot(v, dValues.base)

            #expect(lhs == rhs, "indices \(indices): \(lhs) vs \(rhs)")
        }
    }

    @Test func scatteringAssignEmptyTangent() {
        func example(array: [Double], values: [Double]) -> [Double] {
            var array = array
            array.scatteringAssign(at: [1, 0, 5], values: values)
            return array
        }
        let vwpb = valueWithPullback(at: [1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [7.0, 8.0, 9.0], of: example)
        #expect(vwpb.value == [8.0, 7.0, 3.0, 4.0, 5.0, 9.0])
        let gradient = vwpb.pullback([])
        #expect(gradient.0 == [])
        #expect(gradient.1 == [])
    }

    @Test func scatteringAssignWrongSizedTangent() async {
        await #expect(processExitsWith: .failure) {
            let indices = [1, 0, 5]
            let vwpb = valueWithPullback(at: [1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [7.0, 8.0, 9.0]) { arr, vals in
                var arr = arr
                arr.scatteringAssign(at: indices, values: vals)
                return arr
            }
            #expect(vwpb.value == [8.0, 7.0, 3.0, 4.0, 5.0, 9.0])
            _ = vwpb.pullback([1.0])
        }
    }

    @Test func scatteringAssignMismatchedLengths() async {
        await #expect(processExitsWith: .failure) {
            var array: [Double] = [1.0, 2.0, 3.0]
            array.scatteringAssign(at: [0, 1], values: [1.0])
        }
    }
}
