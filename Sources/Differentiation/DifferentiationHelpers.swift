@inlinable
@inline(__always)
@_semantics("autodiff.nonvarying")
public func withoutDerivative(_ body: () -> Void) {
    body()
}
