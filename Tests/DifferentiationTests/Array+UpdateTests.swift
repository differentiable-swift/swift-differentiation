#if canImport(_Differentiation)

import Differentiation
import Testing

@Suite("Array+Update")
struct ArrayUpdateTests {
    @Test
    func testUpdateWithValue() throws {
        // let's test a function of an array where we modify the array elements
        // using a mutating closure
        @differentiable(reverse)
        func fOfArray(array: [Double]) -> Double {
            var array = array
            var result: Double = 0
            for index in withoutDerivative(at: 0 ..< array.count) {
                let multiplier = 1.0 + Double(index)
                array.update(at: index, with: multiplier * array[index])
                result += array[index]
            }
            return result
        }

        let array = [Double](repeating: 1.0, count: 3)
        let expectedGradientOfFOfArray = [1.0, 2.0, 3.0]
        let obtainedGradientOfFOfArray = gradient(at: array, of: fOfArray).base
        #expect(obtainedGradientOfFOfArray == expectedGradientOfFOfArray)
    }
}

extension Array {
    @inlinable
    public func gather(from indices: [Int]) -> Array<Element> {
        return indices.map { index in
            self[index]
        }
    }
}

extension Array where Element: Differentiable {
    @derivative(of: gather)
    @inlinable
    public func _vjpGather(from indices: [Int]) -> (value: Array<Element>, pullback: (Array<Element>.TangentVector) -> Array<Element>.TangentVector) {
        let count = self.count
        return (
            value: self.gather(from: indices),
            pullback: { (v: Array<Element>.TangentVector) in
                var result: [Element.TangentVector] = .init(repeating: .zero, count: count)
                for (i, tangent) in zip(indices, v) {
                    result[i] += tangent
                }
                return .init(result)
            }
        )
    }
}


@Test
func gather() throws {
    @differentiable(reverse)
    func example1(arr: [Double], indices: [Int]) -> [Double] {
        var result: [Double] = []
        runWithoutDerivative { result.reserveCapacity(indices.count) }
        for i in 0 ..< indices.count {
            let index = indices[i]
            result.append(arr[index])
        }
        return result
    }
    
    @differentiable(reverse)
    func example2(arr: [Double], indices: [Int]) -> [Double] {
        arr.gather(from: indices)
    }
    
    let a: [Double] = [1, 2, 3]
    let indices: [Int] = [0, 0, 2, 0]
    
    let result1 = example1(arr: a, indices: indices)
    let result2 = example2(arr: a, indices: indices)
    
    #expect(result1 == result2)
    
    let vwpb1 = valueWithPullback(at: a, of: { example1(arr: $0, indices: indices) })
    let vwpb2 = valueWithPullback(at: a, of: { example2(arr: $0, indices: indices) })
    
    #expect(vwpb1.value == vwpb2.value)
    
    let one: [Double].TangentVector = [1.0, 0.0, 1.0, 1.0]
    
    let g1 = vwpb1.pullback(one)
    let g2 = vwpb2.pullback(one)
    
    print(g1)
    #expect(g1 == g2)
}

extension Array where Element: Differentiable {
    @inlinable
    public mutating func permute(_ from: Self, indices: [Int], with combining: @differentiable(reverse) (Element, Element) -> Element) {
        assert(from.count == indices.count)
        for i in 0 ..< from.count {
            let j = indices[i]
            let old = self[j]
            let new = from[i]
            self[j] = combining(old, new)
        }
    }
    
    @derivative(of: permute)
    @inlinable
    public mutating func _vjpPermute(_ from: Self, indices: [Int], with combining: @differentiable(reverse) (Element, Element) -> Element) -> (value: (), pullback: (inout Self.TangentVector) -> Self.TangentVector) {
        
        let count = from.count
        var pullbacks: [(Element.TangentVector) -> (Element.TangentVector, Element.TangentVector)] = []
        pullbacks.reserveCapacity(count)
        
        for i in 0 ..< count {
            let j = indices[i]
            let old = self[j]
            let new = from[i]
            let (value, pullback) = valueWithPullback(at: old, new, of: combining)
            pullbacks.append(pullback)
            self[j] = value
        }
        
        return (
            value: (),
            pullback: { v in
                var result = Self.TangentVector(repeating: .zero, count: count)
                for i in (0 ..< count).reversed() {
                    let j = indices[i]
                    let pullback = pullbacks[i]
                    let tangent = v[j]
                    
                    let (gradOld, gradNew) = pullback(tangent)
                    
                    v[j] = gradOld
                    result[i] += gradNew
                }
                return result
            }
        )
    }
}

@Test
func permuteOfzo() {
    @differentiable(reverse)
    func example1(arr: inout [Double], source: [Double], indices: [Int]) {
        arr.permute(source, indices: indices, with: -)
    }
    
    @differentiable(reverse)
    func example2(arr: inout [Double], source: [Double], indices: [Int]) {
        for k in 0 ..< indices.count {
            let lookupIndex = indices[k]
            arr.update(
                at: lookupIndex,
                with: arr[lookupIndex] - source[k]
            )
        }
    }
    
    let arr = [1.0, 2.0, 3.0, 4.0]
    let indices = [1, 0, 3, 2]
    let source = [40.0, 30.0, 20.0, 10.0]
    
    let vwpb1 = valueWithPullback(at: arr, source) { arr, source in
        var arr = arr
        example1(arr: &arr, source: source, indices: indices)
        return arr
    }
    
    let vwpb2 = valueWithPullback(at: arr, source) { arr, source in
        var arr = arr
        example2(arr: &arr, source: source, indices: indices)
        return arr
    }
    
    #expect(vwpb1.value == vwpb2.value)
    
    let one: [Double].TangentVector = [1.0, 0.0, 0.0, 0.0]
    
    let gradient1 = vwpb1.pullback(one)
    let gradient2 = vwpb2.pullback(one)
    
    #expect(gradient1 == gradient2)
}

#endif
