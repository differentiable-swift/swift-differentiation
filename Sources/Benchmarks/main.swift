import CollectionsBenchmark
import Differentiation
import Foundation

var benchmark = Benchmark(title: "Differentiable Collection Benchmarks")


protocol HasBenchmarks {
    static func addMapReduceBenchmarks(_ benchmark: inout Benchmark)
    static func addMeanSquaredErrorBenchmarks(_ benchmark: inout Benchmark)
    static func addLaplaceBenchmarks(_ benchmark: inout Benchmark)
    static func addSubscriptGetContinuousBenchmarks(_ benchmark: inout Benchmark)
    static func addSumArbitraryBenchmarks(_ benchmark: inout Benchmark)
    static func addMutRangeBenchmarks(_ benchmark: inout Benchmark)
}

extension Array: HasLaplaceBenchmark where Element == Float { }
extension DArray: HasLaplaceBenchmark where Element == Float { }

extension Array: HasBenchmarks where Element == Float { }
//extension DArray: HasBenchmarks where Element == Float { }
extension ConstantTimeAccessor: HasBenchmarks where Element == Float { }
extension DCTA: HasBenchmarks where Element == Float { }


let types: [HasBenchmarks.Type] = [
    Array<Float>.self,
    ConstantTimeAccessor<Float>.self,
    DCTA<Float>.self
]

for type in types {
    type.addMapReduceBenchmarks(&benchmark)
    type.addMeanSquaredErrorBenchmarks(&benchmark)
    type.addLaplaceBenchmarks(&benchmark)
    type.addSubscriptGetContinuousBenchmarks(&benchmark)
    type.addSumArbitraryBenchmarks(&benchmark)
    type.addMutRangeBenchmarks(&benchmark)
}

benchmark.main()
