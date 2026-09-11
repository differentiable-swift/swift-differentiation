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
                var result = _collection1.count
        \(arityRange.dropFirst().map { "\(indent(2))result = Swift.min(result, _collection\($0).count)" }.joined(separator: "\n"))
                return result
            }

            @inlinable
            public subscript(index: Int) -> Element {
                (
        \(arityRange.map { "\(indent(3))_collection\($0)[_collection\($0).startIndex.advanced(by: index)]" }.joined(separator: ",\n"))
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
                let capacity = self.count

                var pullbacks: ContiguousArray<(Result.TangentVector) -> (
        \(arityRange.map { "\(indent(3))C\($0).Element.TangentVector" }.joined(separator: ",\n"))
                )>!

                let results = Array<Result>(unsafeUninitializedCapacity: count) { resultsBuffer, resultsInitializedCount in
                    pullbacks = ContiguousArray<(Result.TangentVector) -> (
        \(arityRange.map { "\(indent(4))C\($0).Element.TangentVector" }.joined(separator: ",\n"))
                    )>(unsafeUninitializedCapacity: count) { pullbacksBuffer, pullbacksInitializedCount in
                        for i in 0 ..< capacity {
                            let parameters = self[i]
                            let (value, pullback) = valueWithPullback(
                                at:
        \(arityRange.map { "\(indent(6))parameters.\($0 - 1)" }.joined(separator: ",\n")),
                                of: transform
                            )
                            resultsBuffer.initializeElement(at: i, to: value)
                            pullbacksBuffer.initializeElement(at: i, to: pullback)
                        }
                        pullbacksInitializedCount = count
                    }
                    resultsInitializedCount = count
                }

                return (
                    value: results,
                    pullback: { v in
                        if v.count == 0 {
                            return TangentVector(
        \(arityRange.map { "\(indent(6))C\($0).TangentVector.zero" }.joined(separator: ",\n"))
                            )
                        }
                        let n = pullbacks.count
                        precondition(v.count == n)

        \(arityRange.dropFirst()
            .map { "\(indent(4))let scratch\($0) = UnsafeMutableBufferPointer<C\($0).Element.TangentVector>.allocate(capacity: n)" }
            .joined(separator: "\n"))
        \(arityRange.dropFirst().map { "\(indent(4))defer { scratch\($0).deallocate() }" }.joined(separator: "\n"))

                        let tangents1 = v.withUnsafeContiguousStorage { vBuffer in
                            pullbacks.withUnsafeBufferPointer { pullbackBuffer in
                                C1.TangentVector.building(count: n) { index in
                                    let (\(arityRange.map { "v\($0)" }.joined(separator: ", "))) = pullbackBuffer[index](vBuffer[index])
        \(arityRange.dropFirst().map { "\(indent(7))scratch\($0).initializeElement(at: index, to: v\($0))" }.joined(separator: "\n"))
                                    return v1
                                }
                            }
                        }

        \(arityRange.dropFirst()
            .map { "\(indent(4))let tangents\($0) = C\($0).TangentVector.building(count: n) { i in scratch\($0).moveElement(from: i) }" }
            .joined(separator: "\n"))

                        return TangentVector(
        \(arityRange.map { "\(indent(5))tangents\($0)" }.joined(separator: ",\n"))
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
                    var result = collection1.count
        \(arityRange.dropFirst().map { "\(indent(3))result = Swift.min(result, collection\($0).count)" }.joined(separator: "\n"))
                    return result
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

        """
        return code
    }
}
