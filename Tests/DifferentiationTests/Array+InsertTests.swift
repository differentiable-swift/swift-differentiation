import Differentiation
import Testing

struct ArrayInsertTests {
    @Test func insert() {
        var array1: [Float] = [1.0, 2.0, 3.0]
        array1.insert(4.0, at: 0)
        #expect(array1.count == 4)
        #expect(array1[0] == 4)

        // Test differentiation.
        var array2: [Float] = [1.0, 2.0, 3.0]
        let (_, insertPullback) = array2._vjpInsert(4.0, at: 0)
        #expect(array2 == [4.0, 1.0, 2.0, 3.0])
        var insertTangent = Array<Float>.TangentVector([4.0, 3.0, 2.0])
        let insertValue = insertPullback(&insertTangent)
        #expect(insertValue == 4.0)
        #expect(insertTangent.count == 2)

        let array3: [Float] = [1.0, 2.0, 3.0]
        let value: Float = 4.0
        let vwpb = valueWithPullback(at: array3, value, of: { array, value in
            var array = array
            array.insert(value, at: 0)
            return array
        })

        #expect(vwpb.value == [4.0, 1.0, 2.0, 3.0])
        let tangent: [Float].TangentVector = [4.0, 3.0, 2.0]
        let gradient = vwpb.pullback(tangent)
        #expect(gradient.0 == [3.0, 2.0])
        #expect(gradient.1 == 4.0)
    }
}
