#if canImport(_Differentiation)

import _Differentiation

// MARK: - Differentiable conformance
//
// TangentVector = DifferentiableArrayTangentVector<Element.TangentVector>
// (parameterized by the *element tangent type*, following the ContiguousArray.DifferentiableView pattern)
//
// This ensures TangentVector.TangentVector == TangentVector because:
//   DifferentiableArrayTangentVector<Element.TangentVector>.TangentVector
//     = DifferentiableArrayTangentVector<Element.TangentVector.TangentVector>
//     = DifferentiableArrayTangentVector<Element.TangentVector>  (since Element.TangentVector: Differentiable)
//     = TangentVector ✓

extension DifferentiableArray: Differentiable where Element: Differentiable {
    public typealias TangentVector = DifferentiableArrayTangentVector<Element.TangentVector>

    @inlinable
    public mutating func move(by offset: TangentVector) {
        switch offset.storage {
        case .zero:
            return
        case .oneHot(let i, let v, _):
            _storage[i].move(by: v)
        case .full(let tangents):
            precondition(
                _storage.count == tangents.count,
                "Count mismatch: \(_storage.count) ('self') and \(tangents.count) ('offset')"
            )
            for i in _storage.indices {
                _storage[i].move(by: tangents[i])
            }
        }
    }
}

// MARK: - Differentiable mutation helper

extension DifferentiableArray {
    /// Differentiable alternative to `subscript.modify`, which is not yet supported by AD.
    /// https://github.com/swiftlang/swift/issues/55256
    @differentiable(reverse where Element: Differentiable)
    @inlinable
    public mutating func update(at index: Int, with newValue: Element) {
        self[index] = newValue
    }
}

// MARK: - VJPs

extension DifferentiableArray where Element: Differentiable {
    @inlinable
    @derivative(of: subscript)
    func _vjpSubscript(index: Int) -> (
        value: Element,
        pullback: (Element.TangentVector) -> TangentVector
    ) {
        let n = _storage.count
        return (self[index], { v in
            .init(.oneHot(index: index, value: v, count: n))
        })
    }

    @inlinable
    @derivative(of: init(repeating:count:))
    static func _vjpInit(repeating repeatedValue: Element, count: Int) -> (
        value: DifferentiableArray<Element>,
        pullback: (TangentVector) -> Element.TangentVector
    ) {
        (
            value: .init(repeating: repeatedValue, count: count),
            pullback: { v in
                switch v.storage {
                case .zero:
                    return .zero
                case .oneHot(_, let value, _):
                    return value
                case .full(let arr):
                    return arr.reduce(.zero, +)
                }
            }
        )
    }

    @derivative(of: update(at:with:))
    @inlinable
    public mutating func _vjpUpdate(
        at index: Int,
        with newValue: Element
    ) -> (value: Void, pullback: (inout TangentVector) -> Element.TangentVector) {
        update(at: index, with: newValue)
        return ((), { tangentVector in
            switch tangentVector.storage {
            case .zero:
                return .zero
            case .oneHot(let i, let v, _):
                if i == index {
                    tangentVector = .init(.zero)
                    return v
                } else {
                    return .zero
                }
            case .full(var arr):
                let dElement = arr[index]
                arr[index] = .zero
                tangentVector = .init(.full(arr))
                return dElement
            }
        })
    }
}

#endif
