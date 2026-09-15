enum FusedZipWithGenerator {
    static func generateFor(arity: Int) -> String {
        let arityRange = 1 ... arity
        var code = ""
        code += """

        import _Differentiation

        @inlinable
        public func fusedZip<\(arityRange.map { "C\($0)" }.joined(separator: ", ")), Result>(
        \(arityRange.map { "\(indent(1))_ c\($0): C\($0)" }.joined(separator: ",\n")),
            with transform: @differentiable(reverse) (
        \(arityRange.map { "\(indent(2))C\($0).Element" }.joined(separator: ",\n"))
            ) -> Result
        ) -> [Result] where
            Result: BinaryFloatingPoint,
            Result: Differentiable,
            Result.TangentVector == Result,
        \(arityRange.map { "\(indent(1))C\($0): DifferentiableCollection" }.joined(separator: ",\n"))
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

        @derivative(of: fusedZip)
        @inlinable
        public func _vjpFusedZip<\(arityRange.map { "C\($0)" }.joined(separator: ", ")), Result>(
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
            Result: BinaryFloatingPoint,
            Result: Differentiable,
            Result.TangentVector == Result,
        \(arityRange.map { "\(indent(1))C\($0): DifferentiableCollection" }.joined(separator: ",\n")),
        \(arityRange.map { "\(indent(1))C\($0).Element.TangentVector: ScalableByBinaryFloatingPoint" }.joined(separator: ",\n"))
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

        \(arityRange.map { "\(indent(1))var gradients\($0)Storage: [C\($0).Element.TangentVector]!" }.joined(separator: "\n"))
            let results = [Result](unsafeUninitializedCapacity: count) { resultsBuffer, initializedCount0 in
        \(arityRange
            .map {
                "\(indent(1 + $0))gradients\($0)Storage = [C\($0).Element.TangentVector](unsafeUninitializedCapacity: count) { gradients\($0)Buffer, initializedCount\($0) in"
            }.joined(separator: "\n"))
        \(arityRange.map { "\(indent(2 + arity))var c\($0)i = c\($0).startIndex" }.joined(separator: "\n"))
                \(indent(arity))for i in 0 ..< count {
                \(indent(arity))    let (value, pullback) = valueWithPullback(
                \(indent(arity))        at:
        \(arityRange.map { "\(indent(4 + arity))c\($0)[c\($0)i]" }.joined(separator: ",\n")),
                \(indent(arity))        of: transform
                \(indent(arity))    )

                \(indent(arity))    let (\(arityRange.map { "g\($0)" }.joined(separator: ", "))) = pullback(1.0)
                \(indent(arity))    resultsBuffer.initializeElement(at: i, to: value)
        \(arityRange.map { "\(indent(3 + arity))gradients\($0)Buffer.initializeElement(at: i, to: g\($0))" }.joined(separator: "\n"))

        \(arityRange.map { "\(indent(3 + arity))c\($0).formIndex(after: &c\($0)i)" }.joined(separator: "\n"))
                \(indent(arity))}
                \(indent(arity))initializedCount0 = count
        \(arityRange.map { "\(indent(2 + arity))initializedCount\($0) = count" }.joined(separator: "\n"))
        \(arityRange.map { "\(indent(2 + arity - $0))}" }.joined(separator: "\n"))
            }
        \(arityRange.map { "\(indent(1))let gradients\($0): [C\($0).Element.TangentVector] = gradients\($0)Storage" }
            .joined(separator: "\n"))

            return (
                value: results,
                pullback: { v in
                    let n = v.count
                    if n == 0 {
                        return (
        \(arityRange.map { "\(indent(5))C\($0).TangentVector.zero" }.joined(separator: ",\n"))
                        )
                    }
                    return v.withUnsafeContiguousStorage { vBuffer in
        \(arityRange
            .map {
                "\(indent(4))let tangents\($0) = C\($0).TangentVector.building(count: n) { i in gradients\($0)[i].scaled(by: vBuffer[i]) }"
            }
            .joined(separator: "\n"))
                        return (
        \(arityRange.map { "\(indent(5))tangents\($0)" }.joined(separator: ",\n"))
                        )
                    }
                }
            )
        }

        """
        return code
    }
}
