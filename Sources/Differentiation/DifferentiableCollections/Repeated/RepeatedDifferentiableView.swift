extension Repeated where Element: Differentiable {
    public struct DifferentiableView {
        @usableFromInline
        var base: Repeated<Element>

        @inlinable
        public init(base: Repeated<Element>) {
            self.base = base
        }
    }
}

extension Repeated.DifferentiableView: Equatable where Element: Equatable {
    @inlinable
    public static func == (
        lhs: Repeated.DifferentiableView,
        rhs: Repeated.DifferentiableView
    ) -> Bool {
        lhs.base.count == rhs.base.count && lhs.base.repeatedValue == rhs.base.repeatedValue
    }
}

extension Repeated.DifferentiableView: AdditiveArithmetic
    where Element: AdditiveArithmetic
{
    @inlinable
    public static var zero: Repeated.DifferentiableView {
        Repeated.DifferentiableView(base: repeatElement(.zero, count: 0))
    }

    @inlinable
    public static func + (
        lhs: Repeated.DifferentiableView,
        rhs: Repeated.DifferentiableView
    ) -> Repeated.DifferentiableView {
        if lhs.base.count == 0 {
            return rhs
        }
        if rhs.base.count == 0 {
            return lhs
        }
        precondition(
            lhs.base.count == rhs.base.count,
            "Count mismatch: \(lhs.base.count) and \(rhs.base.count)"
        )
        return Repeated.DifferentiableView(base: repeatElement(lhs.base.repeatedValue + rhs.base.repeatedValue, count: lhs.base.count))
    }

    @inlinable
    public static func - (
        lhs: Repeated.DifferentiableView,
        rhs: Repeated.DifferentiableView
    ) -> Repeated.DifferentiableView {
        if lhs.base.count == 0 {
            return Repeated.DifferentiableView(base: repeatElement(.zero - rhs.base.repeatedValue, count: rhs.base.count))
        }
        if rhs.base.count == 0 {
            return lhs
        }
        precondition(
            lhs.base.count == rhs.base.count,
            "Count mismatch: \(lhs.base.count) and \(rhs.base.count)"
        )
        return Repeated.DifferentiableView(base: repeatElement(lhs.base.repeatedValue - rhs.base.repeatedValue, count: lhs.base.count))
    }
}

extension Repeated.DifferentiableView: Differentiable where Element: Differentiable {
    public typealias TangentVector = Repeated<Element.TangentVector>.DifferentiableView

    @inlinable
    public mutating func move(by offset: TangentVector) {
        if offset.base.isEmpty { return }
        precondition(
            self.base.count == offset.base.count, """
            Count mismatch: \(self.base.count) ('self') and \(offset.base.count) \
            ('direction')
            """
        )
        var newRepeatedValue = self.base.repeatedValue
        newRepeatedValue.move(by: offset.base.repeatedValue)
        self.base = repeatElement(newRepeatedValue, count: self.base.count)
    }
}
