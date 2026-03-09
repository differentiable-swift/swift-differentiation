import Differentiation
import Testing

@Suite("Array Differentiable Methods Tests")
struct CollectionDifferentiableMethodsTests {
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
}
