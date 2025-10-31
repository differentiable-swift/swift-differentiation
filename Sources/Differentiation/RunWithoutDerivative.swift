@inlinable
@_alwaysEmitIntoClient
@_semantics("autodiff.nonvarying")
public func runWithoutDerivative<T>(_ body: () -> T) -> T {
    body()
}
