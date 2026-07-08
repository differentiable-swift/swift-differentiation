/// A `cta:`-style differentiable range subscript on `ArraySlice`.
///
/// Mirrors the scalar `subscript(cta:)` in `swift-differentiation/Array+CTA.swift`:
/// the pullback takes the array's tangent `inout` so the wide-tangent allocation
/// happens once (lazily) and every subsequent call only accumulates an N-sized
/// slice into the existing storage.
///
/// The stock `subscript(_: Range<Int>).get` VJP returns a fresh full-sized zero
/// tangent on every invocation, which is bad for performance in hot loops that slice
/// on each iteration.
extension ArraySlice where Element: Differentiable {
    @inlinable
    public subscript(cta bounds: Range<Int>) -> ArraySlice<Element> {
        @differentiable(reverse)
        mutating get {
            self[bounds]
        }
    }

    @inlinable
    @derivative(of: subscript(cta:))
    public mutating func _vjpSubscriptCTARangeGet(cta bounds: Range<Int>)
        -> (
            value: ArraySlice<Element>,
            pullback: (ArraySlice<Element>.TangentVector, inout TangentVector) -> Void
        )
    {
        // Capture the slice's lowerBound and count at forward time so the pullback
        // can map absolute slice indices to zero-based tangent positions.
        let lowerBound = self.startIndex
        let size = self.count
        return (
            value: self[bounds],
            pullback: { vSlice, tangentVector in
                if tangentVector.isEmpty {
                    tangentVector.base = ArraySlice<Element.TangentVector>(repeating: .zero, count: size)
                }
                // `bounds` uses the slice's absolute indices while `tangentVector.base` is
                // zero-based, so shift by `lowerBound`. `vSlice.base` may use its own zero-based
                // indices (constructed via Array[...]) — walk both ranges in lockstep so the
                // accumulation doesn't depend on alignment.
                for (arrayIdx, sliceIdx) in zip(bounds, vSlice.base.indices) {
                    tangentVector.base[arrayIdx - lowerBound] += vSlice.base[sliceIdx]
                }
            }
        )
    }
}
