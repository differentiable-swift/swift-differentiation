import CollectionsBenchmark
import Differentiation
import Foundation

var benchmark = Benchmark(title: "Differentiable Collection Benchmarks")

benchmark.registerInputGenerator(for: [Float].self) { size in
    (0 ..< size).map { _ in Float.random(in: -1.0E10 ... 1.0E10) }
}

benchmark.registerInputGenerator(for: ([Float], [Float]).self) { size in
    (
        (0 ..< size).map { _ in Float.random(in: -1.0E10 ... 1.0E10) },
        (0 ..< size).map { _ in Float.random(in: -1.0E10 ... 1.0E10) }
    )
}

benchmark.registerInputGenerator(for: DArray<Float>.self) { size in
    DArray((0 ..< size).map { _ in Float.random(in: -1.0E10 ... 1.0E10) })
}

benchmark.registerInputGenerator(for: (DArray<Float>, DArray<Float>).self) { size in
    (
        DArray((0 ..< size).map { _ in Float.random(in: -1.0E10 ... 1.0E10) }),
        DArray((0 ..< size).map { _ in Float.random(in: -1.0E10 ... 1.0E10) })
    )
}

benchmark.registerInputGenerator(for: ConstantTimeAccessor<Float>.self) { size in
    ConstantTimeAccessor((0 ..< size).map { _ in Float.random(in: -1.0E10 ... 1.0E10) })
}

benchmark.registerInputGenerator(for: (ConstantTimeAccessor<Float>, ConstantTimeAccessor<Float>).self) { size in
    (
        ConstantTimeAccessor((0 ..< size).map { _ in Float.random(in: -1.0E10 ... 1.0E10) }),
        ConstantTimeAccessor((0 ..< size).map { _ in Float.random(in: -1.0E10 ... 1.0E10) })
    )
}

benchmark.registerInputGenerator(for: DCTA<Float>.self) { size in
    DCTA((0 ..< size).map { _ in Float.random(in: -1.0E10 ... 1.0E10) })
}

benchmark.registerInputGenerator(for: (DCTA<Float>, DCTA<Float>).self) { size in
    (
        DCTA((0 ..< size).map { _ in Float.random(in: -1.0E10 ... 1.0E10) }),
        DCTA((0 ..< size).map { _ in Float.random(in: -1.0E10 ... 1.0E10) })
    )
}

protocol HasBenchmarks {
    static func addMapReduceBenchmarks(_ benchmark: inout Benchmark)
    static func addZipMapAddBenchmarks(_ benchmark: inout Benchmark)
    static func addMeanSquaredErrorBenchmarks(_ benchmark: inout Benchmark)
    static func addLaplaceBenchmarks(_ benchmark: inout Benchmark)
    static func addSubscriptGetContinuousBenchmarks(_ benchmark: inout Benchmark)
    static func addSumArbitraryBenchmarks(_ benchmark: inout Benchmark)
    static func addMutRangeBenchmarks(_ benchmark: inout Benchmark)
}

extension Array: HasBenchmarks where Element == Float {}
extension DArray: HasBenchmarks where Element == Float {}
extension ConstantTimeAccessor: HasBenchmarks where Element == Float {}
extension DCTA: HasBenchmarks where Element == Float {}

let types: [HasBenchmarks.Type] = [
    Array<Float>.self,
    DArray<Float>.self,
    ConstantTimeAccessor<Float>.self,
    DCTA<Float>.self,
]

for type in types {
    type.addMapReduceBenchmarks(&benchmark)
    type.addZipMapAddBenchmarks(&benchmark)
    type.addMeanSquaredErrorBenchmarks(&benchmark)
    type.addLaplaceBenchmarks(&benchmark)
    type.addSubscriptGetContinuousBenchmarks(&benchmark)
    type.addSumArbitraryBenchmarks(&benchmark)
    type.addMutRangeBenchmarks(&benchmark)
}

benchmark.main()
