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

@differentiable(reverse)
public func zipWith2_fused(_ lhs: [Float], _ rhs: [Float]) -> [Float] {
    fusedZip(lhs, rhs) { $0 * $1 }
}

// MARK: - Arity-8 kernels

@differentiable(reverse)
public func zipWith8_canonical(_ inputs: Inputs8) -> [Float] {
    differentiableZipWith(
        inputs.c1, inputs.c2, inputs.c3, inputs.c4, inputs.c5, inputs.c6, inputs.c7, inputs.c8
    ) { $0 * $1 + $2 * $3 + $4 * $5 + $6 * $7 }
}

// MARK: - Arity coverage (3, 4, 14) for the shape-regression matrix

public struct Inputs3: Differentiable {
    public var c1, c2, c3: [Float]

    public init(n: Int) {
        c1 = makeInput(n, seed: 1)
        c2 = makeInput(n, seed: 2)
        c3 = makeInput(n, seed: 3)
    }
}

@differentiable(reverse)
public func zipWith3_canonical(_ inputs: Inputs3) -> [Float] {
    differentiableZipWith(
        inputs.c1, inputs.c2, inputs.c3
    ) { $0 * $1 + $2 }
}

public struct Inputs4: Differentiable {
    public var c1, c2, c3, c4: [Float]

    public init(n: Int) {
        c1 = makeInput(n, seed: 1)
        c2 = makeInput(n, seed: 2)
        c3 = makeInput(n, seed: 3)
        c4 = makeInput(n, seed: 4)
    }
}

@differentiable(reverse)
public func zipWith4_canonical(_ inputs: Inputs4) -> [Float] {
    differentiableZipWith(
        inputs.c1, inputs.c2, inputs.c3, inputs.c4
    ) { $0 * $1 + $2 * $3 }
}

public struct Inputs14: Differentiable {
    public var c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14: [Float]

    public init(n: Int) {
        c1 = makeInput(n, seed: 1)
        c2 = makeInput(n, seed: 2)
        c3 = makeInput(n, seed: 3)
        c4 = makeInput(n, seed: 4)
        c5 = makeInput(n, seed: 5)
        c6 = makeInput(n, seed: 6)
        c7 = makeInput(n, seed: 7)
        c8 = makeInput(n, seed: 8)
        c9 = makeInput(n, seed: 9)
        c10 = makeInput(n, seed: 10)
        c11 = makeInput(n, seed: 11)
        c12 = makeInput(n, seed: 12)
        c13 = makeInput(n, seed: 13)
        c14 = makeInput(n, seed: 14)
    }
}

@differentiable(reverse)
public func zipWith14_canonical(_ inputs: Inputs14) -> [Float] {
    differentiableZipWith(
        inputs.c1, inputs.c2, inputs.c3, inputs.c4, inputs.c5, inputs.c6, inputs.c7, inputs.c8, inputs.c9, inputs.c10, inputs.c11,
        inputs.c12, inputs.c13, inputs.c14
    ) { $0 * $1 + $2 * $3 + $4 * $5 + $6 * $7 + $8 * $9 + $10 * $11 + $12 * $13 }
}

@differentiable(reverse)
public func zipWith8_fused(_ inputs: Inputs8) -> [Float] {
    fusedZip(
        inputs.c1, inputs.c2, inputs.c3, inputs.c4, inputs.c5, inputs.c6, inputs.c7, inputs.c8
    ) { $0 * $1 + $2 * $3 + $4 * $5 + $6 * $7 }
}

// MARK: - Fused arity coverage

@differentiable(reverse)
public func zipWith3_fused(_ inputs: Inputs3) -> [Float] {
    fusedZip(
        inputs.c1, inputs.c2, inputs.c3
    ) { $0 * $1 + $2 }
}

@differentiable(reverse)
public func zipWith4_fused(_ inputs: Inputs4) -> [Float] {
    fusedZip(
        inputs.c1, inputs.c2, inputs.c3, inputs.c4
    ) { $0 * $1 + $2 * $3 }
}

@differentiable(reverse)
public func zipWith14_fused(_ inputs: Inputs14) -> [Float] {
    fusedZip(
        inputs.c1, inputs.c2, inputs.c3, inputs.c4, inputs.c5, inputs.c6, inputs.c7, inputs.c8, inputs.c9, inputs.c10, inputs.c11,
        inputs.c12, inputs.c13, inputs.c14
    ) { $0 * $1 + $2 * $3 + $4 * $5 + $6 * $7 + $8 * $9 + $10 * $11 + $12 * $13 }
}

// MARK: - Cliff bisection (arities 10, 12)

public struct Inputs10: Differentiable {
    public var c1, c2, c3, c4, c5, c6, c7, c8, c9, c10: [Float]

    public init(n: Int) {
        c1 = makeInput(n, seed: 1)
        c2 = makeInput(n, seed: 2)
        c3 = makeInput(n, seed: 3)
        c4 = makeInput(n, seed: 4)
        c5 = makeInput(n, seed: 5)
        c6 = makeInput(n, seed: 6)
        c7 = makeInput(n, seed: 7)
        c8 = makeInput(n, seed: 8)
        c9 = makeInput(n, seed: 9)
        c10 = makeInput(n, seed: 10)
    }
}

@differentiable(reverse)
public func zipWith10_canonical(_ inputs: Inputs10) -> [Float] {
    differentiableZipWith(
        inputs.c1, inputs.c2, inputs.c3, inputs.c4, inputs.c5, inputs.c6, inputs.c7, inputs.c8, inputs.c9, inputs.c10
    ) { $0 * $1 + $2 * $3 + $4 * $5 + $6 * $7 + $8 * $9 }
}

@differentiable(reverse)
public func zipWith10_fused(_ inputs: Inputs10) -> [Float] {
    fusedZip(
        inputs.c1, inputs.c2, inputs.c3, inputs.c4, inputs.c5, inputs.c6, inputs.c7, inputs.c8, inputs.c9, inputs.c10
    ) { $0 * $1 + $2 * $3 + $4 * $5 + $6 * $7 + $8 * $9 }
}

public struct Inputs12: Differentiable {
    public var c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12: [Float]

    public init(n: Int) {
        c1 = makeInput(n, seed: 1)
        c2 = makeInput(n, seed: 2)
        c3 = makeInput(n, seed: 3)
        c4 = makeInput(n, seed: 4)
        c5 = makeInput(n, seed: 5)
        c6 = makeInput(n, seed: 6)
        c7 = makeInput(n, seed: 7)
        c8 = makeInput(n, seed: 8)
        c9 = makeInput(n, seed: 9)
        c10 = makeInput(n, seed: 10)
        c11 = makeInput(n, seed: 11)
        c12 = makeInput(n, seed: 12)
    }
}

@differentiable(reverse)
public func zipWith12_canonical(_ inputs: Inputs12) -> [Float] {
    differentiableZipWith(
        inputs.c1, inputs.c2, inputs.c3, inputs.c4, inputs.c5, inputs.c6, inputs.c7, inputs.c8, inputs.c9, inputs.c10, inputs.c11,
        inputs.c12
    ) { $0 * $1 + $2 * $3 + $4 * $5 + $6 * $7 + $8 * $9 + $10 * $11 }
}

@differentiable(reverse)
public func zipWith12_fused(_ inputs: Inputs12) -> [Float] {
    fusedZip(
        inputs.c1, inputs.c2, inputs.c3, inputs.c4, inputs.c5, inputs.c6, inputs.c7, inputs.c8, inputs.c9, inputs.c10, inputs.c11,
        inputs.c12
    ) { $0 * $1 + $2 * $3 + $4 * $5 + $6 * $7 + $8 * $9 + $10 * $11 }
}
