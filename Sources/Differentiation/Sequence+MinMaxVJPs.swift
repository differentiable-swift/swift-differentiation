#if canImport(_Differentiation)

import _Differentiation

extension Sequence where
    Self: Collection, // we constrain to conform to collection cause otherwise we can't access any values by index
    Self: Differentiable,
    Self.TangentVector: RangeReplaceableCollection, // we constrain the tangentvector to be able to create a value and write to it
    Self.TangentVector.Element == Element.TangentVector,
    Element: Differentiable,
    Element: Comparable
{
    // Match Self.Index  with Self.TangentVector index so we can use them across both types.
    // The reason we are doing the where clause here rather than at the extension declaration
    // level is because of the DocC crash: https://github.com/swiftlang/swift/issues/75258
    /// To differentiate ``Swift/Sequence/max``
    @derivative(of: max)
    @inlinable
    public func _vjpMax() -> (
        value: Element?,
        pullback: (Element?.TangentVector) -> (Self.TangentVector)
    ) where Self.Index == Self.TangentVector.Index {
        let index = withoutDerivative(at: self.indices.max { self[$0] < self[$1] }) // we grab the index of the element with the max value
        return (
            value: index.map { self[$0] }, // if the index is nil, we return nil otherwise we grab the value at the index
            pullback: { vector in
                var dSelf = Self
                    .TangentVector(
                        repeating: .zero,
                        count: self
                            .count
                    ) // we create a zero tangentvector we need `RangeReplaceableCollection` conformance in order to do this
                if let vectorValue = vector.value,
                   let index = index
                {
                    // if an index was found and our tangentvector's value is non nil we set the value at index of our tangentvector to the
                    // provided tangentvector value
                    dSelf
                        .replaceSubrange(
                            index ..< dSelf.index(after: index),
                            with: [vectorValue]
                        ) // we use `RangeReplaceableCollection`'s method here in order to not have to also constrain our TangentVector to
                    // `MutableCollection`
                }
                return dSelf // return the tangentvector
            }
        )
    }

    // Match Self.Index  with Self.TangentVector index so we can use them across both types.
    // The reason we are doing the where clause here rather than at the extension declaration
    // level is because of the DocC crash: https://github.com/swiftlang/swift/issues/75258
    /// To differentiate ``Swift/Sequence/min``
    @derivative(of: min)
    @inlinable
    public func _vjpMin() -> (
        value: Element?,
        pullback: (Element?.TangentVector) -> (Self.TangentVector)
    ) where Self.Index == Self.TangentVector.Index {
        let index = withoutDerivative(at: self.indices.min { self[$0] < self[$1] }) // we grab the index of the element with the max value
        return (
            value: index.map { self[$0] }, // if the index is nil, we return nil otherwise we grab the value at the index
            pullback: { vector in
                var dSelf = Self.TangentVector(repeating: .zero, count: self.count) // we create a zero tangentvector
                if let vectorValue = vector.value,
                   let index = index
                {
                    // if an index was found and our tangentvector's value is non nil we set the value at index of our tangentvector to the
                    // provided tangentvector value
                    dSelf.replaceSubrange(index ..< dSelf.index(after: index), with: [vectorValue])
                }
                return dSelf // return the tangentvector
            }
        )
    }
}

#endif
