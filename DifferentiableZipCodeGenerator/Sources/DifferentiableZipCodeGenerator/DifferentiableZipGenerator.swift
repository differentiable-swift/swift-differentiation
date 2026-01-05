enum ZipSequenceGenerator {
    static func indent(_ indent: Int) -> String {
        (0 ..< indent).map { _ in "    " }.joined()
    }

    static func generateFor(arity: Int) -> String {
        let arityRange = 1 ... arity

        var code = """
        // MARK: Zip\(arity)SequenceDifferentiable
        """
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
            Zip\(arity)SequenceDifferentiable(\(arityRange.map { "collection\($0)" }.joined(separator: ", ")))
        }

        @frozen
        public struct Zip\(arity)SequenceDifferentiable<\(arityRange.map { "C\($0): Collection" }
            .joined(separator: ", "))> where \(arityRange.map { "C\($0).Index == Int" }.joined(separator: ", ")) {
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
            "_ collection\($0): C\($0)"
        }.joined(separator: ",\n")

        code += """
            ) {
        """
        code += arityRange.map {
            "self._collection\($0) = collection\($0)"
        }.joined(separator: "\n")
        code += """

            }
        }

        extension Zip\(arity)SequenceDifferentiable: Collection {
            public typealias Element = (\(arityRange.map { "C\($0).Element" }.joined(separator: ", ")))
            public typealias Index = Int

            @inlinable
            public var startIndex: Int { 0 }
            @inlinable
            public var endIndex: Int {
                Swift.min(\(arityRange.map { "_collection\($0).count" }.joined(separator: ", ")))
            }
            
            @inlinable
            public subscript(index: Int) -> Element {
                (\(arityRange.map { "_collection\($0)[index]" }.joined(separator: ", ")))
            }

            @inlinable
            public func index(after index: Int) -> Int {
                index + 1
            }

            @inlinable
            public func formIndex(after i: inout Int) {
                i += 1
            }

        }

        extension Zip\(arity)SequenceDifferentiable: Sendable where 
        """
        code += arityRange.map {
            "C\($0): Sendable"
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
        public func _vjpDifferentiableZip<\(arityRange.map { "C\($0)" }.joined(separator: ", "))>(
        """
        code += arityRange.map {
            "_ collection\($0): C\($0)"
        }.joined(separator: ",\n")
        code += """

        ) -> (
            value: Zip\(arity)SequenceDifferentiable<\(arityRange.map { "C\($0)" }.joined(separator: ", "))>,
            pullback: (Zip\(arity)SequenceDifferentiable<\(arityRange.map { "C\($0)" }
            .joined(separator: ", "))>.TangentVector) -> (\(arityRange.map { "C\($0).TangentVector" }.joined(separator: ", ")))
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
                value: differentiableZip(\(arityRange.map { "collection\($0)" }.joined(separator: ", "))),
                pullback: { v in
                    (\(arityRange.map { "v.collection\($0)" }.joined(separator: ", ")))
                }
            )
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
        """
        code += arityRange.map {
            "_collection\($0).move(by: offset.collection\($0))"
        }.joined(separator: "\n")
        code += """
            }

            @inlinable
            public func differentiableMap<Result: Differentiable>(_ transform: @differentiable(reverse) (\(arityRange
            .map { "C\($0).Element" }.joined(separator: ", "))) -> Result
            ) -> [Result] {
                self.map(transform)
            }

            @derivative(of: differentiableMap)
            @inlinable
            public func _vjpDifferentiableMap<Result: Differentiable>(_ transform: @differentiable(reverse) (\(arityRange
            .map { "C\($0).Element" }.joined(separator: ", "))) -> Result
            ) -> (value: [Result], pullback: ([Result].TangentVector) -> TangentVector) {
                var results: [Result] = []
                results.reserveCapacity(self.count)
                var pullbacks: [(Result.TangentVector) -> (\(arityRange.map { "C\($0).Element.TangentVector" }
            .joined(separator: ", ")))] = []
                pullbacks.reserveCapacity(self.count)

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
            var results\($0) = C\($0).TangentVector()
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
        // TODO: We should change this to a DifferentiableView approach similar to Repeated and Array once tuples can conform to `AdditiveArithmetic` (This currently blocks from `Element` conforming due to being a tuple of collection elements
        code += """
        extension Zip\(arity)SequenceDifferentiable {
            public struct TangentVector: Collection & Differentiable & AdditiveArithmetic where 
        """
        code += arityRange.map {
            """
            C\($0): Differentiable,
            C\($0).TangentVector: Collection,
            C\($0).TangentVector.Index == Int
            """
        }.joined(separator: ",\n")
        code += """

            {
                public typealias TangentVector = Self
                public typealias Element = (\(arityRange.map { "C\($0).TangentVector.Element" }.joined(separator: ", ")))
                public typealias Index = Int

                @inlinable
                public var startIndex: Int { 0 }
                @inlinable
                public var endIndex: Int { 
                    Swift.min(\(arityRange.map { "collection\($0).count" }.joined(separator: ", ")))
                }
                
                @inlinable
                public subscript(index: Int) -> Element {
                    (\(arityRange.map { "collection\($0)[index]" }.joined(separator: ", ")))
                }
            
                @inlinable
                public func index(after index: Int) -> Int {
                    index + 1
                }

                @inlinable
                public func formIndex(after i: inout Int) {
                    i += 1
                }

        """
        code += arityRange.map {
            """
            @usableFromInline
            var collection\($0): C\($0).TangentVector
            """
        }.joined(separator: "\n")
        code += """

                @inlinable
                init(\(arityRange.map { "_ collection\($0): C\($0).TangentVector" }.joined(separator: ", "))) {
        """
        code += arityRange.map {
            "self.collection\($0) = collection\($0)"
        }.joined(separator: "\n")
        code += """
                }

            }
        }

        @inlinable
        public func differentiableZipWith<\(arityRange.map { "C\($0)" }.joined(separator: ", ")), Result>(
        """
        code += arityRange.map { "_ c\($0): C\($0)," }.joined(separator: "\n")
        code += """
            with transform: @differentiable(reverse) (\(arityRange.map { "C\($0).Element" }.joined(separator: ", "))) -> Result
        ) -> [Result] where

        """
        code += arityRange.map {
            """
            C\($0): DifferentiableCollection,
            C\($0).Element: Differentiable,
            """
        }.joined(separator: "\n")
        code += """
            Result: Differentiable
        {
            let capacity = min(\(arityRange.map { "c\($0).count" }.joined(separator: ", ")))
            
            if capacity == 0 { return [] }
            
            var results = ContiguousArray<Result>()
            results.reserveCapacity(capacity)

        """
        code += arityRange.map {
            "var c\($0)i = c\($0).startIndex"
        }.joined(separator: "\n")
        code += """
            
            for _ in 0 ..< capacity {
                results.append(transform(\(arityRange.map { "c\($0)[c\($0)i]" }.joined(separator: ", "))))

        """
        code += arityRange.map {
            "c\($0).formIndex(after: &c\($0)i)"
        }.joined(separator: "\n")
        code += """

            }
            
            return Array(results)
        }

        @derivative(of: differentiableZipWith)
        @inlinable
        public func _vjpDifferentiableZipWith<\(arityRange.map { "C\($0)" }.joined(separator: ", ")), Result>(
        """
        code += arityRange.map { "_ c\($0): C\($0)," }.joined(separator: "\n")
        code += """
            with transform: @differentiable(reverse) (\(arityRange.map { "C\($0).Element" }.joined(separator: ", "))) -> Result
        ) -> (value: [Result], pullback: ([Result].TangentVector) -> (\(arityRange.map { "C\($0).TangentVector" }
            .joined(separator: ", ")))) where

        """
        code += arityRange.map {
            """
            C\($0): DifferentiableCollection,
            C\($0).Element: Differentiable,
            """
        }.joined(separator: "\n")
        code += """

            Result: Differentiable
        {
            let count = min(\(arityRange.map { "c\($0).count" }.joined(separator: ", ")))
            
            if count == 0 {
                return (value: [], pullback: { v in (\(arityRange.map { "C\($0).TangentVector()" }.joined(separator: ", "))) })
            }
            
            var results = ContiguousArray<Result>()
            results.reserveCapacity(count)
            var pullbacks: ContiguousArray<(Result.TangentVector) -> (\(arityRange.map { "C\($0).Element.TangentVector" }
            .joined(separator: ", ")))> = []
            pullbacks.reserveCapacity(count)

        """
        code += arityRange.map {
            "var c\($0)i = c\($0).startIndex"
        }.joined(separator: "\n")
        code += """
            
            for _ in 0 ..< count {
                let (value, pullback) = valueWithPullback(at: \(arityRange.map { "c\($0)[c\($0)i]" }
            .joined(separator: ", ")), of: transform)
                
                results.append(value)
                pullbacks.append(pullback)

        """
        code += arityRange.map { "c\($0).formIndex(after: &c\($0)i)" }.joined(separator: "\n")
        code += """

            }
            
            return (
                value: Array(results),
                pullback: { v in

        """
        code += arityRange.map {
            """
            var results\($0) = C\($0).TangentVector()
            results\($0).reserveCapacity(v.count)
            """
        }.joined(separator: "\n")
        code += """
                    
                    for (tangentElement, pullback) in zip(v, pullbacks) {
                        let (\(arityRange.map { "v\($0)" }.joined(separator: ", "))) = pullback(tangentElement)

        """
        code += arityRange.map { "results\($0).appendContribution(of: v\($0))" }.joined(separator: "\n")
        code += """

                    }
                    
                    return (\(arityRange.map { "results\($0)" }.joined(separator: ", ")))
                }
            )
        }


        #endif

        """
        return code
    }
}
