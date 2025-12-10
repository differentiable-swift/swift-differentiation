enum ZipSequenceGenerator {
    static func generate(upToArity arity: Int) -> String {
        var code = """
        #if canImport(_Differentiation)
        import _Differentiation

        """
        // TODO: We should get rid of these overloads as soon as we have a variadic valueWithPullback implementation
        code += """
        public struct Pair<A: Differentiable, B: Differentiable>: Differentiable {
            @usableFromInline
            var a: A
            @usableFromInline
            var b: B

            @inlinable
            init(_ a: A, _ b: B) {
                self.a = a
                self.b = b
            }

            @derivative(of: init)
            @inlinable
            static func _vjpInit(_ a: A, _ b: B) -> (value: Pair, pullback: (Pair.TangentVector) -> (A.TangentVector, B.TangentVector)) {
                fatalError()
            }
        }

        public func valueWithPullback<T, U, V, W, R>(
          at t: T, _ u: U, _ v: V, _ w: W, of f: @differentiable(reverse) (T, U, V, W) -> R
        ) -> (value: R,
              pullback: (R.TangentVector)
                -> (T.TangentVector, U.TangentVector, V.TangentVector, W.TangentVector)) {

            let (value, pullback) = valueWithPullback(at: t, u, Pair(v, w)) { t, u, pair in 
                f(t, u, pair.a, pair.b)
            }

            return (
                value: value,
                pullback: { v in 
                    let results = pullback(v)
                    return (results.0, results.1, results.2.a, results.2.b)
                }
            )
        }

        public func valueWithPullback<T, U, V, W, X, R>(
          at t: T, _ u: U, _ v: V, _ w: W, _ x: X, of f: @differentiable(reverse) (T, U, V, W, X) -> R
        ) -> (value: R,
              pullback: (R.TangentVector)
                -> (T.TangentVector, U.TangentVector, V.TangentVector, W.TangentVector, X.TangentVector)) {

            let (value, pullback) = valueWithPullback(at: t, Pair(u, v), Pair(w, x)) { t, pair1, pair2 in 
                f(t, pair1.a, pair1.b, pair2.a, pair2.b)
            }

            return (
                value: value,
                pullback: { v in 
                    let results = pullback(v)
                    return (results.0, results.1.a, results.1.b, results.2.a, results.2.b)
                }
            )
        }

        public func valueWithPullback<T, U, V, W, X, Y, R>(
          at t: T, _ u: U, _ v: V, _ w: W, _ x: X, _ y: Y, of f: @differentiable(reverse) (T, U, V, W, X, Y) -> R
        ) -> (value: R,
              pullback: (R.TangentVector)
                -> (T.TangentVector, U.TangentVector, V.TangentVector, W.TangentVector, X.TangentVector, Y.TangentVector)) {

            let (value, pullback) = valueWithPullback(at: Pair(t, u), Pair(v, w), Pair(x, y)) { pair1, pair2, pair3 in 
                f(pair1.a, pair1.b, pair2.a, pair2.b, pair3.a, pair3.b)
            }

            return (
                value: value,
                pullback: { v in 
                    let results = pullback(v)
                    return (results.0.a, results.0.b, results.1.a, results.1.b, results.2.a, results.2.b)
                }
            )
        }

        public func valueWithPullback<T, U, V, W, X, Y, Z, R>(
          at t: T, _ u: U, _ v: V, _ w: W, _ x: X, _ y: Y, _ z: Z, of f: @differentiable(reverse) (T, U, V, W, X, Y, Z) -> R
        ) -> (value: R,
              pullback: (R.TangentVector)
                -> (T.TangentVector, U.TangentVector, V.TangentVector, W.TangentVector, X.TangentVector, Y.TangentVector, Z.TangentVector)) {

            let (value, pullback) = valueWithPullback(at: Pair(t, u), Pair(v, w), Pair(x, Pair(y, z))) { pair1, pair2, pair3 in 
                f(pair1.a, pair1.b, pair2.a, pair2.b, pair3.a, pair3.b.a, pair3.b.b)
            }

            return (
                value: value,
                pullback: { v in 
                    let results = pullback(v)
                    return (results.0.a, results.0.b, results.1.a, results.1.b, results.2.a, results.2.b.a, results.2.b.b)
                }
            )
        }

        public func valueWithPullback<S, T, U, V, W, X, Y, Z, R>(
          at s: S, _ t: T, _ u: U, _ v: V, _ w: W, _ x: X, _ y: Y, _ z: Z, of f: @differentiable(reverse) (S, T, U, V, W, X, Y, Z) -> R
        ) -> (value: R,
              pullback: (R.TangentVector)
                -> (S.TangentVector, T.TangentVector, U.TangentVector, V.TangentVector, W.TangentVector, X.TangentVector, Y.TangentVector, Z.TangentVector)) {

            let (value, pullback) = valueWithPullback(at: Pair(s, t), Pair(u, v), Pair(Pair(w, x), Pair(y, z))) { pair1, pair2, pair3 in 
                f(pair1.a, pair1.b, pair2.a, pair2.b, pair3.a.a, pair3.a.b, pair3.b.a, pair3.b.b)
            }

            return (
                value: value,
                pullback: { v in 
                    let results = pullback(v)
                    return (results.0.a, results.0.b, results.1.a, results.1.b, results.2.a.a, results.2.a.b, results.2.b.a, results.2.b.b)
                }
            )
        }

        public func valueWithPullback<Q, S, T, U, V, W, X, Y, Z, R>(
          at q: Q, _ s: S, _ t: T, _ u: U, _ v: V, _ w: W, _ x: X, _ y: Y, _ z: Z, of f: @differentiable(reverse) (Q, S, T, U, V, W, X, Y, Z) -> R
        ) -> (value: R,
              pullback: (R.TangentVector)
                -> (Q.TangentVector, S.TangentVector, T.TangentVector, U.TangentVector, V.TangentVector, W.TangentVector, X.TangentVector, Y.TangentVector, Z.TangentVector)) {

            let (value, pullback) = valueWithPullback(at: Pair(q, s), Pair(t, Pair(u, v)), Pair(Pair(w, x), Pair(y, z))) { pair1, pair2, pair3 in 
                f(pair1.a, pair1.b, pair2.a, pair2.b.a, pair2.b.b, pair3.a.a, pair3.a.b, pair3.b.a, pair3.b.b)
            }

            return (
                value: value,
                pullback: { v in 
                    let results = pullback(v)
                    return (results.0.a, results.0.b, results.1.a, results.1.b.a, results.1.b.b, results.2.a.a, results.2.a.b, results.2.b.a, results.2.b.b)
                }
            )
        }

        #endif

        """
        for arity in 2 ... arity {
            code.append(generateFor(arity: arity))
            code.append("\n\n")
        }
        return code
    }

    static func indent(_ indent: Int) -> String {
        (0 ..< indent).map { _ in "   " }.joined()
    }

    static func generateFor(arity: Int) -> String {
        let arityRange = 1 ... arity

        var code = """
        // MARK: Zip\(arity)SequenceDifferentiable
        """
        code += """
        @inlinable
        public func differentiableZip<\(arityRange.map { "Sequence\($0)" }.joined(separator: ", "))>(
        """
        code += arityRange.map {
            "_ sequence\($0): Sequence\($0)"
        }.joined(separator: ",\n")
        code += """

        ) -> Zip\(arity)SequenceDifferentiable<\(arityRange.map { "Sequence\($0)" }.joined(separator: ", "))> {
            Zip\(arity)SequenceDifferentiable(\(arityRange.map { "sequence\($0)" }.joined(separator: ", ")))
        }

        @frozen
        public struct Zip\(arity)SequenceDifferentiable<\(arityRange.map { "Sequence\($0): Sequence" }.joined(separator: ", "))> {
        """
        code += arityRange.map {
            """
            @usableFromInline
            internal var _sequence\($0): Sequence\($0)
            """
        }.joined(separator: "\n")
        code += """

            @inlinable
            internal init(
        """
        code += arityRange.map {
            "_ sequence\($0): Sequence\($0)"
        }.joined(separator: ",\n")

        code += """
            ) {
        """
        code += arityRange.map {
            "self._sequence\($0) = sequence\($0)"
        }.joined(separator: "\n")
        code += """

            }
        }

        extension Zip\(arity)SequenceDifferentiable {
            @frozen
            public struct Iterator {
        """
        code += arityRange.map {
            """
            @usableFromInline
            internal var _baseStream\($0): Sequence\($0).Iterator
            """
        }.joined(separator: "\n")
        code += """

                @usableFromInline
                internal var _reachedEnd: Bool = false

                @inlinable
                internal init(
        """
        code += arityRange.map {
            "_ iterator\($0): Sequence\($0).Iterator"
        }.joined(separator: ",\n")
        code += """

                ) {
        """
        code += arityRange.map {
            "self._baseStream\($0) = iterator\($0)"
        }.joined(separator: "\n")
        code += """

                }
            }
        }

        extension Zip\(arity)SequenceDifferentiable.Iterator: IteratorProtocol {
            public typealias Element = (\(arityRange.map { "Sequence\($0).Element" }.joined(separator: ", ")))

            @inlinable
            public mutating func next() -> Element? {
                if _reachedEnd {
                    return nil
                }

                guard 
        """
        code += arityRange.map {
            "let element\($0) = _baseStream\($0).next()"
        }.joined(separator: ",\n")
        code += """
                else {
                    _reachedEnd = true
                    return nil
                }

                return (\(arityRange.map { "element\($0)" }.joined(separator: ", ")))
            }
        }

        extension Zip\(arity)SequenceDifferentiable: Sequence {
            public typealias Element = (\(arityRange.map { "Sequence\($0).Element" }.joined(separator: ", ")))

            @inlinable
            public __consuming func makeIterator() -> Iterator {
                Iterator(
        """
        code += arityRange.map {
            "_sequence\($0).makeIterator()"
        }.joined(separator: ",\n")
        code += """

                )
            }

            @inlinable
            public var underestimatedCount: Int {
                Swift.min(
        """
        code += arityRange.map {
            "_sequence\($0).underestimatedCount"
        }.joined(separator: ",\n")
        code += """

                )
            }
        }

        extension Zip\(arity)SequenceDifferentiable: Sendable where 
        """
        code += arityRange.map {
            "Sequence\($0): Sendable"
        }.joined(separator: ",\n")
        code += """
        {}
        extension Zip\(arity)SequenceDifferentiable.Iterator: Sendable where 
        """
        code += arityRange.map {
            "Sequence\($0).Iterator: Sendable"
        }.joined(separator: ",\n")
        code += """
        {}
        """

        // MARK: Differentiable code

        code += """
        // MARK: Zip\(arity)SequenceDifferentiable + Differentiable

        #if canImport(_Differentiation)

        @derivative(of: differentiableZip)
        @inlinable
        public func _vjpDifferentiableZip<\(arityRange.map { "Sequence\($0)" }.joined(separator: ", "))>(
        """
        code += arityRange.map {
            "_ sequence\($0): Sequence\($0)"
        }.joined(separator: ",\n")
        code += """

        ) -> (
            value: Zip\(arity)SequenceDifferentiable<\(arityRange.map { "Sequence\($0)" }.joined(separator: ", "))>,
            pullback: (Zip\(arity)SequenceDifferentiable<\(arityRange.map { "Sequence\($0)" }
            .joined(separator: ", "))>.TangentVector) -> (\(arityRange.map { "Sequence\($0).TangentVector" }.joined(separator: ", ")))
        ) where

        """
        code += arityRange.map {
            """
            Sequence\($0): Differentiable,
            Sequence\($0).Element: Differentiable,
            Sequence\($0).TangentVector: DifferentiableSequence, // at least needs to be a sequence to have an Element associatedtype
            Sequence\($0).TangentVector.Element == Sequence\($0).Element.TangentVector
            """
        }.joined(separator: ",\n")
        code += """
        {
            (
                value: differentiableZip(\(arityRange.map { "sequence\($0)" }.joined(separator: ", "))),
                pullback: { v in
                    (\(arityRange.map { "v.sequence\($0)" }.joined(separator: ", ")))
                }
            )
        }

        extension Zip\(arity)SequenceDifferentiable: Differentiable where

        """
        code += arityRange.map {
            """
            Sequence\($0): Differentiable,
            Sequence\($0).Element: Differentiable,
            Sequence\($0).TangentVector: DifferentiableSequence, // at least needs to be a sequence to have an Element associatedtype
            Sequence\($0).TangentVector.Element == Sequence\($0).Element.TangentVector
            """
        }.joined(separator: ",\n")
        code += """

        {
            @inlinable
            public mutating func move(by offset: TangentVector) {
        """
        code += arityRange.map {
            "_sequence\($0).move(by: offset.sequence\($0))"
        }.joined(separator: "\n")
        code += """
            }

            @inlinable
            public func differentiableMap<Result: Differentiable>(_ transform: @differentiable(reverse) (\(arityRange
            .map { "Sequence\($0).Element" }.joined(separator: ", "))) -> Result
            ) -> [Result] {
                self.map(transform)
            }

            @derivative(of: differentiableMap)
            @inlinable
            public func _vjpDifferentiableMap<Result: Differentiable>(_ transform: @differentiable(reverse) (\(arityRange
            .map { "Sequence\($0).Element" }.joined(separator: ", "))) -> Result
            ) -> (value: [Result], pullback: ([Result].TangentVector) -> TangentVector) {
                var results: [Result] = []
                results.reserveCapacity(self.underestimatedCount)
                var pullbacks: [(Result.TangentVector) -> (\(arityRange.map { "Sequence\($0).Element.TangentVector" }
            .joined(separator: ", ")))] = []
                results.reserveCapacity(self.underestimatedCount)

                for parameters in self {
                    let (value, pullback) = valueWithPullback(at: \(arityRange.map { "parameters.\($0 - 1)" }
            .joined(separator: ", ")), of: transform)
                    results.append(value)
                    pullbacks.append(pullback)
                }

                return (
                    value: results,
                    pullback: { v in

        """
        code += arityRange.map {
            """
            var results\($0) = Sequence\($0).TangentVector()
            results\($0).reserveCapacity(v.count)
            """
        }.joined(separator: "\n")
        code += """

            // thoughts should Repeated tangentvector be a collection instead of also value + count alone? Will that make things easier?
            // we can't do append on a Repeated object so we either have to generate it from a single scope or not at all
            for (tangentElement, pullback) in zip(v, pullbacks) {
                let (\(arityRange.map { "result\($0)" }.joined(separator: ", "))) = pullback(tangentElement)

        """
        code += arityRange.map {
            "results\($0).appendContribution(of: result\($0))"
        }.joined(separator: "\n")
        code += """

                        }

                        return TangentVector(\(arityRange.map { "results\($0)" }.joined(separator: ", ")))
                    }
                )
            }
        }

        """
        // TODO: We should change this to a DifferentiableView approach similar to Repeated and Array once tuples can conform to `AdditiveArithmetic` (This currently blocks from `Element` conforming due to being a tuple of sequence elements
        code += """
        extension Zip\(arity)SequenceDifferentiable {
            public struct TangentVector: Sequence & Differentiable & AdditiveArithmetic where 
        """
        code += arityRange.map {
            """
            Sequence\($0): Differentiable,
            Sequence\($0).TangentVector: Sequence
            """
        }.joined(separator: ",\n")
        code += """

            {
                public typealias TangentVector = Self
                public typealias Element = (\(arityRange.map { "Sequence\($0).TangentVector.Element" }.joined(separator: ", ")))

        """
        code += arityRange.map {
            """
            @usableFromInline
            var sequence\($0): Sequence\($0).TangentVector
            """
        }.joined(separator: "\n")
        code += """

                @inlinable
                init(\(arityRange.map { "_ sequence\($0): Sequence\($0).TangentVector" }.joined(separator: ", "))) {
        """
        code += arityRange.map {
            "self.sequence\($0) = sequence\($0)"
        }.joined(separator: "\n")
        code += """
                }

                @inlinable
                public __consuming func makeIterator() -> Iterator {
                    Iterator(\(arityRange.map { "baseStream\($0): sequence\($0).makeIterator()" }.joined(separator: ", ")))
                }

                @inlinable
                public var underestimatedCount: Int {
                    Swift.min(
                        sequence1.underestimatedCount,
                        sequence2.underestimatedCount
                    )
                }

                public struct Iterator: IteratorProtocol {
                    public typealias Element = (\(arityRange.map { "Sequence\($0).TangentVector.Element" }.joined(separator: ", ")))

        """
        code += arityRange.map {
            """
            @usableFromInline
            var baseStream\($0): Sequence\($0).TangentVector.Iterator
            """
        }.joined(separator: "\n")
        code += """

                    @usableFromInline
                    var reachedEnd: Bool = false

                    @inlinable
                    init(\(arityRange.map { "baseStream\($0): Sequence\($0).TangentVector.Iterator" }.joined(separator: ", "))) {
        """
        code += arityRange.map {
            "self.baseStream\($0) = baseStream\($0)"
        }.joined(separator: "\n")
        code += """

                    }

                    @inlinable
                    public mutating func next() -> Element? {
                        if reachedEnd {
                            return nil
                        }

                        guard 
        """
        code += arityRange.map {
            "let element\($0) = baseStream\($0).next()"
        }.joined(separator: ",\n")
        code += """

                        else {
                            reachedEnd = true
                            return nil
                        }

                        return (\(arityRange.map { "element\($0)" }.joined(separator: ", ")))
                    }
                }
            }
        }

        #endif

        """
        return code
    }
}
