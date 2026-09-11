enum ZipWithGenerator {
    static func generateFor(arity: Int) -> String {
        let arityRange = 1 ... arity
        var code = ""
        code += """

        import _Differentiation

        @inlinable
        public func differentiableZipWith<\(arityRange.map { "C\($0)" }.joined(separator: ", ")), Result>(
        \(arityRange.map { "\(indent(1))_ c\($0): C\($0)" }.joined(separator: ",\n")),
            with transform: @differentiable(reverse) (
        \(arityRange.map { "\(indent(2))C\($0).Element" }.joined(separator: ",\n"))
            ) -> Result
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
            var capacity = c1.count
        \(arityRange.dropFirst().map { "\(indent(1))capacity = Swift.min(capacity, c\($0).count)" }.joined(separator: "\n"))

            if capacity == 0 { return [] }

            return [Result](unsafeUninitializedCapacity: capacity) { buffer, initializedCount in
        \(arityRange.map { "\(indent(2))var c\($0)i = c\($0).startIndex" }.joined(separator: "\n"))

                for i in 0 ..< capacity {
                    let value = transform(
        \(arityRange.map { "\(indent(4))c\($0)[c\($0)i]" }.joined(separator: ",\n"))
                    )
                    buffer.initializeElement(at: i, to: value)
        \(arityRange.map { "\(indent(3))c\($0).formIndex(after: &c\($0)i)" }.joined(separator: "\n"))
                }
                initializedCount = capacity
            }
        }

        @derivative(of: differentiableZipWith)
        @inlinable
        public func _vjpDifferentiableZipWith<\(arityRange.map { "C\($0)" }.joined(separator: ", ")), Result>(
        \(arityRange.map { "\(indent(1))_ c\($0): C\($0)" }.joined(separator: ",\n")),
            with transform: @differentiable(reverse) (
        \(arityRange.map { "\(indent(2))C\($0).Element" }.joined(separator: ",\n"))
            ) -> Result
        ) -> (
            value: [Result],
            pullback: ([Result].TangentVector) -> (
        \(arityRange.map { "\(indent(2))C\($0).TangentVector" }.joined(separator: ",\n"))
            )
        ) where

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
            var count = c1.count
        \(arityRange.dropFirst().map { "\(indent(1))count = Swift.min(count, c\($0).count)" }.joined(separator: "\n"))

            if count == 0 {
                return (
                    value: [],
                    pullback: { _ in
                        (
        \(arityRange.map { "\(indent(5))C\($0).TangentVector.zero" }.joined(separator: ",\n"))
                        )
                    }
                )
            }

            var pullbacks: ContiguousArray<(Result.TangentVector) -> (
        \(arityRange.map { "\(indent(2))C\($0).Element.TangentVector" }.joined(separator: ",\n"))
            )>!
            let results = Array<Result>(unsafeUninitializedCapacity: count) { resultsBuffer, resultsInitializedCount in
                pullbacks = ContiguousArray<(Result.TangentVector) -> (
        \(arityRange.map { "\(indent(3))C\($0).Element.TangentVector" }.joined(separator: ",\n"))
                )>(unsafeUninitializedCapacity: count) { pullbacksBuffer, pullbacksInitializedCount in
        \(arityRange.map { "\(indent(3))var c\($0)i = c\($0).startIndex" }.joined(separator: "\n"))

                    for i in 0 ..< count {
                        let (value, pullback) = valueWithPullback(
                            at:
        \(arityRange.map { "\(indent(5))c\($0)[c\($0)i]" }.joined(separator: ",\n")),
                            of: transform
                        )

                        resultsBuffer.initializeElement(at: i, to: value)
                        pullbacksBuffer.initializeElement(at: i, to: pullback)

        \(arityRange.map { "\(indent(4))c\($0).formIndex(after: &c\($0)i)" }.joined(separator: "\n"))
                    }
                    pullbacksInitializedCount = count
                }
                resultsInitializedCount = count
            }

            return (
                value: results,
                pullback: { v in
                    guard v.count != 0 else {
                        return (
        \(arityRange.map { "\(indent(5))C\($0).TangentVector.zero" }.joined(separator: ",\n"))
                        )
                    }
        \(arityRange.map { "\(indent(3))var results\($0) = C\($0).TangentVector()" }.joined(separator: "\n"))

        \(arityRange.map { "\(indent(3))results\($0).reserveCapacity(pullbacks.count)" }.joined(separator: "\n"))

                    precondition(v.count == pullbacks.count)

                    for (tangentElement, pullback) in zip(v, pullbacks) {
                        let (\(arityRange.map { "v\($0)" }.joined(separator: ", "))) = pullback(tangentElement)

        \(arityRange.map { "\(indent(4))results\($0).appendContribution(of: v\($0))" }.joined(separator: "\n"))
                    }

                    return (
        \(arityRange.map { "\(indent(4))results\($0)" }.joined(separator: ",\n"))
                    )
                }
            )
        }

        """
        return code
    }
}
