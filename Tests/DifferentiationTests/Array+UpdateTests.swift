#if canImport(_Differentiation)

import Testing
@testable import Differentiation

@Suite("Array+Update")
struct ArrayUpdateTests {
    @Test("`update(at:with:)` at a single index")
    func updateAtOneIndex() {
        var array = Array<Double>(repeating: 1.0, count: 3)
        let index = 0
        let vwpb = valueWithPullback(
            at: array,
            of: { array in
                // make a copy here since we can't call valueWithPullback on functions with `inout` parameters directly.
                var arrayCopy = array
                arrayCopy.update(at: index, with: 2.0)
                return arrayCopy
            })

        #expect(vwpb.value == [2.0, 1.0, 1.0])
        // since the value at index 0 is replaced we don't expect it to contribute to the gradient of the array at index 0.
        #expect(vwpb.pullback([1.0, 1.0, 1.0]) == [0.0, 1.0, 1.0])
    }

    @Test("`update(at:with:)` at a single index with a dynamic value")
    func updateAtOneIndexWithDynamicValue() {
        func update(array: [Double], value: Double, at index: Int) -> [Double] {
            // make a copy here since we can't call valueWithPullback on functions with `inout` parameters directly.
            var arrayCopy = array
            arrayCopy.update(at: index, with: value)
            return arrayCopy
        }
        let array = Array<Double>(repeating: 1.0, count: 3)
        let value = 4.0
        let index = 0
        let vwpb = valueWithPullback(
            at: array, value,
            of: { array, value in
                // make a copy here since we can't call valueWithPullback on functions with `inout` parameters directly.
                var arrayCopy = array
                arrayCopy.update(at: index, with: value)
                return arrayCopy
            })

        #expect(vwpb.value == [4.0, 1.0, 1.0])
        // since the value at index 0 is replaced we don't expect it to contribute to the gradient of the array at index 0.
        // instead the value that is placed at that position will have effect on the gradient.
        #expect(vwpb.pullback([1.0, 1.0, 1.0]) == ([0.0, 1.0, 1.0], 1.0))
    }

    @Test("`update(at:with:)` at multiple indices")
    func updateMultipleIndices() {
        @differentiable(reverse)
        func someFunction(array: [Double]) -> Double {
            // make a copy here since we can't call valueWithPullback on functions with `inout` parameters directly.
            var array = array
            var result = 0.0
            for index in withoutDerivative(at: 0 ..< array.count) {
                let multiplier = 1.0 + Double(index)
                array.update(at: index, with: multiplier * array[index])
                result += array[index]
            }
            return result
        }

        let array = Array<Double>(repeating: 1.0, count: 3)
        let gradient = gradient(at: array, of: someFunction)
        #expect(gradient == [1.0, 2.0, 3.0])
    }
}

#endif
