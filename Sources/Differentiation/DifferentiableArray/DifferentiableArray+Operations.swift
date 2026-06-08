#if canImport(_Differentiation)

import _Differentiation

extension DifferentiableArray where Element == Float {
    @inlinable
    @differentiable(reverse, wrt: self)
    public func meanSquaredError(to target: DifferentiableArray<Float>) -> Float {
        var mse: Float = 0
        for i in 0 ..< withoutDerivative(at: self.count) {
            let d = self[i] - target[i]
            mse += d * d
        }
        return mse
    }
}

#endif
