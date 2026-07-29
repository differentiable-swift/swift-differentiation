import Differentiation
import Testing

@Suite("Dictionary+AD")
struct DictionaryADTests {
    // MARK: Getter

    @Test
    func testSubscriptGetGradient() throws {
        let dictionary: [String: Double] = ["a": 3, "b": 7]

        let aMultiplier: Double = 13
        let bMultiplier: Double = 17

        @differentiable(reverse)
        func readFromDictionary(d: [String: Double]) -> Double {
            let a = d[ad: "a"]! * aMultiplier
            let b = d[ad: "b"]! * bMultiplier
            return a + b
        }

        let vwg = valueWithGradient(at: dictionary, of: readFromDictionary)

        #expect(vwg.value == 3 * aMultiplier + 7 * bMultiplier)
        #expect(vwg.gradient == ["a": aMultiplier, "b": bMultiplier])
    }

    @Test
    func testSubscriptGetSameKeyTwiceAccumulates() throws {
        let dictionary: [String: Double] = ["a": 1]

        @differentiable(reverse)
        func readTwice(d: [String: Double]) -> Double {
            d[ad: "a"]! * 2 + d[ad: "a"]! * 3
        }

        let vwg = valueWithGradient(at: dictionary, of: readTwice)

        #expect(vwg.value == 5)
        #expect(vwg.gradient == ["a": 5])
    }

    // MARK: Setter

    @Test
    func testSubscriptSetWriteThenReadAllKeys() throws {
        let dictionary: [String: Double] = ["a": 1, "b": 1]

        let aMultiplier: Double = 13
        let bMultiplier: Double = 17

        @differentiable(reverse)
        func writeAndRead(d: [String: Double], newA: Double, newB: Double) -> Double {
            var d = d
            d[ad: "a"] = newA
            d[ad: "b"] = newB
            return d[ad: "a"]! * aMultiplier + d[ad: "b"]! * bMultiplier
        }

        let vwg = valueWithGradient(at: dictionary, 3.0, 7.0, of: writeAndRead)

        #expect(vwg.value == 3 * aMultiplier + 7 * bMultiplier)
        // Both keys of the input are overwritten, so the input's gradient is zero;
        // the gradients flow to newA/newB instead.
        #expect(vwg.gradient.0 == ["a": 0, "b": 0])
        #expect(vwg.gradient.1 == aMultiplier)
        #expect(vwg.gradient.2 == bMultiplier)
    }

    @Test
    func testSubscriptSetWriteOneKeyReadAnother() throws {
        // Regression test: write to "a", then read a *different* existing key "b".
        // The gradient w.r.t. the input dictionary must preserve d["b"], and newA
        // must receive zero gradient (it does not influence the output).
        let dictionary: [String: Double] = ["a": 1, "b": 1]

        @differentiable(reverse)
        func writeAReadB(d: [String: Double], newA: Double) -> Double {
            var d = d
            d[ad: "a"] = newA
            return d[ad: "b"]! * 2
        }

        let vwg = valueWithGradient(at: dictionary, 5.0, of: writeAReadB)

        #expect(vwg.value == 2)
        #expect(vwg.gradient.0 == ["a": 0, "b": 2])
        #expect(vwg.gradient.1 == 0)
    }
}
