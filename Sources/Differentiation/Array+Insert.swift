import _Differentiation

extension Array where Element: Differentiable {
    @derivative(of: insert)
    @inlinable
    public mutating func _vjpInsert(
        _ newElement: Element,
        at i: Int
    ) -> (value: Void, pullback: (inout TangentVector) -> Element.TangentVector) {
        self.insert(newElement, at: i)
        return (
            value: (),
            pullback: { v in
                v.remove(at: i)
            }
        )
    }
}
