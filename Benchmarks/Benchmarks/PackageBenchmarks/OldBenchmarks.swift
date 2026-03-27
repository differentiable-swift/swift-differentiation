//
//  OldBenchmarks.swift
//  Benchmarks
//
//  Created by Jaap on 25/03/2026.
//
import Benchmark
import Differentiation

let oldBenchmarks: @Sendable () -> Void = {
    Benchmark("regular execution (array zip)") { benchmark in
        let array0: [Double] = (0 ..< 1000).map { Double($0) }
        let array1: [Double] = (0 ..< 1000).map { Double($0) + 1.0 }
        let array2: [Double] = (0 ..< 1000).map { Double($0 % 3) }
        let array3: [Double] = (0 ..< 1000).map { Double($0 % 4) }
        
        benchmark.startMeasurement()
        
        let result: [Double] = differentiableZipWith(array0, array1, array2, array3) { v0, v1, v2, v3 in
            v0 * v1 * v2 * v3
        }
        benchmark.stopMeasurement()
        blackHole(result)
    }
    
    Benchmark("2 forward execution (array zip)") { benchmark in
        let array0: [Double] = (0 ..< 1000).map { Double($0) }
        let array1: [Double] = (0 ..< 1000).map { Double($0) + 1.0 }
//        let array3: [Double] = (0 ..< 1000).map { Double($0 % 4) }
        benchmark.startMeasurement()
        
        let (value, pullback) = valueWithPullback(at: array0, array1) { a0, a1 in
            var a0 = a0
            var a1 = a1
            return differentiableZipWith(a0, a1) { v0, v1 in
                v0 * v1
            }
        }
        benchmark.stopMeasurement()
        let gradient = pullback(Array.DifferentiableView(Array(repeating: 1.0, count: 1000)))
        
        blackHole(value)
        blackHole(gradient)
    }
    
    Benchmark("3 forward execution (array zip)") { benchmark in
        let array0: [Double] = (0 ..< 1000).map { Double($0) }
        let array1: [Double] = (0 ..< 1000).map { Double($0) + 1.0 }
        let array2: [Double] = (0 ..< 1000).map { Double($0 % 3) }
//        let array3: [Double] = (0 ..< 1000).map { Double($0 % 4) }
        benchmark.startMeasurement()
        
        let (value, pullback) = valueWithPullback(at: array0, array1, array2) { a0, a1, a2 in
            var a0 = a0
            var a1 = a1
            var a2 = a2
            return differentiableZipWith(a0, a1, a2) { v0, v1, v2 in
                v0 * v1 * v2
            }
        }
        benchmark.stopMeasurement()
        let gradient = pullback(Array.DifferentiableView(Array(repeating: 1.0, count: 1000)))
        
        blackHole(value)
        blackHole(gradient)
    }
    
    Benchmark("2 reverse execution (array zip)") { benchmark in
        let array0: [Double] = (0 ..< 1000).map { Double($0) }
        let array1: [Double] = (0 ..< 1000).map { Double($0) + 1.0 }
//        let array3: [Double] = (0 ..< 1000).map { Double($0 % 4) }
        
        
        let (value, pullback) = valueWithPullback(at: array0, array1) { a0, a1 in
            var a0 = a0
            var a1 = a1
            return differentiableZipWith(a0, a1) { v0, v1 in
                v0 * v1
            }
        }
        benchmark.startMeasurement()
        let gradient = pullback(Array.DifferentiableView(Array(repeating: 1.0, count: 1000)))
        benchmark.stopMeasurement()
        blackHole(value)
        blackHole(gradient)
    }
    
    Benchmark("3 reverse execution (array zip)") { benchmark in
        let array0: [Double] = (0 ..< 1000).map { Double($0) }
        let array1: [Double] = (0 ..< 1000).map { Double($0) + 1.0 }
        let array2: [Double] = (0 ..< 1000).map { Double($0 % 3) }
//        let array3: [Double] = (0 ..< 1000).map { Double($0 % 4) }
        
        
        let (value, pullback) = valueWithPullback(at: array0, array1, array2) { a0, a1, a2 in
            var a0 = a0
            var a1 = a1
            var a2 = a2
            return differentiableZipWith(a0, a1, a2) { v0, v1, v2 in
                v0 * v1 * v2
            }
        }
        
        benchmark.startMeasurement()
        let gradient = pullback(Array.DifferentiableView(Array(repeating: 1.0, count: 1000)))
        benchmark.stopMeasurement()
        blackHole(value)
        blackHole(gradient)
    }
    
    Benchmark("regular execution (cta)") { benchmark in
        let array0: [Double] = (0 ..< 1000).map { Double($0) }
        let array1: [Double] = (0 ..< 1000).map { Double($0) + 1.0 }
        let array2: [Double] = (0 ..< 1000).map { Double($0 % 3) }
        let array3: [Double] = (0 ..< 1000).map { Double($0 % 4) }
        
        var cta0 = ConstantTimeAccessor(array0)
        var cta1 = ConstantTimeAccessor(array1)
        var cta2 = ConstantTimeAccessor(array2)
        var cta3 = ConstantTimeAccessor(array3)
        
        benchmark.startMeasurement()
        
        var result = ConstantTimeAccessor.init(Array(repeating: 0.0, count: 1000))
        
        for i in 0 ..< result.count {
            cta0.accessElement(at: i)
            cta1.accessElement(at: i)
            cta2.accessElement(at: i)
            cta3.accessElement(at: i)
            let value = cta0.accessed * cta1.accessed * cta2.accessed * cta3.accessed
            result.update(at: i, with: value)
        }

        benchmark.stopMeasurement()
        blackHole(result)
    }
    
    Benchmark("2 forward execution (cta)") { benchmark in
        let array0: [Double] = (0 ..< 1000).map { Double($0) }
        let array1: [Double] = (0 ..< 1000).map { Double($0) + 1.0 }
//        let array3: [Double] = (0 ..< 1000).map { Double($0 % 4) }
        
        let cta0 = ConstantTimeAccessor(array0)
        let cta1 = ConstantTimeAccessor(array1)
//        let cta3 = ConstantTimeAccessor(array3)
        
        benchmark.startMeasurement()
        
        let (value, pullback) = valueWithPullback(at: cta0, cta1) { cta0, cta1 in
            var cta0 = cta0
            var cta1 = cta1
            
            var result = ConstantTimeAccessor.init(Array(repeating: 0.0, count: 1000))
            
            for i in 0 ..< result.count {
                cta0.accessElement(at: i)
                cta1.accessElement(at: i)
                let value = cta0.accessed * cta1.accessed
                result.update(at: i, with: value)
            }
            return result
        }
        
        benchmark.stopMeasurement()
        
        let gradient = pullback(ConstantTimeAccessor(Array(repeating: 1.0, count: 1000)))
        
        blackHole(value)
        blackHole(gradient)
    }
    
    Benchmark("3 forward execution (cta)") { benchmark in
        let array0: [Double] = (0 ..< 1000).map { Double($0) }
        let array1: [Double] = (0 ..< 1000).map { Double($0) + 1.0 }
        let array2: [Double] = (0 ..< 1000).map { Double($0 % 3) }
//        let array3: [Double] = (0 ..< 1000).map { Double($0 % 4) }
        
        let cta0 = ConstantTimeAccessor(array0)
        let cta1 = ConstantTimeAccessor(array1)
        let cta2 = ConstantTimeAccessor(array2)
//        let cta3 = ConstantTimeAccessor(array3)
        
        benchmark.startMeasurement()
        
        let (value, pullback) = valueWithPullback(at: cta0, cta1, cta2) { cta0, cta1, cta2 in
            var cta0 = cta0
            var cta1 = cta1
            var cta2 = cta2
            
            var result = ConstantTimeAccessor.init(Array(repeating: 0.0, count: 1000))
            
            for i in 0 ..< result.count {
                cta0.accessElement(at: i)
                cta1.accessElement(at: i)
                cta2.accessElement(at: i)
                let value = cta0.accessed * cta1.accessed * cta2.accessed
                result.update(at: i, with: value)
            }
            return result
        }
        
        benchmark.stopMeasurement()
        
        let gradient = pullback(ConstantTimeAccessor(Array(repeating: 1.0, count: 1000)))
        
        blackHole(value)
        blackHole(gradient)
    }
    
    Benchmark("2 reverse execution (cta)") { benchmark in
        let array0: [Double] = (0 ..< 1000).map { Double($0) }
        let array1: [Double] = (0 ..< 1000).map { Double($0) + 1.0 }
//        let array3: [Double] = (0 ..< 1000).map { Double($0 % 4) }
        
        let cta0 = ConstantTimeAccessor(array0)
        let cta1 = ConstantTimeAccessor(array1)
//        let cta3 = ConstantTimeAccessor(array3)
        
        let (value, pullback) = valueWithPullback(at: cta0, cta1) { cta0, cta1 in
            var cta0 = cta0
            var cta1 = cta1
            
            var result = ConstantTimeAccessor.init(Array(repeating: 0.0, count: 1000))
            
            for i in 0 ..< result.count {
                cta0.accessElement(at: i)
                cta1.accessElement(at: i)
                let value = cta0.accessed * cta1.accessed
                result.update(at: i, with: value)
            }
            return result
        }
        
        benchmark.startMeasurement()
        
        let gradient = pullback(ConstantTimeAccessor(Array(repeating: 1.0, count: 1000)))
        
        benchmark.stopMeasurement()
        blackHole(value)
        blackHole(gradient)
    }
    
    Benchmark("3 reverse execution (cta)") { benchmark in
        let array0: [Double] = (0 ..< 1000).map { Double($0) }
        let array1: [Double] = (0 ..< 1000).map { Double($0) + 1.0 }
        let array2: [Double] = (0 ..< 1000).map { Double($0 % 3) }
//        let array3: [Double] = (0 ..< 1000).map { Double($0 % 4) }
        
        let cta0 = ConstantTimeAccessor(array0)
        let cta1 = ConstantTimeAccessor(array1)
        let cta2 = ConstantTimeAccessor(array2)
//        let cta3 = ConstantTimeAccessor(array3)
        
        let (value, pullback) = valueWithPullback(at: cta0, cta1, cta2) { cta0, cta1, cta2 in
            var cta0 = cta0
            var cta1 = cta1
            var cta2 = cta2
            
            var result = ConstantTimeAccessor.init(Array(repeating: 0.0, count: 1000))
            
            for i in 0 ..< result.count {
                cta0.accessElement(at: i)
                cta1.accessElement(at: i)
                cta2.accessElement(at: i)
                let value = cta0.accessed * cta1.accessed * cta2.accessed
                result.update(at: i, with: value)
            }
            return result
        }
        
        benchmark.startMeasurement()
        
        let gradient = pullback(ConstantTimeAccessor(Array(repeating: 1.0, count: 1000)))
        
        benchmark.stopMeasurement()
        blackHole(value)
        blackHole(gradient)
    }
    
}
