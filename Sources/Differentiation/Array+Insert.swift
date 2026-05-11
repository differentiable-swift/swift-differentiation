import _Differentiation

extension Array where Element: Differentiable {
    @derivative(of: insert)
    @inlinable
    public mutating func _vjpInsert(_: Element, at i: Int) -> (value: Void, pullback: (inout TangentVector) -> Element.TangentVector) {
        (
            value: (),
            pullback: { v in
                v.remove(at: i)
            }
        )
    }
}
