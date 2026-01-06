enum ZipWithGenerator {
    static func generateFor(arity: Int) -> String {
        let arityRange = 1 ... arity
        var code = ""
        code += """
        
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
            let capacity = min(
        \(arityRange.map { "\(indent(2))c\($0).count" }.joined(separator: ",\n"))
            )

            if capacity == 0 { return [] }

            var results = ContiguousArray<Result>()
            results.reserveCapacity(capacity)

        \(arityRange.map { "\(indent(1))var c\($0)i = c\($0).startIndex" }.joined(separator: "\n"))

            for _ in 0 ..< capacity {
                results.append(transform(
        \(arityRange.map { "\(indent(3))c\($0)[c\($0)i]" }.joined(separator: ",\n"))
                ))
        \(arityRange.map { "\(indent(2))c\($0).formIndex(after: &c\($0)i)" }.joined(separator: "\n"))
            }

            return Array(results)
        }
        
        #if canImport(_Differentiation)

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
            let count = min(
        \(arityRange.map { "\(indent(2))c\($0).count" }.joined(separator: ",\n"))
            )

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

            var results = ContiguousArray<Result>()
            results.reserveCapacity(count)
            var pullbacks: ContiguousArray<(Result.TangentVector) -> (
        \(arityRange.map { "\(indent(2))C\($0).Element.TangentVector" }.joined(separator: ",\n"))
            )> = []
            pullbacks.reserveCapacity(count)

        \(arityRange.map { "\(indent(1))var c\($0)i = c\($0).startIndex" }.joined(separator: "\n"))

            for _ in 0 ..< count {
                let (value, pullback) = valueWithPullback(
                    at:
        \(arityRange.map { "\(indent(3))c\($0)[c\($0)i]" }.joined(separator: ",\n")),
                    of: transform
                )

                results.append(value)
                pullbacks.append(pullback)

        \(arityRange.map { "\(indent(2))c\($0).formIndex(after: &c\($0)i)" }.joined(separator: "\n"))
            }

            return (
                value: Array(results),
                pullback: { v in
                    precondition(v.count == pullbacks.count)

        """
        code += arityRange.map {
            """
            \(indent(3))var results\($0) = C\($0).TangentVector()
            \(indent(3))results\($0).reserveCapacity(v.count)
            """
        }.joined(separator: "\n")
        code += """

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

        #endif

        """
        return code
    }
}
