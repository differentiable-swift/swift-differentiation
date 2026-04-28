// Copyright (c) 2026 PassiveLogic, Inc.

//@testable import ConstantTimeAccessor
import Differentiation
import Testing

struct ConstantTimeAccessorTests {
    @Test func accessed() {
        var array: [Float] = [1.0, 2.0, 3.0]
        #expect(array[cta: 1] == 2.0)
        #expect(array[cta: 2] == 3.0)

        // Test differentiation.
        let (_, accessPullback) = array._vjpSubscript(cta: 1)
        var accessTangent = Array<Float>.TangentVector([0.0, 3.0, 2.0])
        accessPullback(1.0, &accessTangent)
        #expect(accessTangent.count == 3)
        #expect(accessTangent[1] == 4.0)
        var accessTangent2 = Array<Float>.TangentVector([0.0])
        accessPullback(1.0, &accessTangent2)
        #expect(accessTangent2.count == 3)
        #expect(accessTangent2[1] == 1.0)
    }

    @Test func update() {
        var array: [Float] = [1.0, 2.0, 3.0]
        array.update(at: 1, with: 4.0)
        #expect(array[cta: 1] == 4.0)

        // Test differentiation.
        let (_, updatePullback) = array._vjpUpdate(at: 1, with: 4.0)
        var updateTangent = Array<Float>.TangentVector([0.0, 3.0, 2.0])
        let updateValue = updatePullback(&updateTangent)
        #expect(updateValue == 3.0)
        #expect(updateTangent[1] == 0.0)
    }

    @Test func insert() {
        var array: [Float] = [1.0, 2.0, 3.0]
        array.insert(4.0, at: 0)
        #expect(array.count == 4)
        #expect(array[cta: 0] == 4)

        // Test differentiation.
        let (_, insertPullback) = array._vjpInsert(4.0, at: 0)
        var insertTangent = Array<Float>.TangentVector([4.0, 3.0, 2.0])
        let insertValue = insertPullback(&insertTangent)
        #expect(insertValue == 4.0)
        #expect(insertTangent.count == 2)
    }

    @Test func differentiableArray() {
        @differentiable(reverse)
        func sumFirstThree(_ array: [Float]) -> Float {
            array[0] * array[0] + array[1] + array[3] * array[3]
        }

        let testArray: [Float] = [2, 3, 4, 5, 6, 7]

        #expect(
            gradient(at: testArray, of: sumFirstThree) == [4, 1, 0, 10, 0, 0]
        )
    }

    @Test func differentiableCTA() {
        @differentiable(reverse)
        func sumFirstThree(_ array: [Float]) -> Float {
            var array = array
            let v0 = array[cta: 0]
            let v1 = array[cta: 1]
            let v3 = array[cta: 3]
            return v0 * v0 + v1 + v3 * v3
        }

        let testArray: [Float] = [2, 3, 4, 5, 6, 7]

        #expect(
            gradient(at: testArray, of: sumFirstThree) == [4, 1, 0, 10, 0, 0]
        )
    }
}
