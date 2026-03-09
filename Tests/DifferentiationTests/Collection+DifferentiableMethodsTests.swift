import Differentiation
import Testing

@Suite("Array Differentiable Methods Tests")
struct CollectionDifferentiableMethodsTests {
    @Test
    func testReplacingSubrange() {
        @differentiable(reverse)
        func run1(arr: [Double], subrange: Range<Int>, with newValues: [Double]) -> [Double] {
            var arr = arr
            arr.replaceSubrange(subrange, with: newValues)
            return arr
        }

        @differentiable(reverse)
        func run2(arr: [Double], subrange: Range<Int>, with newValues: [Double]) -> [Double] {
            var arr = arr
            for (subrangeIndex, newValuesIndex) in zip(subrange, 0 ..< withoutDerivative(at: newValues.count)) {
                arr.update(at: subrangeIndex, with: newValues[newValuesIndex])
            }
            return arr
        }

        let a: [Double] = [0, 1, 2, 3, 4]
        let replacement: [Double] = [10, 11]
        let subrange: Range<Int> = 2 ..< 4

        #expect(run1(arr: a, subrange: subrange, with: replacement) == [0, 1, 10, 11, 4])
        #expect(run2(arr: a, subrange: subrange, with: replacement) == [0, 1, 10, 11, 4])

        let (value1, pullback1) = valueWithPullback(at: a, replacement, of: { a, replacement in
            run1(arr: a, subrange: subrange, with: replacement)
        })

        let (value2, pullback2) = valueWithPullback(at: a, replacement, of: { a, replacement in
            run2(arr: a, subrange: subrange, with: replacement)
        })

        #expect(value1 == value2)

        let gradient1 = pullback1([1, 0, 0, 0, 0])
        let gradient2 = pullback2([1, 0, 0, 0, 0])

        #expect(gradient1 == gradient2)

        let gradient3 = pullback1([0, 0, 1, 0, 0])
        let gradient4 = pullback2([0, 0, 1, 0, 0])

        #expect(gradient3 == gradient4)

        print(gradient1, gradient3)
    }
}
