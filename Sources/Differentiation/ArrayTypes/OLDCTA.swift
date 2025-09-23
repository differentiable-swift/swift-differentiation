/// An array wrapper that provides better performance on the backwards pass in the form of O(1) subscript reads and
/// writes. It also uses a variable-sized array for the tangent vector, which only fills with zeros as needed while
/// still supporting fast array addition.
public struct ConstantTimeAccessor<Element>: Differentiable, AdditiveArithmetic where Element: Differentiable, Element: AdditiveArithmetic {
    /// A variably-sized representation of the tangent vector for the array, only populating with as many zeros or
    /// values as needed. This allows for empty arrays in the .zero case, or small ones if only the first few values are
    /// active. A fully-sparse Dictionary-based tangent vector suffers from extremely slow additions, which are the
    /// most common operations for tangent vectors. This provides a balance between sparsity and quick addition.
    public typealias TangentVector = ConstantTimeAccessor<Element.TangentVector>

    /// The internal holder for the wrapped array.
    @usableFromInline
    var values: [Element]

    /// Rather than using a direct subscript, this property allows for a two-step access to an indexed value in the
    /// array. You first call `accessElement(at:)` to place the indexed value in this property, then read from it. This
    /// is a workaround needed at present to provide O(1) array accesses on the backwards pass without O(N) zero
    /// generation.
    public var accessed: Element

    @inlinable
    @differentiable(reverse)
    public init(_ values: [Element], accessed: Element = .zero) {
        self.values = values
        self.accessed = accessed
    }

    /// This property provides a means of extracting the entire internal array. It has significant overhead, and should
    /// only be used at the point where the use of the ``ConstantTimeAccessor`` is over.
    @inlinable
    @differentiable(reverse)
    public var array: [Element] { values }

    /// Returns the count of the wrapped array. Prevents the need for differentiable access to the internal wrapper.
    @noDerivative
    @inlinable
    public var count: Int { values.count }
}

/// Basic Differentiable conformance for ``ConstantTimeAccessor`` .
public extension ConstantTimeAccessor {
    /// Vector - Jackobian product for initializing an instance of ``ConstantTimeAccessor``
    @inlinable
    @derivative(of: init(_:accessed:))
    static func vjpInit(_ values: [Element], accessed: Element = .zero)
        -> (value: ConstantTimeAccessor, pullback: (Self.TangentVector) -> ([Element].TangentVector, Element.TangentVector))
    {
        (
            value: Self(values, accessed: accessed),
            pullback: { tangentVector in
                var arrayTangentVector = [Element].TangentVector(tangentVector.values)
                if tangentVector.values.count < values.count {
                    (0 ..< (values.count - tangentVector.values.count)).forEach { _ in
                        arrayTangentVector.append(.zero)
                    }
                }
                return (arrayTangentVector, tangentVector.accessed)
            }
        )
    }

    /// Vector - Jackobian product for getting the array elements
    @inlinable
    @derivative(of: array)
    func vjpArray() -> (value: [Element], pullback: ([Element].TangentVector) -> Self.TangentVector) {
        (
            value: self.values,
            pullback: { tangentVector in
                var base: [Element.TangentVector]
                let localZero = Element.TangentVector.zero
                if tangentVector.base.allSatisfy({ $0 == localZero }) {
                    base = []
                }
                else {
                    base = tangentVector.base
                }
                return Self.TangentVector(base, accessed: Element.TangentVector.zero)
            }
        )
    }

    /// Conforming to Differentiable
    mutating func move(by offset: Self.TangentVector) {
        self.accessed.move(by: offset.accessed)
        self.values.move(by: [Element].TangentVector(offset.values))
    }
}

public extension ConstantTimeAccessor {
    /// Returns a `ConstantTimeAccessor` containging the results of mapping the given closure over the original container's elements.
    /// - Parameter transform: A mapping closure. `transform` accepts an element of this container as its parameter and returns a
    /// transformed value of the same or a different type.
    /// - Returns: A `ConstantTimeAccessor` containing the transformed elements of this container.
    @_alwaysEmitIntoClient
    @inlinable
    func map<T>(
        _ transform: (Element) throws -> T
    ) rethrows -> ConstantTimeAccessor<T> {
        .init(try values.map(transform), accessed: try transform(self.accessed))
    }
}

// Constant-time getter support.
public extension ConstantTimeAccessor {
    /// Reads an element at an index in the array, storing the resulting value in `accessed`.
    ///
    /// - Parameter index: The location within the array to read.
    @inlinable
    @differentiable(reverse)
    mutating func accessElement(at index: Int) {
        self.accessed = self.values[index]
    }

    /// Vector - Jackobian product for mutating access of an element at an index
    @inlinable
    @derivative(of: accessElement)
    mutating func vjpAccessElement(at index: Int)
        -> (value: Void, pullback: (inout Self.TangentVector) -> Void)
    {
        (
            value: accessElement(at: index),
            pullback: { tangentVector in
                if tangentVector.count <= index {
                    tangentVector.values.append(contentsOf: [Element.TangentVector](repeating: .zero, count: index - tangentVector.count))
                    tangentVector.values.append(tangentVector.accessed)
                }
                else {
                    tangentVector.values[index] += tangentVector.accessed
                }
                tangentVector.accessed = .zero
            }
        )
    }
}

// Constant-time setter support.
public extension ConstantTimeAccessor {
    /// Writes a new element into an array at a specified location. Differentiation of subscript setters isn't
    /// currently supported, because `Array.subscript.modify` is a coroutine.
    /// [SR-14113](https://bugs.swift.org/browse/SR-14113) tracks this.
    ///
    /// - Parameters:
    ///   - index: The location within the array to write.
    ///   - newValue: The element to insert into the array at this location.
    @inlinable
    @differentiable(reverse)
    mutating func update(at index: Int, with newValue: Element) {
        values[index] = newValue
    }

    /// Vector - Jackobian product for updating an element at the desired index
    @inlinable
    @derivative(of: update(at:with:))
    mutating func vjpUpdate(
        index: Int,
        with newValue: Element
    ) -> (value: Void, pullback: (inout Self.TangentVector) -> (Element.TangentVector)) {
        (
            value: self.update(at: index, with: newValue),
            pullback: { tangentVector in
                guard index < tangentVector.count else { return .zero }
                let dElement = tangentVector.values[index]
                tangentVector.values[index] = .zero
                return dElement
            }
        )
    }
}

// Overrides for AdditiveArithmetic on ConstantTimeAccessor's TangentVector. A significant amount of time is spent in
// adding zeros to things. This detects those zeros and selectively avoids addition and subtraction operations where
// the result would not change. In common operation, roughly 85% of addition operations are prevented by this.
public extension ConstantTimeAccessor {
    /// Conforming to AdditiveArithmetic: addition operation
    @inlinable
    static func + (lhs: Self, rhs: Self) -> Self {
        if rhs.values.isEmpty {
            return lhs
        }
        else if lhs.values.isEmpty {
            return rhs
        }
        else {
            // Note: I experimented with using raw buffer pointers for this, and found no performance difference from
            // the following simpler zip() invocation. Therefore, I'm using the simpler code instead.
            var base = zip(lhs.values, rhs.values).map(+)
            if lhs.count < rhs.count {
                base.append(contentsOf: rhs.values.suffix(from: lhs.count))
            }
            else if lhs.count > rhs.count {
                base.append(contentsOf: lhs.values.suffix(from: rhs.count))
            }

            return Self(base, accessed: lhs.accessed + rhs.accessed)
        }
    }

    /// Conforming to AdditiveArithmetic: subtraction operation
    @inlinable
    static func - (lhs: Self, rhs: Self) -> Self {
        if rhs.values.isEmpty {
            return lhs
        }
        else {
            var base = zip(lhs.values, rhs.values).map(-)
            if lhs.count < rhs.count {
                base.append(contentsOf: rhs.values.suffix(from: lhs.count).map { .zero - $0 })
            }
            else if lhs.count > rhs.count {
                base.append(contentsOf: lhs.values.suffix(from: rhs.count))
            }

            return Self(base, accessed: lhs.accessed - rhs.accessed)
        }
    }

    /// Conforming to AdditiveArithmetic: the zero element
    @inlinable
    static var zero: Self { Self([], accessed: .zero) }
}

// Convenience accessors for arrays hosting SIMD values.
public extension ConstantTimeAccessor where Element == SIMD8<Float> {
    /// Updating an element inside of an array of SIMD
    @inlinable
    @differentiable(reverse)
    mutating func update2D(i iOffset: Int, j jOffset: Int, with newValue: Element.Scalar) {
        self.accessElement(at: iOffset)
        var vector = self.accessed
        vector[jOffset] = newValue
        self.update(at: iOffset, with: vector)
    }

    /// Vector - Jackobian product for updating an element inside of an array of SIMD
    @inlinable
    @derivative(of: update2D(i:j:with:))
    mutating func vjpUpdate2D(
        i iOffset: Int,
        j jOffset: Int,
        with newValue: Element.Scalar
    ) -> (value: Void, pullback: (inout Self.TangentVector) -> (Element.Scalar.TangentVector)) {
        (
            value: self.update2D(i: iOffset, j: jOffset, with: newValue),
            pullback: { tangentVector in
                guard iOffset < tangentVector.count else { return .zero }
                var dElementSimd = tangentVector.values[iOffset]
                let dElement = dElementSimd[jOffset]
                dElementSimd[jOffset] = .zero
                tangentVector.values[iOffset] = dElementSimd
                return dElement
            }
        )
    }
}

// In a few places, we need the ability to insert a value at the head of an array, so this wraps that operation to
// prevent an expensive round-trip to an array and back.
public extension ConstantTimeAccessor where Element: AdditiveArithmetic {
    /// Inserts an element at the head of the array.
    ///
    /// - Parameter value: The item to insert at the front of the array.
    @inlinable
    @differentiable(reverse)
    mutating func insert(_ value: Element) {
        self.values.insert(value, at: 0)
    }

    /// Vector - Jackobian product for inserting an element at the beginning
    @inlinable
    @derivative(of: insert(_:))
    mutating func vjpInsert(_ value: Element) -> (value: Void, pullback: (inout Self.TangentVector) -> (Element.TangentVector)) {
        (
            value: self.insert(value),
            pullback: { $0.values.removeFirst() }
        )
    }
}

extension ConstantTimeAccessor: ExpressibleByArrayLiteral {
    /// Conform to ExpressibleByArrayLiteral
    public init(arrayLiteral values: Element...) {
        self.values = values
        self.accessed = .zero
    }
}

extension ConstantTimeAccessor {
    @inlinable
    // TODO: mark this with @_alwaysEmitIntoClient from 6.3
    @differentiable(reverse, wrt: self)
    public func differentiableMap<Result: Differentiable>(_ body: @differentiable(reverse) (Element) -> Result) -> ConstantTimeAccessor<Result> {
        ConstantTimeAccessor<Result>(self.values.map(body))
    }
    
    @derivative(of: differentiableMap)
    @inlinable
    public func _vjpDifferentiableMap<Result: Differentiable>(_ body: @differentiable(reverse) (Element) -> Result) -> (value: ConstantTimeAccessor<Result>, pullback: (ConstantTimeAccessor<Result>.TangentVector) -> ConstantTimeAccessor.TangentVector) {
        let count = self.count
        var values: [Result] = []
        var pullbacks: [(Result.TangentVector) -> Element.TangentVector] = []
        values.reserveCapacity(count)
        pullbacks.reserveCapacity(count)
        for x in self.values {
            let (y, pb) = valueWithPullback(at: x, of: body)
            values.append(y)
            pullbacks.append(pb)
        }
        func pullback(_ tans: ConstantTimeAccessor<Result>.TangentVector) -> ConstantTimeAccessor.TangentVector {
            .init(zip(tans.values, pullbacks).map { tan, pb in pb(tan) })
        }
        return (value: ConstantTimeAccessor<Result>(values), pullback: pullback)
    }
    
    @inlinable
    @differentiable(reverse, wrt: (self, initialResult))
    public func differentiableReduce<Result: Differentiable>(
        _ initialResult: Result,
        _ nextPartialResult: @differentiable(reverse) (Result, Element) -> Result
    ) -> Result {
        values.reduce(initialResult, nextPartialResult)
    }
    
    @inlinable
    @derivative(of: differentiableReduce)
    public func _vjpDifferentiableReduce<Result: Differentiable>(
        _ initialResult: Result,
        _ nextPartialResult: @differentiable(reverse) (Result, Element) -> Result
    ) -> (
        value: Result,
        pullback: (Result.TangentVector) -> (ConstantTimeAccessor.TangentVector, Result.TangentVector)
    ) {
        var pullbacks:
        [(Result.TangentVector) -> (Result.TangentVector, Element.TangentVector)] = []
        let count = self.count
        pullbacks.reserveCapacity(count)
        var result = initialResult
        for element in self.values {
            let (y, pb) = valueWithPullback(at: result, element, of: nextPartialResult)
            result = y
            pullbacks.append(pb)
        }
        return (
            value: result,
            pullback: { tangent in
                var resultTangent = tangent
                var elementTangents = TangentVector([])
                elementTangents.values.reserveCapacity(count)
                for pullback in pullbacks.reversed() {
                    let (newResultTangent, elementTangent) = pullback(resultTangent)
                    resultTangent = newResultTangent
                    elementTangents.values.append(elementTangent) // TODO: here we can do a prealloc and write in reverse to prevent the copy into the tangentvector at the end
                }
                return (TangentVector(elementTangents.values.reversed()), resultTangent)
            }
        )
    }
}
