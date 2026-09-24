import _Differentiation

extension Array where Element: Differentiable, Element.TangentVector == Element {
    /// Writes `values[j]` to `self[indices[j]]` for every `j`. Duplicate indices are last-write-wins
    @inlinable
    @differentiable(reverse, wrt: (self, values))
    public mutating func scatteringAssign(
        at indices: some RandomAccessCollection<Index>,
        values: [Element]
    ) {
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
    public mutating func _vjpScatteringAssign(
        at indices: some RandomAccessCollection<Index>,
        values: [Element]
    ) -> (
        value: Void,
        pullback: (inout TangentVector) -> [Element].TangentVector
    ) {
        let selfCount = self.count
        scatteringAssign(at: indices, values: values)
        return ((), { tv in
            // The incoming tangent is either the zero tangent (empty base) meaning scatteringAssign's
            // output didn't contribute. So the source tangent either stays zero, or it has exactly
            // `self.count` elements.
            if tv.base.isEmpty {
                return .zero
            }

            precondition(tv.base.count == selfCount, "Incoming tangent has \(tv.base.count) elements, expected \(selfCount)")

            var dValues = [Element].TangentVector(repeating: .zero, count: indices.count)
            var j = indices.count
            for index in indices.reversed() {
                j -= 1
                dValues.base[j] = tv.base[index]
                // Sever the self-cotangent at the overwritten slot: its prior value never reached
                // the output, so no gradient may flow back into it. Zeroing as we walk backwards
                // also gives any earlier duplicate write to this slot a zero cotangent, matching
                // the forward pass's last-write-wins.
                tv.base[index] = .zero
            }
            return dValues
        })
    }
}
