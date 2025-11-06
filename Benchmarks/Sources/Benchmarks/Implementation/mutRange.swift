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

private let benchmarkTitle = "mutRange"

extension Array where Element == Float {
    static func addMutRangeBenchmarks(_ benchmark: inout Benchmark) {
        benchmark.add(
            title: benchmarkTitle,
            type: Self.self,
            regular: { input in
                var input = input
                let start = 0
                let end = Int(floor(Double(input.count) / Double(4)))
                return { _ in
                    blackHole(input.mutRange(start: start, end: end, { sin($0) }))
                }
            },
            forward: { input in
                let start = 0
                let end = Int(floor(Double(input.count) / Double(4)))
                return { _ in
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
                return { _ in
                    var tangent = Array<Float>.TangentVector(repeating: 0, count: value.count)
                    tangent[0] = 1.0
                    blackHole(pullback(tangent))
                }
            }
        )
    }
}
