#if canImport(_Differentiation)

import _Differentiation
import Foundation

/// Differentiation of ``atan2``
@derivative(of: atan2(_:_:))
public func vjpAtan2(
    y: Double, x: Double
) -> (value: Double, pullback: (Double) -> (Double, Double)) {
    (
        value: atan2(y, x),
        pullback: { ($0 * x / (x * x + y * y), -$0 * y / (x * x + y * y)) }
    )
}

#endif
