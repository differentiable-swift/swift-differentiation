import _Differentiation

extension Array where Element: Differentiable, Element.TangentVector == Element {
    /// Adds `values[j]` to `self[indices[j]]` for every `j`. Duplicate indices accumulate.
    @inlinable
    @differentiable(reverse, wrt: (self, values))
    public mutating func scatteringAdd<C>(
        at indices: some RandomAccessCollection<Index>,
        values: C
    ) where
        C: DifferentiableCollection,
        C.Element == Element
    {
        precondition(indices.count == values.count, "Mismatched indices and values length, \(indices.count) vs \(values.count)")
        // Index-based rather than `zip(indices, values)`: a `Zip2Sequence` over two generic
        // collections carries two generic iterators and a per-element end-of-sequence check, and
        // measured roughly two thirds of the equivalent cost in `scatteringAssign`'s forward.
        var indexCursor = indices.startIndex
        var valueCursor = values.startIndex
        // Bounded by the (precondition-checked) count rather than by comparing against
        // `endIndex`, so the loop cannot outrun `values` whatever the two collections do.
        for _ in 0 ..< indices.count {
            self[indices[indexCursor]] += values[valueCursor]
            indices.formIndex(after: &indexCursor)
            values.formIndex(after: &valueCursor)
        }
    }

    /// The pullback leaves the `self`-cotangent unchanged (identity on the output tangent,
    /// since scatter is read-modify-write, not overwrite) and produces the `values`
    /// cotangent by gathering the inout tangent at `indices`. One closure captures
    /// `(indices, values.count, self.count)` — no per-element pullback storage.
    @inlinable
    @derivative(of: scatteringAdd, wrt: (self, values))
    public mutating func _vjpScatteringAdd<C>(
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
        scatteringAdd(at: indices, values: values)
        return ((), { tv in
            // The incoming tangent is either the zero tangent (empty base) meaning scatteringAdd's output didn't contribute.
            // So the source tangent either stays zero, or it has exactly `self.count` elements.
            if tv.base.isEmpty {
                return .zero
            }

            precondition(tv.base.count == selfCount, "Incoming tangent has \(tv.base.count) elements, expected \(selfCount)")

            return C.TangentVector.building(count: indices.count) { j in
                tv.base[indices[indices.index(indices.startIndex, offsetBy: j)]]
            }
        })
    }
}
