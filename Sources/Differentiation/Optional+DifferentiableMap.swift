#if canImport(_Differentiation)

import _Differentiation

extension Optional where Wrapped: Differentiable {
    @inlinable
    @differentiable(reverse, wrt: self)
    public func differentiableMap<Result: Differentiable>(
        _ body: @differentiable(reverse) (Wrapped) -> Result
    ) -> Optional<Result> {
        map(body)
    }

    @inlinable
    @derivative(of: differentiableMap)
    internal func _vjpDifferentiableMap<Result: Differentiable>(
        _ body: @differentiable(reverse) (Wrapped) -> Result
    ) -> (
        value: Optional<Result>,
        pullback: (Optional<Result>.TangentVector) -> Optional.TangentVector
    ) {
        let vwpb = self.map { valueWithPullback(at: $0, of: body) }
        let bodyPullback = vwpb?.pullback

        func pullback(_ vec: Optional<Result>.TangentVector) -> Optional.TangentVector {
            guard let value = vec.value, let bodyPullback else { return .init(.none) }
            return .init(.some(bodyPullback(value)))
        }

        return (value: vwpb?.value, pullback: pullback)
    }

    @inlinable
    @derivative(of: differentiableMap)
    internal func _jvpDifferentiableMap<Result: Differentiable>(
        _ body: @differentiable(reverse) (Wrapped) -> Result
    ) -> (
        value: Optional<Result>,
        differential: (Optional.TangentVector) -> Optional<Result>.TangentVector
    ) {
        let vwpb = self.map { valueWithDifferential(at: $0, of: body) }
        let bodyDifferential = vwpb?.differential

        func differential(_ vec: Optional.TangentVector) -> Optional<Result>.TangentVector {
            guard let value = vec.value, let bodyDifferential else { return .init(.none) }
            return .init(bodyDifferential(value))
        }

        return (value: vwpb?.value, differential: differential)
    }
}

#endif
