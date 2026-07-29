import _Differentiation

extension Array where Element: Differentiable, Element.TangentVector == Element {
    /// Reads `self[indices[i]]` for every `i`. Output length is `indices.count`.
    @inlinable
    @differentiable(reverse, wrt: self)
    public func gather<C>(at indices: C) -> [Element]
        where C: RandomAccessCollection<Int>, C.Index == Index
    {
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
    public func _vjpGather<C>(at indices: C) -> (
        value: [Element],
        pullback: ([Element].TangentVector) -> [Element].TangentVector
    ) where C: RandomAccessCollection<Index>, C.Index == Index {
        let sourceCount = self.count
        return (
            value: self.gather(at: indices),
            pullback: { v in
                var dBase = [Element].TangentVector(repeating: .zero, count: sourceCount)
                // The incoming tangent is either the zero tangent (empty base), meaning gather's output
                // didn't contribute and the source tangent stays zero, or it has exactly `indices.count`
                // elements (gather's output length) to scatter back into the source.
                if v.base.isEmpty {
                    return dBase
                }
                precondition(
                    v.base.count == indices.count,
                    "gather pullback received a tangent of length \(v.base.count), expected \(indices.count)"
                )

                dBase.base.scatteringAdd(at: indices, values: v.base)

                return dBase
            }
        )
    }
}
