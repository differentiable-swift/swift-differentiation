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
        \(arityRange.map { "\(indent(1))C\($0): DifferentiableCollection," }.joined(separator: "\n"))
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
        \(arityRange.map { "\(indent(1))C\($0): DifferentiableCollection," }.joined(separator: "\n"))
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
            )> = []
            pullbacks.reserveCapacity(count)

            let results = [Result](unsafeUninitializedCapacity: count) { buffer, initializedCount in
        \(arityRange.map { "\(indent(2))var c\($0)i = c\($0).startIndex" }.joined(separator: "\n"))

                for i in 0 ..< count {
                    let (value, pullback) = valueWithPullback(
                        at:
        \(arityRange.map { "\(indent(4))c\($0)[c\($0)i]" }.joined(separator: ",\n")),
                        of: transform
                    )

                    buffer.initializeElement(at: i, to: value)
                    pullbacks.append(pullback)

        \(arityRange.map { "\(indent(3))c\($0).formIndex(after: &c\($0)i)" }.joined(separator: "\n"))
                }

                initializedCount = count
            }

            return (
                value: results,
                pullback: { v in
                    // if the incoming tangent is empty (ie. .zero) we can exit early due to the linear nature of the pullback.
                    if v.count == 0 {
                        return (
        \(arityRange.map { "\(indent(5))C\($0).TangentVector.zero" }.joined(separator: ",\n"))
                        )
                    }

                    let n = pullbacks.count
                    precondition(v.count == n)

                    // Scratch is initialized while building `tangents1` and moved out while building the
                    // rest. This is memory-safe because `building(count:_:)` guarantees a once-per-index, in-order visit
                    // (see `DifferentiableCollectionTangentVector`).
        \(arityRange.dropFirst()
            .map { "\(indent(3))let scratch\($0) = UnsafeMutableBufferPointer<C\($0).Element.TangentVector>.allocate(capacity: n)" }
            .joined(separator: "\n"))
        \(arityRange.dropFirst().map { "\(indent(3))defer { scratch\($0).deallocate() }" }.joined(separator: "\n"))

                    let tangents1 = v.withUnsafeContiguousStorage { vBuffer in
                        pullbacks.withUnsafeBufferPointer { pullbackBuffer in
                            C1.TangentVector.building(count: n) { index in
                                let (\(arityRange.map { "v\($0)" }.joined(separator: ", "))) = pullbackBuffer[index](vBuffer[index])
        \(arityRange.dropFirst().map { "\(indent(6))scratch\($0).initializeElement(at: index, to: v\($0))" }.joined(separator: "\n"))
                                return v1
                            }
                        }
                    }

        \(arityRange.dropFirst()
            .map { "\(indent(3))let tangents\($0) = C\($0).TangentVector.building(count: n) { i in scratch\($0).moveElement(from: i) }" }
            .joined(separator: "\n"))

                    return (
        \(arityRange.map { "\(indent(4))tangents\($0)" }.joined(separator: ",\n"))
                    )
                }
            )
        }

        """
        return code
    }
}
