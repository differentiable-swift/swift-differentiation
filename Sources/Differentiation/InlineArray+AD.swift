#if swift(>=6.2)

import _Differentiation

/// Adds a differentiable subscript to `InlineArray` using the `ad:` argument label to avoid
/// clashing with the built-in subscript.
///
/// Unlike the `cta:` family on `Array`/`ArraySlice`/`ContiguousArray`, the getter is **not**
/// `mutating`: `InlineArray` has a compile-time-known size, so its tangent is a fixed-size inline
/// value, and the `ad:` label signals that difference. A mutating/`inout`-accumulating getter
/// could still help for large tangent vectors. It would allocate the tangent once and accumulate
/// into it rather than producing a fresh full-size tangent per access.
@available(macOS 26, iOS 26, *)
extension InlineArray where Element: Differentiable {
    @inlinable
    public subscript(ad i: Index) -> Element {
        @differentiable(reverse)
        get {
            self[i]
        }

        // TODO: this is a workaround while we're unable to define a direct derivative for `subscript._modify`
        @differentiable(reverse)
        set {
            self[i] = newValue
        }
    }

    @inlinable
    @derivative(of: subscript(ad:))
    public func _vjpSubscriptADGetter(ad i: Index)
        -> (value: Element, pullback: (Element.TangentVector) -> TangentVector)
    {
        (
            value: self[i],
            pullback: { v in
                var array = InlineArray<count, Element.TangentVector>(repeating: .zero)
                array[i] = v
                return array
            }
        )
    }

    @inlinable
    @derivative(of: subscript(ad:).set)
    public mutating func _vjpSubscriptADSetter(newValue: Element, ad i: Index)
        -> (value: Void, pullback: (inout TangentVector) -> Element.TangentVector)
    {
        self[i] = newValue
        return (
            value: (),
            pullback: { (v: inout TangentVector) in
                let dElement = v[i]
                v[i] = Element.TangentVector.zero
                return dElement
            }
        )
    }
}

#endif
