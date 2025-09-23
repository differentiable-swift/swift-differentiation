import CollectionsBenchmark
import Differentiation
import Foundation

// MARK: Array<Float>.sumArbitrary
extension Array where Element == Float {
    @inlinable
    @differentiable(reverse)
    func sumArbitrary(indices: [Index]) -> Float {
        var result: Element = 0
        for i in withoutDerivative(at: indices) {
            result += self[i]
        }
        return result
    }
}

extension ConstantTimeAccessor where Element == Float {
    @inlinable
    @differentiable(reverse)
    mutating func sumArbitrary(indices: [Int]) -> Float {
        var result: Element = 0
        for i in 0 ..< self.count {
            self.accessElement(at: i)
            result += self.accessed
        }
        return result
    }
}

extension DCTA where Element == Float {
    @inlinable
    @differentiable(reverse)
    mutating func sumArbitrary(indices: [Int]) -> Float {
        var result: Element = 0
        for i in 0 ..< self.count {
            result += self[i]
        }
        return result
    }
}

fileprivate let benchmarkTitle = "sumArbitrary"

extension Array where Element == Float {
    static func addSumArbitraryBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            input: Array<Float>.self,
            regular: { input in
                let indicesCount = Int(floor(Double(input.count) / Double(4)))
                let indices = (0..<indicesCount).map { _ in Int.random(in: 0..<input.count) }
                return { timer in
                    blackHole(input.sumArbitrary(indices: indices))
                }
            },
            forward: { input in
                let indicesCount = Int(floor(Double(input.count) / Double(4)))
                let indices = (0..<indicesCount).map { _ in Int.random(in: 0..<input.count) }
                return { timer in
                    blackHole(valueWithPullback(at: input, of: { $0.sumArbitrary(indices: indices) }))
                }
            },
            reverse: { input in
                let indicesCount = Int(floor(Double(input.count) / Double(4)))
                let indices = (0..<indicesCount).map { _ in Int.random(in: 0..<input.count) }
                let pullback = valueWithPullback(
                    at: input, of: { $0.sumArbitrary(indices: indices) }
                ).pullback
                return { timer in
                    blackHole(pullback(1.0))
                }
            }
        )
    }
}

extension ConstantTimeAccessor where Element == Float {
    static func addSumArbitraryBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            input: Array<Float>.self,
            regular: { input in
                var input = ConstantTimeAccessor(input)
                let indicesCount = Int(floor(Double(input.count) / Double(4)))
                let indices = (0..<indicesCount).map { _ in Int.random(in: 0..<input.count) }
                return { timer in
                    blackHole(input.sumArbitrary(indices: indices))
                }
            },
            forward: { input in
                let input = ConstantTimeAccessor(input)
                let indicesCount = Int(floor(Double(input.count) / Double(4)))
                let indices = (0..<indicesCount).map { _ in Int.random(in: 0..<input.count) }
                return { timer in
                    blackHole(valueWithPullback(at: input, of: { input in
                        var input = input
                        return input.sumArbitrary(indices: indices)
                    }))
                }
            },
            reverse: { input in
                let input = ConstantTimeAccessor(input)
                let indicesCount = Int(floor(Double(input.count) / Double(4)))
                let indices = (0..<indicesCount).map { _ in Int.random(in: 0..<input.count) }
                let pullback = valueWithPullback(
                    at: input, of: { input in
                        var input = input
                        return input.sumArbitrary(indices: indices)
                    }
                ).pullback
                return { timer in
                    blackHole(pullback(1.0))
                }
            }
        )
    }
}

extension DCTA where Element == Float {
    static func addSumArbitraryBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            input: Array<Float>.self,
            regular: { input in
                var input = DCTA(input)
                let indicesCount = Int(floor(Double(input.count) / Double(4)))
                let indices = (0..<indicesCount).map { _ in Int.random(in: 0..<input.count) }
                return { timer in
                    blackHole(input.sumArbitrary(indices: indices))
                }
            },
            forward: { input in
                let input = DCTA(input)
                let indicesCount = Int(floor(Double(input.count) / Double(4)))
                let indices = (0..<indicesCount).map { _ in Int.random(in: 0..<input.count) }
                return { timer in
                    blackHole(valueWithPullback(at: input, of: { input in
                        var input = input
                        return input.sumArbitrary(indices: indices)
                    }))
                }
            },
            reverse: { input in
                let input = DCTA(input)
                let indicesCount = Int(floor(Double(input.count) / Double(4)))
                let indices = (0..<indicesCount).map { _ in Int.random(in: 0..<input.count) }
                let pullback = valueWithPullback(
                    at: input, of: { input in
                        var input = input
                        return input.sumArbitrary(indices: indices)
                    }
                ).pullback
                return { timer in
                    blackHole(pullback(1.0))
                }
            }
        )
    }
}
