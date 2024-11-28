#if canImport(_Differentiation)

import Differentiation
import Testing

@Suite("Dictionary+Update")
struct DictionaryUpdateTests {
    @Test
    func testUpdateWithValue() throws {
        let dictionary: [String: Double] = ["a": 1, "b": 1]

        let aMultiplier: Double = 13
        let bMultiplier: Double = 17

        func writeAndReadFromDictionary(d: [String: Double], newA: Double, newB: Double) -> Double {
            var d = d
            d.update(at: "a", with: newA)
            d.update(at: "b", with: newB)
            let a = d["a"]! * aMultiplier
            let b = d["b"]! * bMultiplier
            return a + b
        }

        let newA: Double = 3
        let newB: Double = 7

        let valAndGrad = valueWithGradient(at: dictionary, newA, newB, of: writeAndReadFromDictionary)
        
        #expect(valAndGrad.value == newA * aMultiplier + newB * bMultiplier)
        #expect(valAndGrad.gradient == (["a": 0, "b": 0], aMultiplier, bMultiplier))
    }
}

#endif
