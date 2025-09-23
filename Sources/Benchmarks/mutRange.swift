import CollectionsBenchmark
import Differentiation
import Foundation

// MARK: Array<Float>.mutRange
extension Array where Element: Differentiable {
    @inlinable
    @differentiable(reverse)
    mutating func mutRange(
        start: Int, end: Int, _ transform: @differentiable(reverse) (Element) -> Element
    ) {
        for i in start ..< end {
            self.update(at: i, with: transform(self[i]))
        }
    }
}

extension ConstantTimeAccessor where Element: Differentiable {
    @inlinable
    @differentiable(reverse)
    mutating func mutRange(
        start: Int, end: Int, _ transform: @differentiable(reverse) (Element) -> Element
    ) {
        for i in start ..< end {
            self.accessElement(at: i)
            self.update(at: i, with: transform(self.accessed))
        }
    }
}

extension DCTA where Element: Differentiable {
    @inlinable
    @differentiable(reverse)
    mutating func mutRange(start: Int, end: Int, _ transform: @differentiable(reverse) (Element) -> Element) {
        for i in start ..< end {
            self[i] = transform(self[i])
        }
    }
}

fileprivate let benchmarkTitle = "mutRange"

extension Array where Element == Float {
    static func addMutRangeBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            input: Array<Float>.self,
            regular: { input in
                var input = input
                let start = 0
                let end = Int(floor(Double(input.count) / Double(4)))
                return { timer in
                    blackHole(input.mutRange(start: start, end: end, { sin($0) }))
                }
            },
            forward: { input in
                let start = 0
                let end = Int(floor(Double(input.count) / Double(4)))
                return { timer in
                    blackHole(
                        valueWithPullback(
                            at: input,
                            of: {
                                var result = $0
                                result.mutRange(start: start, end: end, { sin($0) })
                                return result
                            }
                        )
                    )
                }
            },
            reverse: { input in
                let start = 0
                let end = Int(floor(Double(input.count) / Double(4)))
                let (value, pullback) = valueWithPullback(
                    at: input,
                    of: {
                        var result = $0
                        result.mutRange(start: start, end: end, { sin($0) })
                        return result
                    }
                )
                return { timer in
                    var tangent = Array<Float>.TangentVector(repeating: 0, count: value.count)
                    tangent[0] = 1.0
                    blackHole(pullback(tangent))
                }
            }
        )
    }
}

extension ConstantTimeAccessor where Element == Float {
    static func addMutRangeBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            input: Array<Float>.self,
            regular: { input in
                var input = ConstantTimeAccessor(input)
                let start = 0
                let end = Int(floor(Double(input.count) / Double(4)))
                return { timer in
                    blackHole(input.mutRange(start: start, end: end, { sin($0) }))
                }
            },
            forward: { input in
                let input = ConstantTimeAccessor(input)
                let start = 0
                let end = Int(floor(Double(input.count) / Double(4)))
                return { timer in
                    blackHole(
                        valueWithPullback(
                            at: input,
                            of: {
                                var result = $0
                                result.mutRange(start: start, end: end, { sin($0) })
                                return result
                            }
                        )
                    )
                }
            },
            reverse: { input in
                let input = ConstantTimeAccessor(input)
                let start = 0
                let end = Int(floor(Double(input.count) / Double(4)))
                let (value, pullback) = valueWithPullback(
                    at: input,
                    of: {
                        var result = $0
                        result.mutRange(start: start, end: end, { sin($0) })
                        return result
                    }
                )
                return { timer in
                    var tangent = ConstantTimeAccessor.TangentVector([Float](repeating: 0, count: value.count))
                    tangent.update(at: 0, with: 1.0)
                    blackHole(pullback(tangent))
                }
            }
        )
    }
}

extension DCTA where Element == Float {
    static func addMutRangeBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            input: Array<Float>.self,
            regular: { input in
                var input = DCTA(input)
                let start = 0
                let end = Int(floor(Double(input.count) / Double(4)))
                return { timer in
                    blackHole(input.mutRange(start: start, end: end, { sin($0) }))
                }
            },
            forward: { input in
                let input = DCTA(input)
                let start = 0
                let end = Int(floor(Double(input.count) / Double(4)))
                return { timer in
                    blackHole(
                        valueWithPullback(
                            at: input,
                            of: {
                                var result = $0
                                result.mutRange(start: start, end: end, { sin($0) })
                                return result
                            }
                        )
                    )
                }
            },
            reverse: { input in
                let input = DCTA(input)
                let start = 0
                let end = Int(floor(Double(input.count) / Double(4)))
                let (value, pullback) = valueWithPullback(
                    at: input,
                    of: {
                        var result = $0
                        result.mutRange(start: start, end: end, { sin($0) })
                        return result
                    }
                )
                return { timer in
                    var tangent = DCTA.TangentVector([Float](repeating: 0, count: value.count))
                    tangent[0] = 1.0
                    blackHole(pullback(tangent))
                }
            }
        )
    }
}
