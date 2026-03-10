enum ZipWithInoutGenerator {
    static func generateFor(arity: Int) -> String {
        let arityRange = 2 ... arity
        var code = ""
        code += """

        #if canImport(_Differentiation)
        import _Differentiation

        @inlinable
        public func differentiableZipWith<Inout, \(arityRange.map { "C\($0)" }.joined(separator: ", "))>(
            _ c1: inout Inout,
        \(arityRange.map { "\(indent(1))_ c\($0): C\($0)" }.joined(separator: ",\n")),
            with transform: @differentiable(reverse) (
                Inout.Element,
        \(arityRange.map { "\(indent(2))C\($0).Element" }.joined(separator: ",\n"))
            ) -> Inout.Element
        ) -> Void where
            Inout: MutableCollection,
            Inout: DifferentiableCollection,
            Inout.Element: Differentiable,

        """
        code += arityRange.map {
            """
                C\($0): DifferentiableCollection,
                C\($0).Element: Differentiable
            """
        }.joined(separator: ",\n")
        code += """

        {
            let capacity = min(
                c1.count,
        \(arityRange.map { "\(indent(2))c\($0).count" }.joined(separator: ",\n"))
            )

            if capacity == 0 { return }

            var c1i = c1.startIndex
        \(arityRange.map { "\(indent(1))var c\($0)i = c\($0).startIndex" }.joined(separator: "\n"))

            for _ in 0 ..< capacity {
                c1[c1i] = transform(
                    c1[c1i],
        \(arityRange.map { "\(indent(3))c\($0)[c\($0)i]" }.joined(separator: ",\n"))
                )
                c1.formIndex(after: &c1i)
        \(arityRange.map { "\(indent(2))c\($0).formIndex(after: &c\($0)i)" }.joined(separator: "\n"))
            }
        }

        @derivative(of: differentiableZipWith)
        @inlinable
        public func _vjpDifferentiableZipWith<Inout, \(arityRange.map { "C\($0)" }.joined(separator: ", "))>(
            _ c1: inout Inout,
        \(arityRange.map { "\(indent(1))_ c\($0): C\($0)" }.joined(separator: ",\n")),
            with transform: @differentiable(reverse) (
                Inout.Element,
        \(arityRange.map { "\(indent(2))C\($0).Element" }.joined(separator: ",\n"))
            ) -> Inout.Element
        ) -> (
            value: Void,
            pullback: (inout Inout.TangentVector) -> (
        \(arityRange.map { "\(indent(2))C\($0).TangentVector" }.joined(separator: ",\n"))
            )
        ) where
            Inout: MutableCollection,
            Inout.TangentVector: MutableCollection,
            Inout: DifferentiableCollection,
            Inout.Element: Differentiable,

        """
        code += arityRange.map {
            """
                C\($0): DifferentiableCollection,
                C\($0).Element: Differentiable
            """
        }.joined(separator: ",\n")
        code += """

        {
            let count = min(
                c1.count,
        \(arityRange.map { "\(indent(2))c\($0).count" }.joined(separator: ",\n"))
            )

            if count == 0 {
                return (
                    value: (),
                    pullback: { _ in
                        // swiftformat:disable:next redundantParens
                        (
        \(arityRange.map { "\(indent(5))C\($0).TangentVector.zero" }.joined(separator: ",\n"))
                        )
                    }
                )
            }

            var pullbacks: ContiguousArray<(Inout.Element.TangentVector) -> (
                Inout.Element.TangentVector,
        \(arityRange.map { "\(indent(2))C\($0).Element.TangentVector" }.joined(separator: ",\n"))
            )> = []
            pullbacks.reserveCapacity(count)

            var c1i = c1.startIndex
        \(arityRange.map { "\(indent(1))var c\($0)i = c\($0).startIndex" }.joined(separator: "\n"))

            for _ in 0 ..< count {
                let (value, pullback) = valueWithPullback(
                    at:
                    c1[c1i],
        \(arityRange.map { "\(indent(3))c\($0)[c\($0)i]" }.joined(separator: ",\n")),
                    of: transform
                )

                c1[c1i] = value

                pullbacks.append(pullback)

                c1.formIndex(after: &c1i)
        \(arityRange.map { "\(indent(2))c\($0).formIndex(after: &c\($0)i)" }.joined(separator: "\n"))
            }

            return (
                value: (),
                pullback: { v in
                    precondition(v.count == pullbacks.count)

        \(arityRange.map { "\(indent(3))var results\($0) = C\($0).TangentVector(repeating: .zero, count: v.count)" }
            .joined(separator: "\n"))
        \(arityRange.map { "\(indent(3))var results\($0)Index = results\($0).startIndex" }.joined(separator: "\n"))

                    for (index, (tangentElement, pullback)) in zip(v.indices, zip(v, pullbacks)) {
                        let (v1, \(arityRange.map { "v\($0)" }.joined(separator: ", "))) = pullback(tangentElement)
                        v[index] = v1
        \(arityRange.map { "\(indent(4))results\($0).writeTangentContribution(of: v\($0), at: results\($0)Index)" }.joined(separator: "\n"))
        \(arityRange.map { "\(indent(4))results\($0).formIndex(after: &results\($0)Index)" }.joined(separator: "\n"))
                    }

                    // swiftformat:disable:next redundantParens
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
