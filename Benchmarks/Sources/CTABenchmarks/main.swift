import CollectionsBenchmark
import Differentiation

var benchmark = Benchmark(title: "CTA Benchmarks")

//benchmark.add(
//    title: "regular.cta.Array.mse",
//    input: Int.self
//) { size in
//    var input = Array.random(of: size)
//    var target = Array.random(of: size)
//        
//    return { _ in
//        var value: Float = 0.0
//        
//        for i in 0 ..< input.count {
//            let d = input[cta: i] - target[cta: i]
//            value += d * d
//        }
//        blackHole(value)
//    }
//}
//
//benchmark.add(
//    title: "regular.cta.CTA.mse",
//    input: Int.self
//) { size in
//    let input = ConstantTimeAccessor(Array.random(of: size))
//    let target = ConstantTimeAccessor(Array.random(of: size))
//    return { _ in
//        var input = input
//        var target = target
//        var value: Float = 0.0
//        
//        for i in 0 ..< input.count {
//            input.accessElement(at: i)
//            target.accessElement(at: i)
//            let d = input.accessed - target.accessed
//            value += d * d
//        }
//        blackHole(value)
//    }
//}

//benchmark.add(
//    title: "vwpb.cta.Array.mse",
//    input: Int.self
//) { size in
//    return { _ in
//        let input = Array.random(of: size)
//        let target = Array.random(of: size)
//        let vwpb = valueWithPullback(at: input, target) { input, target in
//            var value: Float = 0.0
//            
//            for i in 0 ..< withoutDerivative(at: input.count) {
//                let d = input[i] - target[i]
//                value += d * d
//            }
//            return value
//        }
//        blackHole(vwpb)
//    }
//}

benchmark.add(
    title: "vwpb.cta.CTA.mse",
    input: Int.self
) { size in
    let input = ConstantTimeAccessor(Array.random(of: size))
    let target = ConstantTimeAccessor(Array.random(of: size))
        
    return { _ in
                
        let vwpb = valueWithPullback(at: input, of: { input in
            var input = input
            var target = target

            var value: Float = 0.0
            
            for i in 0 ..< withoutDerivative(at: input.count) {
                input.accessElement(at: i)
                target.accessElement(at: i)
                let d = input.accessed - target.accessed
                value += d * d
            }
            return value
        })
        blackHole(vwpb)
    }
}


benchmark.main()
