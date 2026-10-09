import _Differentiation

/// A lazy, non-allocating view of `base` read through `indices`: `self[i] == base[indices[i]]`.
///
/// Where `Array.gather(at:)` materializes a fresh array, a `GatheringView` stores only the base
/// and the index array and resolves each read on demand. In a forward-only run that removes the
/// gather's output allocation entirely; under reverse-mode AD the forward view is still
/// allocation-free and only the pullback scatters cotangents back into the source.
///
/// When `Base` is a differentiable collection the view conforms to `DifferentiableCollection`, so
/// it can be fed straight into `differentiableZipWith` and friends without ever materializing the
/// gathered elements.
///
/// Produced by `Array.gatheringView(at:)`, whose derivative scatters the view's cotangent into the
/// source — the same VJP as the materializing `gather`, just fed from a lazy forward value.
///
/// The view's own index space is `0 ..< indices.count`, independent of both the base's indices and
/// the values stored in `indices`. Out-of-range gathering indices are not validated up front; they
/// trap on the read that first resolves them.
public struct GatheringView<Base>: RandomAccessCollection where Base: RandomAccessCollection, Base.Index == Int {
    public typealias Index = Int
    public typealias Indices = Range<Int>
    public typealias Element = Base.Element

    @usableFromInline
    let base: Base
    /// The positions in `base` that this view reads, in view order. Distinct from `indices`, which
    /// is the view's own index space as required by `Collection`.
    @usableFromInline
    let gatheringIndices: [Base.Index]
    @inlinable
    public var indices: Indices { gatheringIndices.indices }

    @inlinable
    init(base: Base, indices: [Base.Index]) {
        self.base = base
        self.gatheringIndices = indices
    }

    @inlinable
    public var startIndex: Int { gatheringIndices.startIndex }
    @inlinable
    public var endIndex: Int { gatheringIndices.endIndex }
    @inlinable public func index(after i: Int) -> Int { gatheringIndices.index(after: i) }

    @inlinable
    public subscript(position: Int) -> Base.Element {
        self.base[self.gatheringIndices[position]]
    }
}

extension GatheringView: Differentiable where Base: Differentiable {
    public typealias TangentVector = Base.TangentVector

    /// `Differentiable` requires `move(by:)`, but a `GatheringView` is a read-only projection of
    /// its source, not an independent point: scattering an offset back through `indices` is only
    /// well-defined for distinct indices, and a gather is free to read the same source element
    /// more than once. The view exists purely as a forward-only intermediate consumed by the
    /// elementwise operators, so reverse-mode pullback evaluation never calls this. Trap rather
    /// than silently mis-move if some future (e.g. forward-mode) transform ever does.
    @inlinable
    public mutating func move(by _: TangentVector) {
        preconditionFailure("GatheringView.move(by:) is not supported — it is a forward-only projection view")
    }
}

extension GatheringView: DifferentiableCollection where Base: Differentiable, Base.TangentVector: DifferentiableCollectionTangentVector,
    Base.Element.TangentVector == Base.TangentVector.Element, Base.Element: Differentiable {}

extension Array {
    /// Lazy counterpart of `gather(at:)`: returns a non-allocating `GatheringView` instead of a
    /// fresh `[Element]`. Differentiable w.r.t. `self` when `Element` is; the pullback scatters
    /// the view's cotangent back into the source's tangent.
    ///
    /// Unlike `gather(at:)`, this does not require `Element.TangentVector == Element`.
    @inlinable
    @differentiable(reverse, wrt: self where Element: Differentiable)
    public func gatheringView(at indices: [Int]) -> GatheringView<Self> {
        GatheringView(base: self, indices: indices)
    }
}

extension Array where Element: Differentiable {
    /// A custom VJP for `gatheringView` that allocates a single pullback closure capturing
    /// `(indices, sourceCount)` and scatters the view's tangent back into the source's tangent —
    /// no per-element pullback storage, regardless of `indices.count`.
    @inlinable
    @derivative(of: gatheringView, wrt: self)
    public func _vjpGatheringView(at indices: [Int]) -> (
        value: GatheringView<Self>,
        pullback: (GatheringView<Self>.TangentVector) -> Self.TangentVector
    ) {
        let sourceCount = self.count
        return (
            value: GatheringView(base: self, indices: indices),
            pullback: { dView in
                // The incoming tangent is either the zero tangent (empty base), meaning the view
                // didn't contribute and the source tangent stays zero, or it has exactly
                // `indices.count` elements (the view's length) to scatter back into the source.
                if dView.base.isEmpty { return .zero }
                precondition(
                    dView.base.count == indices.count,
                    "gatheringView pullback received a tangent of length \(dView.base.count), expected \(indices.count)"
                )

                var dBase = [Element].TangentVector(repeating: .zero, count: sourceCount)
                dBase.base.scatteringAdd(at: indices, values: dView.base)

                return dBase
            }
        )
    }
}
