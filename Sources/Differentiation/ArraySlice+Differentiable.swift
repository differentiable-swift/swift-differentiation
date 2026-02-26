import _Differentiation

extension ArraySlice where Element: Differentiable {
    public struct DifferentiableView {
        public var base: ArraySlice<Element>
    }
}

extension ArraySlice.DifferentiableView {
    @inlinable
    public init(_ base: ArraySlice<Element>) {
        self.base = base
    }
}

extension ArraySlice.DifferentiableView: Equatable where Element: Equatable {
    @inlinable
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.base == rhs.base
    }
}

extension ArraySlice.DifferentiableView: AdditiveArithmetic where Element: AdditiveArithmetic {
    @inlinable
    public static var zero: Self { .init([]) }

    @inlinable
    public static func +(lhs: Self, rhs: Self) -> Self {
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
        return ArraySlice.DifferentiableView(zip(lhs.base, rhs.base).map(+)[...])
    }

    public static func -(lhs: Self, rhs: Self) -> Self {
        if lhs.base.count == 0 {
            return ArraySlice.DifferentiableView(rhs.base.map { .zero - $0 }[...])
        }
        if rhs.base.count == 0 {
            return lhs
        }
        precondition(
            lhs.base.count == rhs.base.count,
            "Count mismatch: \(lhs.base.count) and \(rhs.base.count)")
        return ArraySlice.DifferentiableView(zip(lhs.base, rhs.base).map(-)[...])
    }
}

extension ArraySlice.DifferentiableView: Differentiable {
    public typealias TangentVector = ArraySlice<Element.TangentVector>.DifferentiableView
    
    @inlinable
    public mutating func move(by offset: TangentVector) {
        if offset.base.isEmpty {
            return
        }
        precondition(
        base.count == offset.base.count, """
            Count mismatch: \(base.count) ('self') and \(offset.base.count) \
            ('direction')
            """)
        for i in offset.base.indices {
            base[i].move(by: offset.base[i])
        }
    }
}

extension ArraySlice.DifferentiableView {
    // TODO: is this correct?
    public typealias SubSequence = ArraySlice.SubSequence
    
    @inlinable
    public subscript(position: Index) -> Element {
        _read { yield base[position] }
        set(newValue) { base[position] = newValue }
    }
    
    @inlinable
    public subscript(bounds: Range<Index>) -> SubSequence {
        get { base[bounds] }
        set(newValue) { base[bounds] = newValue }
    }
}

extension ArraySlice.DifferentiableView: Collection {
    public typealias Index = ArraySlice.Index
    
    @inlinable
    public func index(after i: ArraySlice<Element>.Index) -> ArraySlice<Element>.Index {
        base.index(after: i)
    }
    
    @inlinable
    public var startIndex: ArraySlice<Element>.Index {
        base.startIndex
    }
    
    @inlinable
    public var endIndex: ArraySlice<Element>.Index {
        base.endIndex
    }
}

extension ArraySlice.DifferentiableView: RangeReplaceableCollection {
    @inlinable
    public init() {
        self.base = .init()
    }
    
    public mutating func replaceSubrange<C>(_ subrange: Range<ArraySlice<Element>.Index>, with newElements: C) where C: Collection, Element == C.Element {
        base.replaceSubrange(subrange, with: newElements)
    }
}

extension ArraySlice.DifferentiableView: MutableCollection {
    
}

extension ArraySlice: @retroactive Differentiable where Element: Differentiable {
    public typealias TangentVector = ArraySlice<Element.TangentVector>.DifferentiableView
    
    public func move(by offset: TangentVector) {
        fatalError()
    }
}

extension Array where Element: Differentiable {
    @derivative(of: Array.subscript.get)
    @inlinable
    public func _vjpSubscriptRangeGet(bounds: Range<Int>) -> (value: ArraySlice<Element>, pullback: (ArraySlice<Element>.TangentVector) -> Array<Element>.TangentVector) {
        let forwardCount = self.count
        return (
            value: self[bounds],
            pullback: { v in
                var result = Array<Element>.TangentVector(repeating: .zero, count: forwardCount)
                result.replaceSubrange(bounds, with: v)
                return result
            }
        )
    }
}

extension ContiguousArray where Element: Differentiable {
    @derivative(of: init)
    @inlinable
    static func _vjpInit<C: Collection>(_ c: C) -> (value: Self, pullback: (Self.TangentVector) -> C.TangentVector) where C: Differentiable, C.Element == Element, C.TangentVector: RangeReplaceableCollection, Element.TangentVector == C.TangentVector.Element {
        (
            value: .init(c),
            pullback: { v in
                return C.TangentVector(v)
            }
        )
    }
}

extension Array where Element: Differentiable {
    @derivative(of: init)
    @inlinable
    static func _vjpInit<C: Collection>(_ c: C) -> (value: Self, pullback: (Self.TangentVector) -> C.TangentVector) where C: Differentiable, C.Element == Element, C.TangentVector: RangeReplaceableCollection, Element.TangentVector == C.TangentVector.Element {
        (
            value: .init(c),
            pullback: { v in
                return C.TangentVector(v)
            }
        )
    }
}
