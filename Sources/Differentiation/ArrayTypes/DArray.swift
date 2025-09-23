import _Differentiation

public struct DArray<Element>: Differentiable where Element: Differentiable {
    public typealias TangentVector = DArray<Element.TangentVector>

    @usableFromInline
    var storage: Array<Element>
    
    @inlinable
    public mutating func move(by offset: TangentVector) {
        if offset.storage.isEmpty { return }
        
        precondition(
            storage.count == offset.storage.count, """
            Count mismatch: \(storage.count) ('self') and \(offset.storage.count) \
            ('direction')
            """)
        for i in offset.storage.indices {
            storage[i].move(by: offset.storage[i])
        }
    }
    
    @inlinable
    internal init(storage: Array<Element>) {
        self.storage = storage
    }
}

extension DArray:
    Sequence,
    Collection,
    RangeReplaceableCollection,
    RandomAccessCollection,
    BidirectionalCollection,
    MutableCollection
{
    public typealias Index = Array<Element>.Index
    public typealias SubSequence = Array<Element>.SubSequence

    @inlinable
    public subscript(position: Index) -> Element {
        get { storage[position] }
        set(newValue) { storage[position] = newValue }
    }

    @inlinable
    public subscript(bounds: Range<Index>) -> SubSequence {
        get { storage[bounds] }
        set(newValue) { storage[bounds] = newValue }
    }

    @inlinable
    public var startIndex: Index { storage.startIndex }

    @inlinable
    public var endIndex: Index { storage.endIndex }

    @inlinable
    public init() { self.init(Array<Element>()) }

    @inlinable
    public mutating func replaceSubrange<C>(_ subrange: Range<Self.Index>, with newElements: C)
        where C: Collection, Self.Element == C.Element
    {
        storage.replaceSubrange(subrange, with: newElements)
    }
}

extension DArray: ExpressibleByArrayLiteral {
    @inlinable
    public init(arrayLiteral elements: Element...) {
        self.init(storage: elements)
    }
}

extension DArray: Equatable where Element: Equatable {
    @inlinable
    public static func ==(lhs: DArray<Element>, rhs: DArray<Element>) -> Bool {
        lhs.storage == rhs.storage
    }
}

extension DArray: AdditiveArithmetic where Element: AdditiveArithmetic {
    @inlinable
    public static var zero: DArray<Element> { .init(storage: []) }
    
    @inlinable
    public static func + (lhs: DArray<Element>, rhs: DArray<Element>) -> DArray<Element> {
        if lhs.storage.count == 0 {
          return rhs
        }
        if rhs.storage.count == 0 {
          return lhs
        }
        precondition(
          lhs.storage.count == rhs.storage.count,
          "Count mismatch: \(lhs.storage.count) and \(rhs.storage.count)")
        return DArray(storage: zip(lhs.storage, rhs.storage).map(+))
    }
    
    @inlinable
    public static func - (lhs: DArray<Element>, rhs: DArray<Element>) -> DArray<Element> {
        if lhs.storage.count == 0 {
            return rhs
        }
        if rhs.storage.count == 0 {
            return lhs
        }
        precondition(
            lhs.storage.count == rhs.storage.count,
            "Count mismatch: \(lhs.storage.count) and \(rhs.storage.count)")
        return DArray(storage: zip(lhs.storage, rhs.storage).map(-))
    }
}

// MARK: Derivatives

extension DArray {
    @inlinable
    @derivative(of: subscript)
    func _vjpSubscriptGet(position index: Int) -> (value: Element, pullback: (Element.TangentVector) -> TangentVector) {
        let count = self.count
        return (
            value: self[index],
            pullback: { v in
                var dSelf = TangentVector(repeating: .zero, count: count)
                dSelf[index] += v
                return dSelf
            }
        )
    }
    
    @inlinable
    @derivative(of: subscript.set)
    mutating func _vjpSubscriptSet(_ newValue: Element, position index: Int) -> (value: Void, pullback: (inout TangentVector) -> Element.TangentVector) {
        storage[index] = newValue
        return (
            value: (),
            pullback: { v in
                let dElement = v[index]
                v.storage[index] = .zero
                return dElement
            }
        )
    }
    
    @inlinable
    public func map<Result: Differentiable>(_ transform: @differentiable(reverse) (Element) -> Result) -> DArray<Result> {
        DArray<Result>(storage: storage.map(transform))
    }
    
    @inlinable
    @derivative(of: map)
    internal func _vjpMap<Result: Differentiable>(
        _ body: @differentiable(reverse) (Element) -> Result
    ) -> (
        value: DArray<Result>,
        pullback: (DArray<Result>.TangentVector) -> DArray.TangentVector
    ) {
        var values: DArray<Result> = []
        let count = self.count
        values.storage.reserveCapacity(count)
        var pullbacks: [(Result.TangentVector) -> Element.TangentVector] = []
        pullbacks.reserveCapacity(count)
        
        for x in self {
            let (y, pb) = valueWithPullback(at: x, of: body)
            values.append(y)
            pullbacks.append(pb)
        }
        return (
            value: values,
            pullback: { v in
                DArray.TangentVector(storage: zip(v.storage, pullbacks).map { vi, pb in pb(vi) })
            }
        )
    }
    
    @inlinable
    public func reduce<Result: Differentiable>(
        _ initialResult: Result,
        _ nextPartialResult: @differentiable(reverse) (Result, Element) -> Result
    ) -> Result {
        storage.reduce(initialResult, nextPartialResult)
    }
    
    @inlinable
    @derivative(of: reduce)
    func _vjpReduce<Result: Differentiable>(
        _ initialResult: Result,
        _ nextPartialResult: @differentiable(reverse) (Result, Element) -> Result
    ) -> (
        value: Result,
        pullback: (Result.TangentVector) -> (DArray.TangentVector, Result.TangentVector)
    ) {
        var pullbacks: [(Result.TangentVector) -> (Result.TangentVector, Element.TangentVector)] = []
        let count = self.count
        pullbacks.reserveCapacity(count)
        var result = initialResult
        for element in self {
            let (y, pb) = valueWithPullback(at: result, element, of: nextPartialResult)
            result = y
            pullbacks.append(pb)
        }
        return (
            value: result,
            pullback: { tangent in
                var resultTangent = tangent
                var elementTangents = TangentVector([])
                elementTangents.storage.reserveCapacity(count)
                for pullback in pullbacks.reversed() {
                    let (newResultTangent, elementTangent) = pullback(resultTangent)
                    resultTangent = newResultTangent
                    elementTangents.storage.append(elementTangent)
                }
                return (TangentVector(storage: elementTangents.storage.reversed()), resultTangent)
            }
        )
    }
}
