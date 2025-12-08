/// Creates a sequence of pairs built out of two underlying sequences.
///
/// In the `Zip2Sequence` instance returned by this function, the elements of
/// the *i*th pair are the *i*th elements of each underlying sequence. The
/// following example uses the `zip(_:_:)` function to iterate over an array
/// of strings and a countable range at the same time:
///
///     let words = ["one", "two", "three", "four"]
///     let numbers = 1...4
///
///     for (word, number) in zip(words, numbers) {
///         print("\(word): \(number)")
///     }
///     // Prints "one: 1"
///     // Prints "two: 2"
///     // Prints "three: 3"
///     // Prints "four: 4"
///
/// If the two sequences passed to `zip(_:_:)` are different lengths, the
/// resulting sequence is the same length as the shorter sequence. In this
/// example, the resulting array is the same length as `words`:
///
///     let naturalNumbers = 1...Int.max
///     let zipped = Array(zip(words, naturalNumbers))
///     // zipped == [("one", 1), ("two", 2), ("three", 3), ("four", 4)]
///
/// - Parameters:
///   - sequence1: The first sequence or collection to zip.
///   - sequence2: The second sequence or collection to zip.
/// - Returns: A sequence of tuple pairs, where the elements of each pair are
///   corresponding elements of `sequence1` and `sequence2`.
@inlinable // generic-performance
public func differentiableZip<Sequence1, Sequence2>(
    _ sequence1: Sequence1, _ sequence2: Sequence2
) -> Zip2SequenceDifferentiable<Sequence1, Sequence2> {
    Zip2SequenceDifferentiable(sequence1, sequence2)
}

/// A sequence of pairs built out of two underlying sequences.
///
/// In a `Zip2Sequence` instance, the elements of the *i*th pair are the *i*th
/// elements of each underlying sequence. To create a `Zip2Sequence` instance,
/// use the `zip(_:_:)` function.
///
/// The following example uses the `zip(_:_:)` function to iterate over an
/// array of strings and a countable range at the same time:
///
///     let words = ["one", "two", "three", "four"]
///     let numbers = 1...4
///
///     for (word, number) in zip(words, numbers) {
///         print("\(word): \(number)")
///     }
///     // Prints "one: 1"
///     // Prints "two: 2"
///     // Prints "three: 3"
///     // Prints "four: 4"
@frozen // generic-performance
public struct Zip2SequenceDifferentiable<Sequence1: Sequence, Sequence2: Sequence> {
    @usableFromInline // generic-performance
    internal var _sequence1: Sequence1
    @usableFromInline // generic-performance
    internal var _sequence2: Sequence2

    /// Creates an instance that makes pairs of elements from `sequence1` and
    /// `sequence2`.
    @inlinable // generic-performance
    internal init(_ sequence1: Sequence1, _ sequence2: Sequence2) {
        (_sequence1, _sequence2) = (sequence1, sequence2)
    }
}

extension Zip2SequenceDifferentiable {
    /// An iterator for `Zip2Sequence`.
    @frozen // generic-performance
    public struct Iterator {
        @usableFromInline // generic-performance
        internal var _baseStream1: Sequence1.Iterator
        @usableFromInline // generic-performance
        internal var _baseStream2: Sequence2.Iterator
        @usableFromInline // generic-performance
        internal var _reachedEnd: Bool = false

        /// Creates an instance around a pair of underlying iterators.
        @inlinable // generic-performance
        internal init(
            _ iterator1: Sequence1.Iterator,
            _ iterator2: Sequence2.Iterator
        ) {
            (_baseStream1, _baseStream2) = (iterator1, iterator2)
        }
    }
}

extension Zip2SequenceDifferentiable.Iterator: IteratorProtocol {
    /// The type of element returned by `next()`.
    public typealias Element = (Sequence1.Element, Sequence2.Element)

    /// Advances to the next element and returns it, or `nil` if no next element
    /// exists.
    ///
    /// Once `nil` has been returned, all subsequent calls return `nil`.
    @inlinable // generic-performance
    public mutating func next() -> Element? {
        // The next() function needs to track if it has reached the end.  If we
        // didn't, and the first sequence is longer than the second, then when we
        // have already exhausted the second sequence, on every subsequent call to
        // next() we would consume and discard one additional element from the
        // first sequence, even though next() had already returned nil.

        if _reachedEnd {
            return nil
        }

        guard let element1 = _baseStream1.next(),
              let element2 = _baseStream2.next() else
        {
            _reachedEnd = true
            return nil
        }

        return (element1, element2)
    }
}

extension Zip2SequenceDifferentiable: Sequence {
    public typealias Element = (Sequence1.Element, Sequence2.Element)

    /// Returns an iterator over the elements of this sequence.
    @inlinable // generic-performance
    public __consuming func makeIterator() -> Iterator {
        Iterator(
            _sequence1.makeIterator(),
            _sequence2.makeIterator()
        )
    }

    @inlinable // generic-performance
    public var underestimatedCount: Int {
        Swift.min(
            _sequence1.underestimatedCount,
            _sequence2.underestimatedCount
        )
    }
}

extension Zip2SequenceDifferentiable: Sendable where Sequence1: Sendable,
    Sequence2: Sendable {}
extension Zip2SequenceDifferentiable.Iterator: Sendable where Sequence1.Iterator: Sendable,
    Sequence2.Iterator: Sendable {}

// MARK: Differentiable

#if canImport(_Differentiation)

import _Differentiation

@derivative(of: differentiableZip)
@inlinable
public func _vjpDifferentiableZip<Sequence1, Sequence2>(
    _ sequence1: Sequence1, _ sequence2: Sequence2
) -> (
    value: Zip2SequenceDifferentiable<Sequence1, Sequence2>,
    pullback: (Zip2SequenceDifferentiable<Sequence1, Sequence2>.TangentVector) -> (Sequence1.TangentVector, Sequence2.TangentVector)
) where
    Sequence1: Differentiable,
    Sequence2: Differentiable,
    Sequence1.Element: Differentiable,
    Sequence2.Element: Differentiable,
    Sequence1.TangentVector: DifferentiableSequence, // at least needs to be a sequence to have an Element associatedtype
    Sequence2.TangentVector: DifferentiableSequence, // at least needs to be a sequence to have an Element associatedtype
    Sequence1.TangentVector.Element == Sequence1.Element.TangentVector,
    Sequence2.TangentVector.Element == Sequence2.Element.TangentVector
{
    (
        value: differentiableZip(sequence1, sequence2),
        pullback: { v in
            (v.sequence1, v.sequence2)
        }
    )
}

extension Zip2SequenceDifferentiable: Differentiable where
    Sequence1: Differentiable,
    Sequence2: Differentiable,
    Sequence1.Element: Differentiable,
    Sequence2.Element: Differentiable,
    Sequence1.TangentVector: DifferentiableSequence, // at least needs to be a sequence to have an Element associatedtype
    Sequence2.TangentVector: DifferentiableSequence, // at least needs to be a sequence to have an Element associatedtype
    Sequence1.TangentVector.Element == Sequence1.Element.TangentVector,
    Sequence2.TangentVector.Element == Sequence2.Element.TangentVector
{
    @inlinable
    public mutating func move(by offset: TangentVector) {
        _sequence1.move(by: offset.sequence1)
        _sequence2.move(by: offset.sequence2)
    }

    @inlinable
    public func differentiableMap<Result: Differentiable>(_ transform: @differentiable(reverse) (Sequence1.Element, Sequence2.Element)
        -> Result
    ) -> [Result] {
        self.map(transform)
    }

    @derivative(of: differentiableMap)
    @inlinable
    public func _vjpDifferentiableMap<Result: Differentiable>(_ transform: @differentiable(reverse) (Sequence1.Element, Sequence2.Element)
        -> Result
    ) -> (value: [Result], pullback: ([Result].TangentVector) -> Zip2SequenceDifferentiable.TangentVector) {
        var results: [Result] = []
        results.reserveCapacity(self.underestimatedCount)
        var pullbacks: [(Result.TangentVector) -> (Sequence1.Element.TangentVector, Sequence2.Element.TangentVector)] = []
        results.reserveCapacity(self.underestimatedCount)

        for pair in self {
            let (value, pullback) = valueWithPullback(at: pair.0, pair.1, of: transform)
            results.append(value)
            pullbacks.append(pullback)
        }

        return (
            value: results,
            pullback: { v in
                var results1 = Sequence1.TangentVector()
                results1.reserveCapacity(v.count)
                var results2 = Sequence2.TangentVector()
                results2.reserveCapacity(v.count)

                // thoughts should Repeated tangentvector be a collection instead of also value + count alone? Will that make things easier?
                // we can't do append on a Repeated object so we either have to generate it from a single scope or not at all
                for (tangentElement, pullback) in zip(v, pullbacks) {
                    let (result1, result2) = pullback(tangentElement)
                    results1.appendContribution(of: result1)
                    results2.appendContribution(of: result2)
                }

                return TangentVector(results1, results2)
            }
        )
    }
}

extension Zip2SequenceDifferentiable {
    public struct TangentVector: Sequence & Differentiable & AdditiveArithmetic where Sequence1: Differentiable, Sequence2: Differentiable,
        Sequence1.TangentVector: Sequence, Sequence2.TangentVector: Sequence
    {
        public typealias TangentVector = Self
        public typealias Element = (Sequence1.TangentVector.Element, Sequence2.TangentVector.Element)

        @usableFromInline
        var sequence1: Sequence1.TangentVector
        @usableFromInline
        var sequence2: Sequence2.TangentVector

        @inlinable
        init(_ sequence1: Sequence1.TangentVector, _ sequence2: Sequence2.TangentVector) {
            self.sequence1 = sequence1
            self.sequence2 = sequence2
        }

        @inlinable
        public __consuming func makeIterator() -> Iterator {
            Iterator(baseStream1: sequence1.makeIterator(), baseStream2: sequence2.makeIterator())
        }

        @inlinable // generic-performance
        public var underestimatedCount: Int {
            Swift.min(
                sequence1.underestimatedCount,
                sequence2.underestimatedCount
            )
        }

        public struct Iterator: IteratorProtocol {
            public typealias Element = (Sequence1.TangentVector.Element, Sequence2.TangentVector.Element)

            @usableFromInline
            var baseStream1: Sequence1.TangentVector.Iterator
            @usableFromInline
            var baseStream2: Sequence2.TangentVector.Iterator
            @usableFromInline
            var reachedEnd: Bool = false

            @inlinable
            init(baseStream1: Sequence1.TangentVector.Iterator, baseStream2: Sequence2.TangentVector.Iterator) {
                self.baseStream1 = baseStream1
                self.baseStream2 = baseStream2
            }

            @inlinable
            public mutating func next() -> (Sequence1.TangentVector.Element, Sequence2.TangentVector.Element)? {
                if reachedEnd {
                    return nil
                }

                guard let element1 = baseStream1.next(),
                      let element2 = baseStream2.next() else
                {
                    reachedEnd = true
                    return nil
                }

                return (element1, element2)
            }
        }
    }
}

#endif
