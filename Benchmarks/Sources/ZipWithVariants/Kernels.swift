import Differentiation

// Shared between both benchmark frameworks and the correctness tests. Inputs are deterministic
// (no RNG) so ordo-one baselines stay comparable across runs.

public func makeInput(_ n: Int, seed: Float = 1) -> [Float] {
    (0 ..< n).map { Float(($0 % 97) + 1) * 0.013 * seed }
}

/// Aggregates 8 arrays so arity-8 kernels can be differentiated through the single-argument
/// `valueWithPullback(at:of:)` (the multi-argument overloads don't go to arity 8).
public struct Inputs8: Differentiable {
    public var c1: [Float]
    public var c2: [Float]
    public var c3: [Float]
    public var c4: [Float]
    public var c5: [Float]
    public var c6: [Float]
    public var c7: [Float]
    public var c8: [Float]

    public init(n: Int) {
        c1 = makeInput(n, seed: 1)
        c2 = makeInput(n, seed: 2)
        c3 = makeInput(n, seed: 3)
        c4 = makeInput(n, seed: 4)
        c5 = makeInput(n, seed: 5)
        c6 = makeInput(n, seed: 6)
        c7 = makeInput(n, seed: 7)
        c8 = makeInput(n, seed: 8)
    }

    public init(base: [Float]) {
        c1 = base
        c2 = base.map { $0 * 0.2 }
        c3 = base.map { $0 * 0.3 }
        c4 = base.map { $0 * 0.4 }
        c5 = base.map { $0 * 0.5 }
        c6 = base.map { $0 * 0.6 }
        c7 = base.map { $0 * 0.7 }
        c8 = base.map { $0 * 0.8 }
    }
}

// MARK: - Arity-2 kernels

@differentiable(reverse)
public func zipWith2_canonical(_ lhs: [Float], _ rhs: [Float]) -> [Float] {
    differentiableZipWith(lhs, rhs) { $0 * $1 }
}

// MARK: - Arity-8 kernels

@differentiable(reverse)
public func zipWith8_canonical(_ inputs: Inputs8) -> [Float] {
    differentiableZipWith(
        inputs.c1, inputs.c2, inputs.c3, inputs.c4, inputs.c5, inputs.c6, inputs.c7, inputs.c8
    ) { $0 * $1 + $2 * $3 + $4 * $5 + $6 * $7 }
}
