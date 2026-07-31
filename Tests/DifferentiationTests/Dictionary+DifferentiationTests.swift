import Differentiation
import Testing

@Suite("Dictionary+Differentiation")
struct DictionaryDifferentiationTests {
    @Test
    func testSubscriptGet() throws {
        let dictionary: [String: Double] = ["a": 3, "b": 7]

        let aMultiplier: Double = 13
        let bMultiplier: Double = 17

        func readFromDictionary(d: [String: Double]) -> Double {
            let a = d["a"]! * aMultiplier
            let b = d["b"]! * bMultiplier
            return a + b
        }

        let vwg = valueWithGradient(at: dictionary, of: readFromDictionary)

        #expect(vwg.value == 3 * aMultiplier + 7 * bMultiplier)
        #expect(vwg.gradient == ["a": aMultiplier, "b": bMultiplier])
    }

    @Test
    func testDictionaryReadAndCombineValues() {
        @differentiable(reverse)
        func testFunction(newValues: [String: Double]) -> Double {
            1.0 * newValues["s1"]! +
                2.0 * newValues["s2"]! +
                3.0 * newValues["s3"]!
        }

        let vwg = valueWithGradient(
            at: ["s1": 10.0, "s2": 20.0, "s3": 30.0],
            of: testFunction
        )

        #expect(vwg.value == 140.0)
        #expect(vwg.gradient == ["s1": 1.0, "s2": 2.0, "s3": 3.0])
    }

    @Test
    func testDictionaryInoutWriteMethod() {
        @differentiable(reverse)
        func combineByReplacingDictionaryValues(of mainDict: inout [String: Double], with otherDict: [String: Double]) {
            for key in withoutDerivative(at: otherDict.keys) {
                let otherValue = otherDict[key]!
                mainDict[ad: key] = otherValue
            }
        }

        @differentiable(reverse)
        func inoutWrapper(dictionary: [String: Double], otherDictionary: [String: Double]) -> [String: Double] {
            // we wrap the `combineByReplacingDictionaryValues`
            var mainCopy = dictionary
            combineByReplacingDictionaryValues(of: &mainCopy, with: otherDictionary)
            return mainCopy
        }

        let vwpb = valueWithPullback(
            at: ["s1": 10.0, "s2": 20.0, "s3": 30.0],
            ["s1": 2.0], // , "s2": nil, "s3": nil],
            of: inoutWrapper
        )

        #expect(vwpb.value == ["s1": 2.0, "s2": 20.0, "s3": 30.0])
        // we need to provide a full tangentvector to the pullback hence the keys with zero entries.
        #expect(vwpb.pullback(["s1": 1.0, "s2": 0.0, "s3": 0.0]) == (["s2": 0.0, "s3": 0.0], ["s1": 1.0]))
        #expect(vwpb.pullback(["s1": 0.0, "s2": 1.0, "s3": 0.0]) == (["s2": 1.0, "s3": 0.0], ["s1": 0.0]))
        #expect(vwpb.pullback(["s1": 0.0, "s2": 0.0, "s3": 1.0]) == (["s2": 0.0, "s3": 1.0], ["s1": 0.0]))
    }

    @Test
    func testInoutWriteAndSumValues() {
        @differentiable(reverse)
        func combineByReplacingDictionaryValues(of mainDict: inout [String: Double], with otherDict: [String: Double]) {
            for key in withoutDerivative(at: otherDict.keys) {
                let otherValue = otherDict[key]!
                mainDict[ad: key] = otherValue
            }
        }

        @differentiable(reverse)
        func sumValues(of dictionary: [String: Double]) -> Double {
            var sum = 0.0
            for key in withoutDerivative(at: dictionary.keys) {
                sum += dictionary[key]!
            }
            return sum
        }

        @differentiable(reverse, wrt: dictionary)
        func inoutWrapperAndSum(dictionary: [String: Double], otherDictionary: [String: Double]) -> Double {
            var mainCopy = dictionary
            combineByReplacingDictionaryValues(of: &mainCopy, with: otherDictionary)
            return sumValues(of: mainCopy)
        }

        let vwg = valueWithGradient(
            at: ["s1": 10.0, "s2": 20.0, "s3": 30.0],
            ["s1": 2.0], // , "s2": nil, "s3": nil],
            of: inoutWrapperAndSum
        )

        #expect(vwg.value == 52.0)
        #expect(vwg.gradient == (["s2": 1.0, "s3": 1.0], ["s1": 1.0]))
    }

    // Writing to a key that isn't present in the base dictionary would previously make the
    // setter pullback insert `key: .zero` into the base tangent (it zeroes the overwritten
    // slot in place). That stray zero entry would survive into the gradient, so applying it
    // back with `move(by:)` would previously hit `fatalMissingComponent` because the primal
    // dictionary had no such key.
    //
    // Setting the slot to `nil` instead of `.zero` in `_vjpSubscriptSet` would drop the entry
    // (a missing key is definitionally zero) and this now no longer crashes.
    @Test
    func testWritingNewKeyLeavesStrayZeroThatCrashesMove() {
        @differentiable(reverse)
        func insertNewKey(dict: [String: Double]) -> [String: Double] {
            var copy = dict
            copy[ad: "new"] = 5.0 // "new" is absent from the base dictionary
            return copy
        }

        var params = ["a": 1.0]
        let vwpb = valueWithPullback(at: params, of: insertNewKey)

        // Pullback zeroes "new" in place, so the base gradient is ["a": 1.0, "new": 0.0]
        // rather than the sparse ["a": 1.0].
        let gradient = vwpb.pullback(["a": 1.0, "new": 1.0])

        // `params` has no "new" key, so `move(by:)` trips `fatalMissingComponent`.
        params.move(by: gradient)
    }
}
