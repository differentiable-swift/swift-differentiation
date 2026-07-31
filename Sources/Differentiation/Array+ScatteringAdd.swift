import _Differentiation

extension Array where Element: Differentiable, Element.TangentVector == Element {
    /// Adds `values[j]` to `self[indices[j]]` for every `j`. Duplicate indices accumulate.
    @inlinable
    @differentiable(reverse, wrt: (self, values))
    public mutating func scatteringAdd(
        at indices: some RandomAccessCollection<Index>,
        values: [Element]
    ) {
        precondition(indices.count == values.count, "Mismatched indices and values length, \(indices.count) vs \(values.count)")
        for (index, value) in zip(indices, values) {
            self[index] += value
        }
    }

    /// The pullback leaves the `self`-cotangent unchanged (identity on the output tangent,
    /// since scatter is read-modify-write, not overwrite) and produces the `values`
    /// cotangent by gathering the inout tangent at `indices`. One closure captures
    /// `(indices, values.count, self.count)` — no per-element pullback storage.
    @inlinable
    @derivative(of: scatteringAdd, wrt: (self, values))
    public mutating func _vjpScatteringAdd(
        at indices: some RandomAccessCollection<Index>,
        values: [Element]
    ) -> (
        value: Void,
        pullback: (inout TangentVector) -> [Element].TangentVector
    ) {
        let selfCount = self.count
        scatteringAdd(at: indices, values: values)
        return ((), { tv in
            // The incoming tangent is either the zero tangent (empty base) meaning scatteringAdd's output didn't contribute.
            // So the source tangent either stays zero, or it has exactly `self.count` elements.
            if tv.base.isEmpty {
                return .zero
            }

            precondition(tv.base.count == selfCount, "Incoming tangent has \(tv.base.count) elements, expected \(selfCount)")

            return TangentVector(tv.base.gather(at: indices))
        })
    }
}
