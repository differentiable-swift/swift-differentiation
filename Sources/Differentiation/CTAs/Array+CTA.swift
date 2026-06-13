import _Differentiation

/// Adds a differentiable subscript to `Array` using the `cta:` argument label to avoid
/// clashing with the built-in subscript. The getter is `mutating` so the pullback accumulates
/// directly into the existing tangent vector instead of allocating a new one per access.
extension Array where Element: Differentiable {
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
        let size = self.count
        return (
            value: self[index],
            pullback: { dElement, tangentVector in
                if tangentVector.isEmpty {
                    tangentVector.base = [Element.TangentVector](repeating: .zero, count: size)
                }
                tangentVector[index] += dElement
            }
        )
    }

    @inlinable
    @derivative(of: subscript(cta:).set)
    public mutating func _vjpSubscriptCTASet(newValue: Element, cta index: Int)
        -> (value: Void, pullback: (inout TangentVector) -> Element.TangentVector)
    {
        let forwardCount = self.count
        self[index] = newValue
        return (
            value: (),
            pullback: { tangentVector in
                assert(index < forwardCount)
                guard !tangentVector.isEmpty else {
                    // this is a zero tangentVector
                    return .zero
                }

                assert(tangentVector.count == forwardCount)

                let dElement = tangentVector.base[index]
                tangentVector.base[index] = .zero
                return dElement
            }
        )
    }
}
