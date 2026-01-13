enum ZipSequenceGenerator {
    static func generateFor(arity: Int) -> String {
        let arityRange = 1 ... arity
        var code = ""
        code += """

        @inlinable
        public func differentiableZip<
        \(arityRange.map { "\(indent(1))C\($0)" }.joined(separator: ",\n"))
        >(

        """
        code += arityRange.map {
            "\(indent(1))_ collection\($0): C\($0)"
        }.joined(separator: ",\n")
        code += """

        ) -> Zip\(arity)SequenceDifferentiable<\(arityRange.map { "C\($0)" }.joined(separator: ", "))> {
            Zip\(arity)SequenceDifferentiable(
        \(arityRange.map { "\(indent(2))collection\($0)" }.joined(separator: ",\n"))
            )
        }

        @frozen
        public struct Zip\(arity)SequenceDifferentiable<
        \(arityRange.map { "\(indent(1))C\($0): Collection" }.joined(separator: ",\n"))
        > where
        \(arityRange.map { "\(indent(1))C\($0).Index == Int" }.joined(separator: ",\n"))
        {

        """
        code += arityRange.map {
            """
                @usableFromInline
                internal var _collection\($0): C\($0)
            """
        }.joined(separator: "\n")
        code += """

            @inlinable
            internal init(

        """
        code += arityRange.map {
            "\(indent(2))_ collection\($0): C\($0)"
        }.joined(separator: ",\n")

        code += """

            ) {

        """
        code += arityRange.map {
            "\(indent(2))self._collection\($0) = collection\($0)"
        }.joined(separator: "\n")
        code += """

            }
        }

        extension Zip\(arity)SequenceDifferentiable: Collection {
            public typealias Element = (
        \(arityRange.map { "\(indent(2))C\($0).Element" }.joined(separator: ",\n"))
            )
            public typealias Index = Int

            @inlinable
            public var startIndex: Int { 0 }
            @inlinable
            public var endIndex: Int {
                Swift.min(
        \(arityRange.map { "\(indent(3))_collection\($0).count" }.joined(separator: ",\n"))
                )
            }

            @inlinable
            public subscript(index: Int) -> Element {
                (
        \(arityRange.map { "\(indent(3))_collection\($0)[index]" }.joined(separator: ",\n"))
                )
            }

            @inlinable
            public func index(after i: Int) -> Int {
                i + 1
            }

            @inlinable
            public func formIndex(after i: inout Int) {
                i += 1
            }
        }

        extension Zip\(arity)SequenceDifferentiable: Sendable where
        \(arityRange.map { "\(indent(1))C\($0): Sendable" }.joined(separator: ",\n"))
        {}


        """

        // MARK: Differentiable code

        code += """
        // MARK: Zip\(arity)SequenceDifferentiable + Differentiable

        #if canImport(_Differentiation)

        @derivative(of: differentiableZip)
        @inlinable
        public func _vjpDifferentiableZip<\(arityRange.map { "C\($0)" }.joined(separator: ", "))>(
        \(arityRange.map { "\(indent(1))_ collection\($0): C\($0)" }.joined(separator: ",\n"))
        ) -> (
            value: Zip\(arity)SequenceDifferentiable<\(arityRange.map { "C\($0)" }.joined(separator: ", "))>,
            pullback: (Zip\(arity)SequenceDifferentiable<\(arityRange.map { "C\($0)" }.joined(separator: ", "))>.TangentVector) -> (
        \(arityRange.map { "\(indent(2))C\($0).TangentVector" }.joined(separator: ",\n"))
            )
        ) where

        """
        code += arityRange.map {
            """
                C\($0): Differentiable,
                C\($0).Element: Differentiable,
                C\($0).TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
                C\($0).TangentVector.Index == Int,
                C\($0).TangentVector.Element == C\($0).Element.TangentVector
            """
        }.joined(separator: ",\n")
        code += """

        {
            (
                value: differentiableZip(
        \(arityRange.map { "\(indent(3))collection\($0)" }.joined(separator: ",\n"))
                ),
                pullback: { v in
                    (
        \(arityRange.map { "\(indent(4))v.collection\($0)" }.joined(separator: ",\n"))
                    )
                }
            )
        }

        extension Zip\(arity)SequenceDifferentiable {
            @inlinable
            public func differentiableMap<Result: Differentiable>(
                _ transform: @differentiable(reverse) (
        \(arityRange.map { "\(indent(3))C\($0).Element" }.joined(separator: ",\n"))
                ) -> Result
            ) -> [Result] {
                self.map(transform)
            }
        }

        extension Zip\(arity)SequenceDifferentiable: Differentiable where

        """
        code += arityRange.map {
            """
                C\($0): Differentiable,
                C\($0).Element: Differentiable,
                C\($0).TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
                C\($0).TangentVector.Index == Int,
                C\($0).TangentVector.Element == C\($0).Element.TangentVector
            """
        }.joined(separator: ",\n")
        code += """

        {
            @inlinable
            public mutating func move(by offset: TangentVector) {
        \(arityRange.map { "\(indent(2))_collection\($0).move(by: offset.collection\($0))" }.joined(separator: "\n"))
            }

            @derivative(of: differentiableMap)
            @inlinable
            public func _vjpDifferentiableMap<Result: Differentiable>(
                _ transform: @differentiable(reverse) (
        \(arityRange.map { "\(indent(3))C\($0).Element" }.joined(separator: ",\n"))
                ) -> Result
            ) -> (value: [Result], pullback: ([Result].TangentVector) -> TangentVector) {
                var results: [Result] = []
                results.reserveCapacity(self.count)
                var pullbacks: [(Result.TangentVector) -> (
        \(arityRange.map { "\(indent(3))C\($0).Element.TangentVector" }.joined(separator: ",\n"))
                )] = []
                pullbacks.reserveCapacity(self.count)

                for parameters in self {
                    let (value, pullback) = valueWithPullback(
                        at:
        \(arityRange.map { "\(indent(4))parameters.\($0 - 1)" }.joined(separator: ",\n")),
                        of: transform
                    )
                    results.append(value)
                    pullbacks.append(pullback)
                }

                return (
                    value: results,
                    pullback: { v in
        \(arityRange.map { "\(indent(4))var results\($0) = C\($0).TangentVector()" }.joined(separator: "\n"))

        \(arityRange.map { "\(indent(4))results\($0).reserveCapacity(v.count)" }.joined(separator: "\n"))

                        // thoughts should Repeated tangentvector be a collection instead of also value + count alone? Will that make things easier?
                        // we can't do append on a Repeated object so we either have to generate it from a single scope or not at all

                        assert(v.count == pullbacks.count)
                        for (tangentElement, pullback) in zip(v, pullbacks) {
                            let (
        \(arityRange.map { "\(indent(6))result\($0)" }.joined(separator: ",\n"))
                            ) = pullback(tangentElement)

        \(arityRange.map { "\(indent(5))results\($0).appendContribution(of: result\($0))" }.joined(separator: "\n"))
                        }

                        return TangentVector(
        \(arityRange.map { "\(indent(5))results\($0)" }.joined(separator: ",\n"))
                        )
                    }
                )
            }
        }

        """
        // TODO: We should change this to a DifferentiableView approach similar to Repeated and Array once tuples can conform to `AdditiveArithmetic` (This currently blocks from `Element` conforming due to being a tuple of collection elements
        code += """

        extension Zip\(arity)SequenceDifferentiable {
            public struct TangentVector: Collection & Differentiable & AdditiveArithmetic where

        """
        code += arityRange.map {
            """
            \(indent(2))C\($0): Differentiable,
            \(indent(2))C\($0).TangentVector: Collection,
            \(indent(2))C\($0).TangentVector.Index == Int
            """
        }.joined(separator: ",\n")
        code += """

            {
                public typealias TangentVector = Self
                public typealias Element = (
        \(arityRange.map { "\(indent(3))C\($0).TangentVector.Element" }.joined(separator: ",\n"))
                )
                public typealias Index = Int

                @inlinable
                public var startIndex: Int { 0 }
                @inlinable
                public var endIndex: Int {
                    Swift.min(
        \(arityRange.map { "\(indent(4))collection\($0).count" }.joined(separator: ",\n"))
                    )
                }

                @inlinable
                public subscript(index: Int) -> Element {
                    (
        \(arityRange.map { "\(indent(4))collection\($0)[index]" }.joined(separator: ",\n"))
                    )
                }

                @inlinable
                public func index(after i: Int) -> Int {
                    i + 1
                }

                @inlinable
                public func formIndex(after i: inout Int) {
                    i += 1
                }


        """
        code += arityRange.map {
            """
            \(indent(2))@usableFromInline
            \(indent(2))var collection\($0): C\($0).TangentVector
            """
        }.joined(separator: "\n")
        code += """

                @inlinable
                init(
        \(arityRange.map { "\(indent(3))_ collection\($0): C\($0).TangentVector" }.joined(separator: ",\n"))
                ) {
        \(arityRange.map { "\(indent(3))self.collection\($0) = collection\($0)" }.joined(separator: "\n"))
                }
            }
        }

        #endif

        """
        return code
    }
}
