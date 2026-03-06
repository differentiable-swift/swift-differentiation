#if canImport(_Differentiation)

extension ArraySlice where Element: Differentiable {
    @inlinable
    @differentiable(reverse, wrt: (self, initialResult))
    public func differentiableReduce<Result: Differentiable>(
        _ initialResult: Result,
        _ nextPartialResult: @differentiable(reverse) (Result, Element) -> Result
    ) -> Result {
        reduce(initialResult, nextPartialResult)
    }

    @inlinable
    @derivative(of: differentiableReduce)
    internal func _vjpDifferentiableReduce<Result: Differentiable>(
        _ initialResult: Result,
        _ nextPartialResult: @differentiable(reverse) (Result, Element) -> Result
    ) -> (
        value: Result,
        pullback: (Result.TangentVector)
            -> (ArraySlice.TangentVector, Result.TangentVector)
    ) {
        var pullbacks:
            [(Result.TangentVector) -> (Result.TangentVector, Element.TangentVector)] = []
        let count = self.count
        pullbacks.reserveCapacity(count)
        var result = initialResult
        for element in self {
            let (y, pb) =
                valueWithPullback(at: result, element, of: nextPartialResult)
            result = y
            pullbacks.append(pb)
        }
        return (
            value: result,
            pullback: { tangent in
                var resultTangent = tangent
                var elementTangents: [Element.TangentVector] = []
                elementTangents.reserveCapacity(count)
                for pullback in pullbacks.reversed() {
                    let (newResultTangent, elementTangent) = pullback(resultTangent)
                    resultTangent = newResultTangent
                    elementTangents.append(elementTangent)
                }
                return (TangentVector(elementTangents.reversed()), resultTangent)
            }
        )
    }
}

#endif
