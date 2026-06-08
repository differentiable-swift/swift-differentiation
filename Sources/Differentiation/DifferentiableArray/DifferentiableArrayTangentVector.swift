#if canImport(_Differentiation)

import _Differentiation

// MARK: - TangentVector type
//
// Following the ContiguousArray.DifferentiableView pattern:
//   DifferentiableArray<E>: Differentiable with TangentVector = DifferentiableArrayTangentVector<E.TangentVector>
//
// The generic parameter `Element` here IS the element tangent type (e.g. Float for DifferentiableArray<Float>).
// This ensures TangentVector.TangentVector == TangentVector via:
//   DifferentiableArrayTangentVector<E>.TangentVector = DifferentiableArrayTangentVector<E.TangentVector>
//   and for E: Differentiable, E.TangentVector.TangentVector == E.TangentVector ✓

/// Enum-based tangent vector for `DifferentiableArray`.
///
/// `Element` is the tangent type of each array element (e.g. `Float` for `DifferentiableArray<Float>`).
/// Three storage cases avoid full-array allocation for common AD patterns:
/// - `.zero` — additive identity, no allocation
/// - `.oneHot` — single nonzero entry (used in subscript pullbacks instead of allocating a zero-padded array)
/// - `.full` — fully materialized element-wise tangents
@frozen
public struct DifferentiableArrayTangentVector<Element: AdditiveArithmetic> {
    @frozen
    public enum Storage {
        case zero
        case oneHot(index: Int, value: Element, count: Int)
        case full([Element])
    }

    public var storage: Storage

    @inlinable
    public init(_ storage: Storage) {
        self.storage = storage
    }
}

// MARK: - Equatable

extension DifferentiableArrayTangentVector: Equatable where Element: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs.storage, rhs.storage) {
        case (.zero, .zero):
            return true
        case (.oneHot(let i1, let v1, let n1), .oneHot(let i2, let v2, let n2)):
            return i1 == i2 && v1 == v2 && n1 == n2
        case (.full(let l), .full(let r)):
            return l == r
        default:
            return false
        }
    }
}

// MARK: - CustomStringConvertible

extension DifferentiableArrayTangentVector: CustomStringConvertible {
    public var description: String {
        switch storage {
        case .zero: return ".zero"
        case .oneHot(let i, let v, let n): return ".oneHot(\(i), \(v), count:\(n))"
        case .full(let arr): return ".full(\(arr))"
        }
    }
}

// MARK: - AdditiveArithmetic

extension DifferentiableArrayTangentVector: AdditiveArithmetic {

    @inlinable
    public static var zero: Self { .init(.zero) }

    @inlinable
    public static func + (lhs: Self, rhs: Self) -> Self {
        switch (lhs.storage, rhs.storage) {
        case (.zero, _):
            return rhs
        case (_, .zero):
            return lhs
        case (.oneHot(let i, let lv, let ln), .oneHot(let j, let rv, let rn)):
            precondition(ln == rn)
            if i == j {
                return .init(.oneHot(index: i, value: lv + rv, count: ln))
            } else {
                var arr = [Element](repeating: .zero, count: ln)
                arr[i] = lv
                arr[j] = rv
                return .init(.full(arr))
            }
        case (.oneHot(let i, let v, let n), .full(var arr)):
            precondition(n == arr.count)
            arr[i] = arr[i] + v
            return .init(.full(arr))
        case (.full(var arr), .oneHot(let i, let v, let n)):
            precondition(arr.count == n)
            arr[i] = arr[i] + v
            return .init(.full(arr))
        case (.full(let l), .full(let r)):
            precondition(l.count == r.count, "Count mismatch: \(l.count) and \(r.count)")
            return .init(.full(zip(l, r).map(+)))
        }
    }

    @inlinable
    public static func - (lhs: Self, rhs: Self) -> Self {
        switch (lhs.storage, rhs.storage) {
        case (_, .zero):
            return lhs
        case (.zero, .oneHot(let i, let rv, let n)):
            return .init(.oneHot(index: i, value: .zero - rv, count: n))
        case (.zero, .full(let arr)):
            return .init(.full(arr.map { .zero - $0 }))
        case (.oneHot(let i, let lv, let ln), .oneHot(let j, let rv, let rn)):
            precondition(ln == rn)
            if i == j {
                return .init(.oneHot(index: i, value: lv - rv, count: ln))
            } else {
                var arr = [Element](repeating: .zero, count: ln)
                arr[i] = lv
                arr[j] = .zero - rv
                return .init(.full(arr))
            }
        case (.oneHot(let i, let lv, let ln), .full(let rarr)):
            precondition(ln == rarr.count)
            // result[i] = lv - rarr[i]; result[j≠i] = .zero - rarr[j]
            var result = rarr.map { .zero - $0 }
            result[i] = result[i] + lv
            return .init(.full(result))
        case (.full(var arr), .oneHot(let i, let rv, let rn)):
            precondition(arr.count == rn)
            arr[i] = arr[i] - rv
            return .init(.full(arr))
        case (.full(let l), .full(let r)):
            precondition(l.count == r.count, "Count mismatch: \(l.count) and \(r.count)")
            return .init(.full(zip(l, r).map(-)))
        }
    }
}

// MARK: - Differentiable
//
// DifferentiableArrayTangentVector<E>: Differentiable when E: Differentiable.
// TangentVector = DifferentiableArrayTangentVector<E.TangentVector>
// Then TangentVector.TangentVector = DifferentiableArrayTangentVector<E.TangentVector.TangentVector>
//                                  = DifferentiableArrayTangentVector<E.TangentVector>  (since E.TangentVector: Differentiable)
//                                  = TangentVector ✓

extension DifferentiableArrayTangentVector: Differentiable where Element: Differentiable {
    public typealias TangentVector = DifferentiableArrayTangentVector<Element.TangentVector>

    @inlinable
    public mutating func move(by offset: DifferentiableArrayTangentVector<Element.TangentVector>) {
        switch offset.storage {
        case .zero:
            return

        case .oneHot(let j, let t, let n):
            // t: Element.TangentVector
            switch self.storage {
            case .zero:
                var v = Element.zero
                v.move(by: t)
                self = .init(.oneHot(index: j, value: v, count: n))
            case .oneHot(let i, var v, _):
                if i == j {
                    v.move(by: t)
                    self = .init(.oneHot(index: i, value: v, count: n))
                } else {
                    var arr = [Element](repeating: .zero, count: n)
                    arr[i] = v
                    arr[j].move(by: t)
                    self = .init(.full(arr))
                }
            case .full(var arr):
                arr[j].move(by: t)
                self = .init(.full(arr))
            }

        case .full(let offsets):
            // offsets: [Element.TangentVector]
            switch self.storage {
            case .zero:
                var result = [Element](repeating: .zero, count: offsets.count)
                for i in offsets.indices { result[i].move(by: offsets[i]) }
                self = .init(.full(result))
            case .oneHot(let i, let v, let n):
                var arr = [Element](repeating: .zero, count: n)
                arr[i] = v
                for j in offsets.indices { arr[j].move(by: offsets[j]) }
                self = .init(.full(arr))
            case .full(var arr):
                for i in arr.indices { arr[i].move(by: offsets[i]) }
                self = .init(.full(arr))
            }
        }
    }
}

// MARK: - Helpers

extension DifferentiableArrayTangentVector {
    /// Materializes the tangent as a concrete array of element tangents.
    @inlinable
    public func asArray(count: Int) -> [Element] {
        switch storage {
        case .zero:
            return [Element](repeating: .zero, count: count)
        case .oneHot(let i, let v, let n):
            var arr = [Element](repeating: .zero, count: n)
            arr[i] = v
            return arr
        case .full(let arr):
            return arr
        }
    }
}

#endif
