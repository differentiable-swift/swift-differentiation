import _Differentiation

extension Array where Element: Differentiable {
    @inlinable
    public subscript(cta index: Int) -> Element {
        mutating get {
            self[index]
        }
    }
    
    @derivative(of: subscript(cta:))
    @inlinable
    public mutating func _vjpSubscript(cta index: Int) -> (value: Element, pullback: (Element.TangentVector, inout Array.TangentVector) -> Void) {
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
}
