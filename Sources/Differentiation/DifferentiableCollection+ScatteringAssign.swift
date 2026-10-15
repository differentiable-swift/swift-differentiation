import _Differentiation

extension DifferentiableCollection where
    Self: MutableCollection,
    TangentVector: MutableCollection,
    TangentVector.Index == Index,
    Element.TangentVector == Element
{
    /// Writes `values[j]` to `self[indices[j]]` for every `j`.
    ///
    /// **`indices` must contain no duplicates.** The pullback gathers each written slot's
    /// cotangent exactly once and severs it, which is only the true adjoint when every slot is
    /// written once; a repeated index would hand the same cotangent to several inputs. Enforcing
    /// Checked by `assert`, so it costs nothing in `-O`: the condition is an autoclosure that
    /// release builds never evaluate. Benchmarks and any other optimized build therefore pay
    /// nothing, while debug builds and the test suite catch a duplicate at the call that
    /// introduced it. The check sorts rather than hashing because `Index` is only guaranteed
    /// `Comparable`.
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
        assert(
            {
                let ordered = indices.sorted()
                return !zip(ordered, ordered.dropFirst()).contains { $0 == $1 }
            }(),
            "scatteringAssign requires duplicate-free indices; a repeated index makes the pullback wrong"
        )
        var indexCursor = indices.startIndex
        var valueCursor = values.startIndex
        for _ in 0 ..< indices.count {
            self[indices[indexCursor]] = values[valueCursor]
            indices.formIndex(after: &indexCursor)
            values.formIndex(after: &valueCursor)
        }
    }

    /// The pullback zeroes the `self`-cotangent at every written slot. The prior value never
    /// reached the output, so there's no gradient flowing back. It gathers those same slots
    /// as the `values` cotangent. One closure captures `(indices, selfCount)` so no per-element
    /// pullback storage.
    ///
    /// Walks front-to-back, which is the order tangents are built in, so the result needs no
    /// scratch staging. This is sound exactly because `indices` is required to be duplicate-free:
    /// each slot is read and severed once.
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
            // The incoming tangent is either the zero tangent (empty), meaning scatteringAssign's
            // output didn't contribute and the source tangent stays zero, or it has exactly
            // `self.count` elements.
            if tv.isEmpty {
                return .zero
            }

            precondition(tv.count == selfCount, "Incoming tangent has \(tv.count) elements, expected \(selfCount)")

            let count = indices.count
            var cursor = indices.startIndex
            return C.TangentVector(count: count) {
                let index = indices[cursor]
                indices.formIndex(after: &cursor)
                let gradient = tv[index]
                // Sever the self-cotangent at the written slot: its prior value never reached the
                // output, so no gradient may flow back into it.
                tv[index] = .zero
                return gradient
            }
        })
    }
}
