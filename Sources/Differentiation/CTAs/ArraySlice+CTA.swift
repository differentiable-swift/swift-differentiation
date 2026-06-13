/// A `cta:`-style scalar differentiable subscript on `ArraySlice`.
///
/// Mirrors `Array.subscript(cta:)` in `swift-differentiation/Array+CTA.swift` and
/// `Array.subscript(cta: Range<Int>)` in `Array+CTASlice.swift`: the pullback takes
/// the slice's tangent `inout` so we only allocate the slice tangent once (lazily)
/// and every subsequent call accumulates into it.
///
/// Lets callers consume a small `ArraySlice` directly — `T[cta: i]` — without first
/// materializing it via `Array(slice)`. The `Array.init` step would otherwise
/// allocate a fresh small Array on every forward pass.
extension ArraySlice where Element: Differentiable {
    @inlinable
    public subscript(cta index: Int) -> Element {
        @differentiable(reverse)
        mutating get {
            self[index]
        }

        // TODO: this is a workaround while we're unable to define a direct derivative for `subscript._modify`
        @differentiable(reverse)
        set {
            self[index] = newValue
        }
    }

    @inlinable
    @derivative(of: subscript(cta:))
    public mutating func _vjpSubscriptCTAGet(cta index: Int)
        -> (value: Element, pullback: (Element.TangentVector, inout TangentVector) -> Void)
    {
        // Capture the slice's lowerBound and count at forward time so the pullback
        // can map absolute slice `index` to zero-based tangent position.
        let lowerBound = self.startIndex
        let size = self.count
        return (
            value: self[index],
            pullback: { dElement, tangentVector in
                if tangentVector.isEmpty {
                    tangentVector.base = ArraySlice<Element.TangentVector>(repeating: .zero, count: size)
                }
                tangentVector[index - lowerBound] += dElement
            }
        )
    }

    @inlinable
    @derivative(of: subscript(cta:).set)
    public mutating func _vjpSubscriptCTASet(newValue: Element, cta index: Int)
        -> (value: Void, pullback: (inout TangentVector) -> Element.TangentVector)
    {
        // Capture the slice's lowerBound and count at forward time so the pullback
        // can map absolute slice `index` to zero-based tangent position.
        let lowerBound = self.startIndex
        let size = self.count

        self[index] = newValue
        return (
            value: (),
            pullback: { tangentVector in
                assert(index - lowerBound < size)
                guard !tangentVector.isEmpty else {
                    // this is a zero tangentVector
                    return .zero
                }

                assert(tangentVector.count == size)

                let dElement = tangentVector.base[index - lowerBound]
                tangentVector.base[index - lowerBound] = .zero
                return dElement
            }
        )
    }
}
