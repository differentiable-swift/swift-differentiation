import _Differentiation

public struct DCTA<Element: Differentiable>: Differentiable {
    public typealias TangentVector = DCTA<Element.TangentVector>
    
    @usableFromInline
    var storage: [Element]
    
    @inlinable
    public mutating func move(by offset: TangentVector) {
        if offset.storage.isEmpty {
            return
        }
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
    public init(_ storage: Array<Element>) {
        self.storage = storage
    }
    
    @inlinable
    @noDerivative
    public var count: Int { storage.count }
}

extension DCTA {
    @inlinable
    public subscript(index: Int) -> Element {
        mutating get {
            self.storage[index]
        }
        set {
            self.storage[index] = newValue
        }
    }

    @derivative(of: subscript.get)
    @inlinable
    mutating func _vjpSubscriptGet(index: Int) -> (value: Element, pullback: (Element.TangentVector, inout DCTA.TangentVector) -> Void) {
        let size = self.count
        return (
            value: self[index],
            pullback: { dElement, tangentVector in
                if tangentVector.storage.isEmpty { // TODO: can we lift this out of the method?
                    tangentVector.storage = [Element.TangentVector](repeating: .zero, count: size)
                }
                tangentVector.storage[index] += dElement
            }
        )
    }
    
    @derivative(of: subscript.set)
    @inlinable
    mutating func _vjpSubscriptSet(newValue: Element, index: Int) -> (value: Void, pullback: (inout DCTA.TangentVector) -> (Element.TangentVector)) {
        self[index] = newValue
        return (
            value: (),
            pullback: { tangentVector in
                let dElement = tangentVector.storage[index]
                tangentVector.storage[index] = .zero
                return dElement
            }
        )
    }
}

extension DCTA: ExpressibleByArrayLiteral {
    @inlinable
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension DCTA: Equatable where Element: Equatable {
    @inlinable
    public static func ==(lhs: DCTA<Element>, rhs: DCTA<Element>) -> Bool {
        lhs.storage == rhs.storage
    }
}

extension DCTA: AdditiveArithmetic where Element: AdditiveArithmetic {
    @inlinable
    public static var zero: DCTA<Element> {
        .init([])
    }
    
    @inlinable
    public static func + (lhs: DCTA<Element>, rhs: DCTA<Element>) -> DCTA<Element> {
        if rhs.storage.isEmpty { return lhs }
        else if lhs.storage.isEmpty { return rhs }
        else {
            assert(lhs.count == rhs.count)
            return DCTA(zip(lhs.storage, rhs.storage).map(+))
        }
    }
    
    @inlinable
    public static func - (lhs: DCTA<Element>, rhs: DCTA<Element>) -> DCTA<Element> {
        if rhs.storage.isEmpty { return lhs }
        else if lhs.storage.isEmpty { return rhs }
        else {
            assert(lhs.count == rhs.count)
            return DCTA(zip(lhs.storage, rhs.storage).map(-))
        }
    }
}

extension DCTA {
    @inlinable
    // TODO: mark this with @_alwaysEmitIntoClient from 6.3
    @differentiable(reverse, wrt: self)
    public func differentiableMap<Result: Differentiable>(_ body: @differentiable(reverse) (Element) -> Result) -> DCTA<Result> {
        DCTA<Result>(self.storage.map(body))
    }
    
    @derivative(of: differentiableMap)
    @inlinable
    public func _vjpDifferentiableMap<Result: Differentiable>(_ body: @differentiable(reverse) (Element) -> Result) -> (value: DCTA<Result>, pullback: (DCTA<Result>.TangentVector) -> DCTA.TangentVector) {
        let count = self.count
        var values: [Result] = []
        var pullbacks: [(Result.TangentVector) -> Element.TangentVector] = []
        values.reserveCapacity(count)
        pullbacks.reserveCapacity(count)
        for x in self.storage {
            let (y, pb) = valueWithPullback(at: x, of: body)
            values.append(y)
            pullbacks.append(pb)
        }
        func pullback(_ tans: DCTA<Result>.TangentVector) -> DCTA.TangentVector {
            .init(zip(tans.storage, pullbacks).map { tan, pb in pb(tan) })
        }
        return (value: DCTA<Result>(values), pullback: pullback)
    }
    
    @inlinable
    @differentiable(reverse, wrt: (self, initialResult))
    public func differentiableReduce<Result: Differentiable>(
        _ initialResult: Result,
        _ nextPartialResult: @differentiable(reverse) (Result, Element) -> Result
    ) -> Result {
        self.storage.reduce(initialResult, nextPartialResult)
    }
    
    @inlinable
    @derivative(of: differentiableReduce)
    public func _vjpDifferentiableReduce<Result: Differentiable>(
        _ initialResult: Result,
        _ nextPartialResult: @differentiable(reverse) (Result, Element) -> Result
    ) -> (
        value: Result,
        pullback: (Result.TangentVector) -> (DCTA.TangentVector, Result.TangentVector)
    ) {
        var pullbacks:
        [(Result.TangentVector) -> (Result.TangentVector, Element.TangentVector)] = []
        let count = self.count
        pullbacks.reserveCapacity(count)
        var result = initialResult
        for element in self.storage {
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
                    elementTangents.storage.append(elementTangent) // TODO: here we can do a prealloc and write in reverse to prevent the copy into the tangentvector at the end
                }
                return (TangentVector(elementTangents.storage.reversed()), resultTangent)
            }
        )
    }
}
