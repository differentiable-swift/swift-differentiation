enum ZipWithInoutGenerator {
    static func generateFor(arity: Int) -> String {
        let arityRange = 2 ... arity
        var code = ""
        code += """

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
        \(arityRange.map { "\(indent(1))C\($0): DifferentiableCollection" }.joined(separator: ",\n"))
        {
            var capacity = c1.count
        \(arityRange.map { "\(indent(1))capacity = Swift.min(capacity, c\($0).count)" }.joined(separator: "\n"))

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
        \(arityRange.map { "\(indent(1))C\($0): DifferentiableCollection" }.joined(separator: ",\n"))
        {
            var count = c1.count
        \(arityRange.map { "\(indent(1))count = Swift.min(count, c\($0).count)" }.joined(separator: "\n"))

            if count == 0 {
                return (
                    value: (),
                    pullback: { _ in
                        \(tupleExpression(arityRange.map { "C\($0).TangentVector.zero" }, parenIndent: 4))
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
                    let n = pullbacks.count

                    if v.count == 0 {
                        return \(tupleExpression(arityRange.map { "C\($0).TangentVector.zero" }, parenIndent: 4))
                    }

                    precondition(v.count == n)

                    // `tangents2` is the driver: it runs each element pullback once, writes the `Inout`
                    // tangent back into `v` in place (along `v`'s native indices — its index type need not be
                    // `Int`), and stashes the remaining tangents (`C3` here; `C3…CN` in general) into scratch
                    // buffers. The remaining tangents are then built by moving out of those buffers. Memory-safe
                    // because of `init(count:_:)`'s once-per-index, in-order contract: every scratch slot is
                    // initialized during the driver pass before it is moved (see
                    // `DifferentiableCollectionTangentVector`).
        \(arityRange.dropFirst()
            .map { "\(indent(3))let scratch\($0) = UnsafeMutableBufferPointer<C\($0).Element.TangentVector>.allocate(capacity: n)" }
            .joined(separator: "\n"))
        \(arityRange.dropFirst().map { "\(indent(3))defer { scratch\($0).deallocate() }" }.joined(separator: "\n"))

                    var vi = v.startIndex
                    let tangents2 = pullbacks.withUnsafeBufferPointer { pullbackBuffer in
                        C2.TangentVector(count: n) { index in
                            let (v1, \(arityRange.map { "v\($0)" }.joined(separator: ", "))) = pullbackBuffer[index](v[vi])
                            v[vi] = v1
        \(arityRange.dropFirst().map { "\(indent(5))scratch\($0).initializeElement(at: index, to: v\($0))" }.joined(separator: "\n"))
                            v.formIndex(after: &vi)
                            return v2
                        }
                    }

        \(arityRange.dropFirst()
            .map { "\(indent(3))let tangents\($0) = C\($0).TangentVector(count: n) { i in scratch\($0).moveElement(from: i) }" }
            .joined(separator: "\n"))

                    return \(tupleExpression(arityRange.map { "tangents\($0)" }, parenIndent: 3))
                }
            )
        }

        """
        return code
    }
}
