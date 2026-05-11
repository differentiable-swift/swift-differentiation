import Differentiation
import Testing

struct ArrayInsertTests {
    @Test func insert() {
        var array: [Float] = [1.0, 2.0, 3.0]
        array.insert(4.0, at: 0)
        #expect(array.count == 4)
        #expect(array[0] == 4)

        // Test differentiation.
        let (_, insertPullback) = array._vjpInsert(4.0, at: 0)
        var insertTangent = Array<Float>.TangentVector([4.0, 3.0, 2.0])
        let insertValue = insertPullback(&insertTangent)
        #expect(insertValue == 4.0)
        #expect(insertTangent.count == 2)
    }
}
