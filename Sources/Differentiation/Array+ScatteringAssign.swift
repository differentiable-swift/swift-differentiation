import _Differentiation

extension Array where Element: Differentiable, Element.TangentVector == Element {
    /// Writes `values[j]` to `self[indices[j]]` for every `j`. Duplicate indices are last-write-wins
    @inlinable
    @differentiable(reverse, wrt: (self, values))
    public mutating func scatteringAssign<C>(
        at indices: some RandomAccessCollection<Index>,
        values: C
    ) where
        C: DifferentiableCollection,
        C.Element == Element
    {
        precondition(indices.count == values.count, "Mismatched indices and values length, \(indices.count) vs \(values.count)")
        for (index, value) in zip(indices, values) {
            self[index] = value
        }
    }

    /// The pullback zeroes the `self`-cotangent at every written slot. The prior value never
    /// reached the output, so there's no gradient flowing back. It gathers those same slots
    /// as the `values` cotangent. One closure captures `(indices, selfCount)` so no per-element
    /// pullback storage.
    ///
    /// The gather runs back-to-front so that duplicate indices match the forward pass's
    /// last-write-wins behaviour: the last write to a slot takes that slot's cotangent and zeroes
    /// it, so earlier writes to the same slot correctly receive zero.
    @inlinable
    @derivative(of: scatteringAssign, wrt: (self, values))
    public mutating func _vjpScatteringAssign<C>(
        at indices: some RandomAccessCollection<Index>,
        values: C
    ) -> (
        value: Void,
        pullback: (inout TangentVector) -> C.TangentVector
    ) where
        C: DifferentiableCollection,
        C.Element == Element
    {
        let selfCount = self.count
        scatteringAssign(at: indices, values: values)
        return ((), { tv in
            // The incoming tangent is either the zero tangent (empty base), meaning scatteringAssign's
            // output didn't contribute and the source tangent stays zero, or it has exactly
            // `self.count` elements.
            if tv.base.isEmpty {
                return .zero
            }

            precondition(tv.base.count == selfCount, "Incoming tangent has \(tv.base.count) elements, expected \(selfCount)")

            // The walk has to run back-to-front, but `C.TangentVector` can only be built
            // front-to-back, so the cotangents land in a scratch buffer first and move into the
            // tangent in one forward pass.
            let count = indices.count
            let scratch = UnsafeMutableBufferPointer<C.TangentVector.Element>.allocate(capacity: count)
            defer { scratch.deallocate() }

            var j = count
            var cursor = indices.endIndex
            while j > 0 {
                j -= 1
                indices.formIndex(before: &cursor)
                let index = indices[cursor]
                scratch.initializeElement(at: j, to: tv.base[index])
                // Sever the self-cotangent at the overwritten slot: its prior value never reached
                // the output, so no gradient may flow back into it. Zeroing as we walk backwards
                // also gives any earlier duplicate write to this slot a zero cotangent, matching
                // the forward pass's last-write-wins.
                tv.base[index] = .zero
            }
            return C.TangentVector.building(count: count) { scratch.moveElement(from: $0) }
        })
    }
}
