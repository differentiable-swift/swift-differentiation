import Differentiation
import Testing

@Suite("Array Differentiable Methods Tests")
struct CollectionDifferentiableMethodsTests {
    @differentiable(reverse)
    func run1(arr: [Double], subrange: Range<Int>, with newValues: [Double]) -> [Double] {
        var arr = arr
        arr.replaceSubrange(subrange, with: newValues)
        return arr
    }

    @differentiable(reverse)
    func run2(arr: [Double], subrange: Range<Int>, with newValues: [Double]) -> [Double] {
        var arr = arr

        let eraseCount = subrange.count
        let insertCount = withoutDerivative(at: newValues.count)
        let growth = insertCount - eraseCount
        for (subrangeIndex, newValuesIndex) in zip(subrange, 0 ..< withoutDerivative(at: newValues.count)) {
            arr.update(at: subrangeIndex, with: newValues[newValuesIndex])
        }

        if growth > 0 {
            for _ in 0 ..< growth {
                arr.append(.zero)
            }

            for i in 0 ..< growth {
                let newValue = newValues[i + eraseCount]
                let offsetIndex = i + subrange.upperBound
                let oldValue = arr[offsetIndex]
                arr.update(at: offsetIndex, with: newValue)
                arr.update(at: offsetIndex + growth, with: oldValue)
            }
            return arr
        }
        else if growth < 0 {
            for i in 0 ..< abs(growth) {
                let index = i + subrange.lowerBound + insertCount
                arr.update(at: index, with: arr[i + subrange.upperBound])
            }
            let arrayCount = withoutDerivative(at: arr.count)
            var newArr = Array<Double>(repeating: .zero, count: arrayCount + growth)
            for i in 0 ..< arrayCount + growth {
                newArr.update(at: i, with: arr[i])
            }
            return newArr
        }
        else {
            return arr
        }
    }

    @Test
    func sliceArray() {
        @differentiable(reverse)
        func run(arr: [Double], range: Range<Int>) -> Double {
            arr[range].differentiableReduce(0, +)
        }

        let arr: [Double] = [100, 2, 3, 4, 100]

        let (value, pullback) = valueWithPullback(at: arr) { array in
            run(arr: array, range: 1 ..< 4)
        }

        #expect(value == 9)
        let gradient = pullback(1)
        #expect(gradient == [0, 1, 1, 1, 0])
    }

    @Test
    func testReplacingSubrange() {
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

    @Test
    func testReplacingWithLongerSubrange() {
        let a: [Double] = [0, 1, 2, 3, 4]
        let replacement: [Double] = [10, 11, 22]
        let subrange: Range<Int> = 2 ..< 4

        #expect(run1(arr: a, subrange: subrange, with: replacement) == [0, 1, 10, 11, 22, 4])
        #expect(run2(arr: a, subrange: subrange, with: replacement) == [0, 1, 10, 11, 22, 4])

        let (value1, pullback1) = valueWithPullback(at: a, replacement, of: { a, replacement in
            run1(arr: a, subrange: subrange, with: replacement)
        })

        let (value2, pullback2) = valueWithPullback(at: a, replacement, of: { a, replacement in
            run2(arr: a, subrange: subrange, with: replacement)
        })

        #expect(value1 == value2)

        let gradient1 = pullback1([1, 0, 0, 0, 0, 0])
        let gradient2 = pullback2([1, 0, 0, 0, 0, 0])

        #expect(gradient1 == gradient2)

        let gradient3 = pullback1([0, 0, 1, 0, 0, 0])
        let gradient4 = pullback2([0, 0, 1, 0, 0, 0])

        #expect(gradient3 == gradient4)

        print(gradient1, gradient3)
    }

    @Test
    func testReplacingWithShorterSubrange() {
        let a: [Double] = [0, 1, 2, 3, 4]
        let replacement: [Double] = [10]
        let subrange: Range<Int> = 2 ..< 4

        #expect(run1(arr: a, subrange: subrange, with: replacement) == [0, 1, 10, 4])
        #expect(run2(arr: a, subrange: subrange, with: replacement) == [0, 1, 10, 4])

        let (value1, pullback1) = valueWithPullback(at: a, replacement, of: { a, replacement in
            run1(arr: a, subrange: subrange, with: replacement)
        })

        let (value2, pullback2) = valueWithPullback(at: a, replacement, of: { a, replacement in
            run2(arr: a, subrange: subrange, with: replacement)
        })

        #expect(value1 == value2)

        let gradient1 = pullback1([1, 0, 0, 0])
        let gradient2 = pullback2([1, 0, 0, 0])

        #expect(gradient1 == gradient2)

        let gradient3 = pullback1([0, 0, 1, 0])
        let gradient4 = pullback2([0, 0, 1, 0])

        #expect(gradient3 == gradient4)

        print(gradient1, gradient3)
    }
}
