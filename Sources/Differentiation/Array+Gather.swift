import _Differentiation

extension Array where Element: Differentiable, Element.TangentVector == Element {
    /// Reads `self[indices[i]]` for every `i`. Output length is `indices.count`.
    @inlinable
    @differentiable(reverse, wrt: self)
    public func gather(at indices: some RandomAccessCollection<Index>) -> [Element] {
        Array(unsafeUninitializedCapacity: indices.count) { buffer, initializedCount in
            for (i, index) in indices.enumerated() {
                buffer.initializeElement(at: i, to: self[index])
            }
            initializedCount = indices.count
        }
    }

    /// A custom VJP for `gather` that allocates a single pullback closure that captures `(indices, sourceCount)`
    /// and scatters the output tangent back into the source's tangent — no per-element
    /// pullback storage, regardless of `indices.count`.
    @inlinable
    @derivative(of: gather, wrt: self)
    public func _vjpGather(at indices: some RandomAccessCollection<Index>) -> (
        value: [Element],
        pullback: ([Element].TangentVector) -> [Element].TangentVector
    ) {
        let sourceCount = self.count
        return (
            value: self.gather(at: indices),
            pullback: { v in
                // The incoming tangent is either the zero tangent (empty base), meaning gather's output
                // didn't contribute and the source tangent stays zero, or it has exactly `indices.count`
                // elements (gather's output length) to scatter back into the source.
                if v.base.isEmpty {
                    return .zero
                }
                precondition(
                    v.base.count == indices.count,
                    "gather pullback received a tangent of length \(v.base.count), expected \(indices.count)"
                )

                var dBase = [Element].TangentVector(repeating: .zero, count: sourceCount)
                dBase.base.scatteringAdd(at: indices, values: v.base)

                return dBase
            }
        )
    }
}
