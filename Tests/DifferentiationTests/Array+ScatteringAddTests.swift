import Differentiation
import Testing

@Suite
struct ArrayScatteringAddTests {
    @Test func scatteringAdd() {
        var array: [Float] = [1.0, 2.0, 3.0, 4.0]

        array.scatteringAdd(at: [0, 1], values: [1.0, 1.0])

        #expect(array == [2.0, 3.0, 3.0, 4.0])
    }

    @Test func vjpScatteringAdd() {
        var array: [Float] = [1.0, 2.0, 3.0, 4.0]

        // Test differentiation directly through the VJP.
        let (_, pullback) = array._vjpScatteringAdd(at: [2, 0, 2], values: [1.0, 2.0, 3.0])
        #expect(array == [3.0, 2.0, 7.0, 4.0])

        var outTangent: [Float].TangentVector = [1.0, 2.0, 3.0, 4.0]
        let dBase = pullback(&outTangent)

        #expect(dBase == [3.0, 1.0, 3.0])
    }

    @Test func scatteringAddSlicedIndices() {
        var array: [Float] = [1.0, 2.0, 3.0, 4.0]

        // A slice with a non-zero start index: elements [2, 0, 2], but startIndex == 1.
        // Positional indexing (indices[0]) would trap or read the wrong element here.
        let backing = [9, 2, 0, 2, 9]
        let indices = backing[1 ..< 4]
        #expect(indices.startIndex == 1)

        let (_, pullback) = array._vjpScatteringAdd(at: indices, values: [1.0, 2.0, 3.0])
        #expect(array == [3.0, 2.0, 7.0, 4.0])

        var outTangent: [Float].TangentVector = [1.0, 2.0, 3.0, 4.0]
        let dValues = pullback(&outTangent)
        #expect(dValues == [3.0, 1.0, 3.0])
    }

    @Test func differentiableScatteringAdd() {
        @differentiable(reverse)
        func sumScattered(_ array: [Float], values: [Float]) -> [Float] {
            var array = array
            array.scatteringAdd(at: [2, 0, 2], values: values)
            return array
        }

        let testArray: [Float] = [1.0, 2.0, 3.0, 4.0]

        let vwpb = valueWithPullback(at: testArray, [3.0, 2.0, 1.0], of: sumScattered)
        #expect(vwpb.value == [3.0, 2.0, 7.0, 4.0])

        let unit0: [Float].TangentVector = [1.0, 0.0, 0.0, 0.0]
        let unit1: [Float].TangentVector = [0.0, 1.0, 0.0, 0.0]
        let unit2: [Float].TangentVector = [0.0, 0.0, 1.0, 0.0]
        let unit3: [Float].TangentVector = [0.0, 0.0, 0.0, 1.0]

        let gradient0 = vwpb.pullback(unit0)
        #expect(gradient0.0 == unit0)
        #expect(gradient0.1 == [0.0, 1.0, 0.0])

        let gradient1 = vwpb.pullback(unit1)
        #expect(gradient1.0 == unit1)
        #expect(gradient1.1 == [0.0, 0.0, 0.0])

        let gradient2 = vwpb.pullback(unit2)
        #expect(gradient2.0 == unit2)
        #expect(gradient2.1 == [1.0, 0.0, 1.0])

        let gradient3 = vwpb.pullback(unit3)
        #expect(gradient3.0 == unit3)
        #expect(gradient3.1 == [0.0, 0.0, 0.0])
    }

    @Test func scatteringAddOutOfRange() {
        func example(_ array: [Double], values: [Double]) -> [Double] {
            var array = array
            array.scatteringAdd(at: [2, 5], values: values)
            return array
        }

        let testArray: [Double] = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]

        let vwpb = valueWithPullback(at: testArray, [1.0, 4.0], of: example)

        #expect(vwpb.value == [1.0, 2.0, 4.0, 4.0, 5.0, 10.0])

        let unit0: [Double].TangentVector = [1.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        let unit1: [Double].TangentVector = [0.0, 1.0, 0.0, 0.0, 0.0, 0.0]
        let unit2: [Double].TangentVector = [0.0, 0.0, 1.0, 0.0, 0.0, 0.0]
        let unit3: [Double].TangentVector = [0.0, 0.0, 0.0, 1.0, 0.0, 0.0]
        let unit4: [Double].TangentVector = [0.0, 0.0, 0.0, 0.0, 1.0, 0.0]
        let unit5: [Double].TangentVector = [0.0, 0.0, 0.0, 0.0, 0.0, 1.0]

        let gradient0 = vwpb.pullback(unit0)
        #expect(gradient0.0 == unit0)
        #expect(gradient0.1 == [0.0, 0.0])

        let gradient1 = vwpb.pullback(unit1)
        #expect(gradient1.0 == unit1)
        #expect(gradient1.1 == [0.0, 0.0])

        let gradient2 = vwpb.pullback(unit2)
        #expect(gradient2.0 == unit2)
        #expect(gradient2.1 == [1.0, 0.0])

        let gradient3 = vwpb.pullback(unit3)
        #expect(gradient3.0 == unit3)
        #expect(gradient3.1 == [0.0, 0.0])

        let gradient4 = vwpb.pullback(unit4)
        #expect(gradient4.0 == unit4)
        #expect(gradient4.1 == [0.0, 0.0])

        let gradient5 = vwpb.pullback(unit5)
        #expect(gradient5.0 == unit5)
        #expect(gradient5.1 == [0.0, 1.0])
    }

    @Test func scatterEmptyTangent() {
        func example(array: [Double], values: [Double]) -> [Double] {
            var array = array
            array.scatteringAdd(at: [1, 0, 5], values: values)
            return array
        }
        let vwpb = valueWithPullback(at: [1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [1.0, 2.0, 1.0], of: example)
        #expect(vwpb.value == [3.0, 3.0, 3.0, 4.0, 5.0, 7.0])
        let gradient = vwpb.pullback([])
        #expect(gradient.0 == [])
        #expect(gradient.1 == [0.0, 0.0, 0.0])
    }

    @Test func scatteringAddWrongSizedTangent() async {
        await #expect(processExitsWith: .failure) {
            let indices = [1, 0, 5]
            let vwpb = valueWithPullback(at: [1.0, 2.0, 3.0, 4.0, 5.0, 6.0], [1.0, 4.0, 1.0]) { arr, vals in
                var arr = arr
                arr.scatteringAdd(at: indices, values: vals)
                return arr
            }
            #expect(vwpb.value == [5.0, 3.0, 3.0, 4.0, 5.0, 7.0])
            _ = vwpb.pullback([1.0])
        }
    }
}
