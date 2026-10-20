#if compiler(>=6.4)
import _Differentiation

extension Array where Element: Differentiable {
    @inlinable
    @differentiable(reverse, wrt: self)
    public func differentiableThrowingMap<Result: Differentiable, E: Error>(
        _ body: @differentiable(reverse) (Element) throws(E) -> Result
    ) throws(E) -> [Result] {
        try map(body)
    }

    @inlinable
    @derivative(of: differentiableThrowingMap)
    internal func _vjpDifferentiableThrowingMap<Result: Differentiable, E: Error>(
        _ body: @differentiable(reverse) (Element) throws(E) -> Result
    ) throws(E) -> (
        value: [Result],
        pullback: (Array<Result>.TangentVector) -> Array.TangentVector
    ) {
        let count = self.count
        var values: [Result] = []
        var pullbacks: [(Result.TangentVector) -> Element.TangentVector] = []
        values.reserveCapacity(count)
        pullbacks.reserveCapacity(count)
        for x in self {
            let (y, pb) = try valueWithPullback(at: x, of: body)
            values.append(y)
            pullbacks.append(pb)
        }
        func pullback(_ tans: Array<Result>.TangentVector) -> Array.TangentVector {
            .init(zip(tans.base, pullbacks).map { tan, pb in pb(tan) })
        }
        return (value: values, pullback: pullback)
    }
}

#endif
