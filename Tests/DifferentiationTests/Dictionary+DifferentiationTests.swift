#if canImport(_Differentiation)

import Differentiation
import Testing

@Suite("Dictionary Differentiation Tests")
struct DictionaryDifferentiationTests {
    
}

import PLDifferentiation
import XCTest

final class DictionaryDifferentiationTests: XCTestCase {
    func testSubscriptGet() throws {
        let dictionary: [String: Double] = ["a": 3, "b": 7]

        let aMultiplier: Double = 13
        let bMultiplier: Double = 17

        func readFromDictionary(d: [String: Double]) -> Double {
            let a = d["a"]! * aMultiplier
            let b = d["b"]! * bMultiplier
            return a + b
        }

        let valAndGrad = valueWithGradient(at: dictionary, of: readFromDictionary)

        XCTAssertEqual(valAndGrad.value, 3 * aMultiplier + 7 * bMultiplier)
        XCTAssertEqual(valAndGrad.gradient["a"]!, aMultiplier)
        XCTAssertEqual(valAndGrad.gradient["b"]!, bMultiplier)
    }

    func testSubscriptSet() throws {
        let dictionary: [String: Double] = ["a": 1, "b": 1]

        let aMultiplier: Double = 13
        let bMultiplier: Double = 17

        func writeAndReadFromDictionary(d: [String: Double], newA: Double, newB: Double) -> Double {
            var d = d
            d.set("a", to: newA)
            d.set("b", to: newB)
            let a = d["a"]! * aMultiplier
            let b = d["b"]! * bMultiplier
            return a + b
        }

        let newA: Double = 3
        let newB: Double = 7

        let valAndGrad = valueWithGradient(at: dictionary, newA, newB, of: writeAndReadFromDictionary)

        XCTAssertEqual(valAndGrad.value, newA * aMultiplier + newB * bMultiplier)
        XCTAssertEqual(valAndGrad.gradient.0["a"], 0)
        XCTAssertEqual(valAndGrad.gradient.0["b"], 0)
        XCTAssertEqual(valAndGrad.gradient.1, aMultiplier)
        XCTAssertEqual(valAndGrad.gradient.2, bMultiplier)
    }

    func testDictionaryNonInout() {
        func getD(from newValues: [String: Double?], at key: String) -> Double? {
            if newValues.keys.contains(key) {
                return newValues[key]!
            }
            return nil
        }
        @differentiable(reverse)
        func testFunctionD(newValues: [String: Double?]) -> Double {
            return 1.0 * getD(from: newValues, at: "s1")! +
                2.0 * getD(from: newValues, at: "s2")! +
                3.0 * getD(from: newValues, at: "s3")!
        }

        func get<DataType>(from newValues: [String: DataType?], at key: String) -> DataType?
            where DataType: Differentiable
        {
            if newValues.keys.contains(key) {
                return newValues[key]!
            }
            return nil
        }
        @differentiable(reverse)
        func testFunction(newValues: [String: Double?]) -> Double {
            return 1.0 * get(from: newValues, at: "s1")! +
                2.0 * get(from: newValues, at: "s2")! +
                3.0 * get(from: newValues, at: "s3")!
        }

        let answerExpected = [1.0, 2.0, 3.0]
        let answerConcreteType = gradient(
            at: ["s1": 10.0, "s2": 20.0, "s3": 30.0],
            of: testFunctionD
        ).sorted(by: { $0.key < $1.key }).compactMap(\.value.value)
        let answerGenericType = gradient(
            at: ["s1": 10.0, "s2": 20.0, "s3": 30.0],
            of: testFunction
        ).sorted(by: { $0.key < $1.key }).compactMap(\.value.value)

        XCTAssertEqual(answerConcreteType, answerExpected)
        XCTAssertEqual(answerGenericType, answerExpected)
    }

    func testDictionaryInout() {
        func dictionaryOperationD(of newValues: [String: Double?], on another: inout [String: Double?]) {
            for key in withoutDerivative(at: another.keys) where newValues.keys.contains(key) {
                let value = newValues[key]!
                another.set(key, to: value)
            }
        }
        @differentiable(reverse)
        func testFunctionD(newValues: [String: Double?], dict: [String: Double?]) -> Double {
            var newDict = dict
            dictionaryOperationD(of: newValues, on: &newDict)
            return 1.0 * newDict["s1"]!! + 2.0 * newDict["s2"]!! + 3.0 * newDict["s3"]!!
        }

        func dictionaryOperation<DataType>(of newValues: [String: DataType?], on another: inout [String: DataType?])
            where DataType: Differentiable
        {
            for key in withoutDerivative(at: another.keys) where newValues.keys.contains(key) {
                let value = newValues[key]!
                another.set(key, to: value)
            }
        }
        @differentiable(reverse)
        func testFunction(newValues: [String: Double?], dict: [String: Double?]) -> Double {
            var newDict = dict
            dictionaryOperation(of: newValues, on: &newDict)
            return 1.0 * newDict["s1"]!! + 2.0 * newDict["s2"]!! + 3.0 * newDict["s3"]!!
        }
        let answerExpected = [1.0, 2.0, 3.0]
        let answerConcreteType = gradient(
            at: ["s1": 10.0, "s2": 20.0, "s3": 30.0],
            ["s1": 0.0, "s2": nil, "s3": nil],
            of: testFunctionD
        ).0.sorted(by: { $0.key < $1.key }).compactMap(\.value.value)
        let answerGenericType = gradient(
            at: ["s1": 10.0, "s2": 20.0, "s3": 30.0],
            ["s1": 0.0, "s2": nil, "s3": nil],
            of: testFunction
        ).0.sorted(by: { $0.key < $1.key }).compactMap(\.value.value)

        XCTAssertEqual(answerConcreteType, answerExpected)
        XCTAssertEqual(answerGenericType, answerExpected)
    }
}

#endif
