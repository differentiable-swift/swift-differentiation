
@derivative(of: repeatElement)
@inlinable
public func _vjpRepeatElement<Element: Differentiable>(
    _ element: Element,
    count: Int
) -> (value: Repeated<Element>, pullback: (Repeated<Element>.TangentVector) -> (Element.TangentVector)) {
    (
        value: repeatElement(element, count: count),
        pullback: { v in
            v.base.repeatedValue
        }
    )
}
