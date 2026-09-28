import _Differentiation

/// A lazy, non-allocating view of `base` read through `indices`: `self[i] == base[indices[i]]`.
///
/// Conforms to `DifferentiableCollection`, so it can be fed straight into the elementwise
/// operators (`.-`, `.*`, `./`, …) without ever materializing the gathered `[Double]`. In a
/// forward-only run this removes the gather's output allocation entirely; under reverse-mode AD
/// the forward view is still allocation-free and only the pullback scatters cotangents back.
///
/// Produced by `Array.gatherView(at:)`, whose derivative scatters the view's cotangent into the
/// source — the same VJP as the materializing `gather`, just fed from a lazy forward value.
public struct GatherView<Element>: DifferentiableCollection where Element: Differentiable {
    public typealias Index = Int
    public typealias TangentVector = [Element].TangentVector

    @usableFromInline var base: [Element]
    @usableFromInline let indices: [Int]

    @inlinable
    init(base: [Element], indices: [Int]) {
        self.base = base
        self.indices = indices
    }

    @inlinable public var startIndex: Int { 0 }
    @inlinable public var endIndex: Int { self.indices.count }
    @inlinable public func index(after i: Int) -> Int { i + 1 }

    @inlinable
    public subscript(position: Int) -> Element {
        self.base[self.indices[position]]
    }

    /// `Differentiable` requires `move(by:)`, but a `GatherView` is a read-only projection of
    /// its source, not an independent point: scattering an offset back through `indices` is only
    /// well-defined for distinct indices, and gathers here reuse nodes (e.g. `conductionEdgesA/B`).
    /// The view exists purely as a forward-only intermediate consumed by the elementwise operators,
    /// so reverse-mode pullback evaluation never calls this. Trap rather than silently mis-move if
    /// some future (e.g. forward-mode) transform ever does.
    @inlinable
    public mutating func move(by _: TangentVector) {
        preconditionFailure("GatherView.move(by:) is not supported — it is a forward-only projection view")
    }
}

extension Array where Element: Differentiable {
    /// Lazy counterpart of `gather(at:)`: returns a non-allocating `GatherView` instead of a
    /// fresh `[Double]`. Differentiable w.r.t. `self`; the pullback scatters the view's
    /// cotangent back into the source's tangent.
    @inlinable
    @differentiable(reverse, wrt: self)
    public func gatherView(at indices: [Int]) -> GatherView<Element> {
        GatherView(base: self, indices: indices)
    }

    @inlinable
    @derivative(of: gatherView, wrt: self)
    public func _vjpGatherView(at indices: [Int]) -> (
        value: GatherView<Element>,
        pullback: (GatherView<Element>.TangentVector) -> [Element].TangentVector
    ) {
        let sourceCount = self.count
        return (
            value: GatherView(base: self, indices: indices),
            pullback: { dView in
                if dView.base.isEmpty { return .zero }
                var dBase = [Element].TangentVector(repeating: .zero, count: sourceCount)
                dBase.base.scatteringAdd(at: indices, values: dView.base)
                return dBase
            }
        )
    }
}
