// Trimmed copy of fallingwater's DifferentiableOperators (ArrayElementwise.swift):
// just the element-wise add/multiply/divide operators the fusedZipWith benchmark chains together.

import Differentiation

infix operator .*: MultiplicationPrecedence
infix operator ./: MultiplicationPrecedence
infix operator .+: AdditionPrecedence

// MARK: - Element-wise add

@inlinable
@differentiable(reverse)
public func elementwiseAdd<C1, C2>(_ lhs: C1, _ rhs: C2) -> [Double]
where C1: DifferentiableCollection, C2: DifferentiableCollection, C1.Element == Double, C2.Element == Double {
    let n = Swift.min(lhs.count, rhs.count)
    return Array(unsafeUninitializedCapacity: n) { buffer, initializedCount in
        var il = lhs.startIndex
        var ir = rhs.startIndex
        for i in 0 ..< n {
            buffer.initializeElement(at: i, to: lhs[il] + rhs[ir])
            il = lhs.index(after: il)
            ir = rhs.index(after: ir)
        }
        initializedCount = n
    }
}

@inlinable
@derivative(of: elementwiseAdd)
public func _vjpElementwiseAdd<C1, C2>(
    _ lhs: C1,
    _ rhs: C2
) -> (
    value: [Double],
    pullback: ([Double].TangentVector) -> (C1.TangentVector, C2.TangentVector)
)
where C1: DifferentiableCollection, C2: DifferentiableCollection, C1.Element == Double, C2.Element == Double
{
    let lhsCount = lhs.count
    let rhsCount = rhs.count
    let n = Swift.min(lhsCount, rhsCount)
    return (
        value: elementwiseAdd(lhs, rhs),
        pullback: { dOut in
            let d = dOut.base
            let limit = Swift.min(n, d.count)

            let dL = C1.TangentVector(count: lhsCount) { i in i < limit ? d[i] : 0 }
            let dR = C2.TangentVector(count: rhsCount) { i in i < limit ? d[i] : 0 }

            return (dL, dR)
        }
    )
}

@inlinable
@differentiable(reverse)
public func .+ <C1, C2>(lhs: C1, rhs: C2) -> [Double]
where C1: DifferentiableCollection, C2: DifferentiableCollection, C1.Element == Double, C2.Element == Double {
    elementwiseAdd(lhs, rhs)
}

// MARK: - Element-wise multiply

@inlinable
@differentiable(reverse)
public func elementwiseMultiply<C1, C2>(_ lhs: C1, _ rhs: C2) -> [Double]
where C1: DifferentiableCollection, C2: DifferentiableCollection, C1.Element == Double, C2.Element == Double {
    let n = Swift.min(lhs.count, rhs.count)
    return Array(unsafeUninitializedCapacity: n) { buffer, initializedCount in
        var il = lhs.startIndex
        var ir = rhs.startIndex
        for i in 0 ..< n {
            buffer.initializeElement(at: i, to: lhs[il] * rhs[ir])
            il = lhs.index(after: il)
            ir = rhs.index(after: ir)
        }
        initializedCount = n
    }
}

@inlinable
@derivative(of: elementwiseMultiply)
public func _vjpElementwiseMultiply<C1, C2>(
    _ lhs: C1,
    _ rhs: C2
) -> (
    value: [Double],
    pullback: ([Double].TangentVector) -> (C1.TangentVector, C2.TangentVector)
)
where C1: DifferentiableCollection, C2: DifferentiableCollection, C1.Element == Double, C2.Element == Double
{
    let lhsSaved = lhs
    let rhsSaved = rhs
    let lhsCount = lhs.count
    let rhsCount = rhs.count
    let n = Swift.min(lhsCount, rhsCount)
    return (
        value: elementwiseMultiply(lhs, rhs),
        pullback: { dOut in
            let d = dOut.base
            let limit = Swift.min(n, d.count)

            // dL[i] = d[i]·rhs[i]; walk `rhs` in lockstep (element is called in index order).
            var ir = rhsSaved.startIndex
            let dL = C1.TangentVector(count: lhsCount) { i in
                guard i < limit else { return 0 }
                defer { ir = rhsSaved.index(after: ir) }
                return d[i] * rhsSaved[ir]
            }
            // dR[i] = d[i]·lhs[i]; walk `lhs` in lockstep.
            var il = lhsSaved.startIndex
            let dR = C2.TangentVector(count: rhsCount) { i in
                guard i < limit else { return 0 }
                defer { il = lhsSaved.index(after: il) }
                return d[i] * lhsSaved[il]
            }

            return (dL, dR)
        }
    )
}

@inlinable
@differentiable(reverse)
public func .* <C1, C2>(lhs: C1, rhs: C2) -> [Double]
where C1: DifferentiableCollection, C2: DifferentiableCollection, C1.Element == Double, C2.Element == Double {
    elementwiseMultiply(lhs, rhs)
}

// MARK: - Element-wise divide

@inlinable
@differentiable(reverse)
public func elementwiseDivide<C1, C2>(_ lhs: C1, _ rhs: C2) -> [Double]
where C1: DifferentiableCollection, C2: DifferentiableCollection, C1.Element == Double, C2.Element == Double {
    let n = Swift.min(lhs.count, rhs.count)
    return Array(unsafeUninitializedCapacity: n) { buffer, initializedCount in
        var il = lhs.startIndex
        var ir = rhs.startIndex
        for i in 0 ..< n {
            buffer.initializeElement(at: i, to: lhs[il] / rhs[ir])
            il = lhs.index(after: il)
            ir = rhs.index(after: ir)
        }
        initializedCount = n
    }
}

@inlinable
@derivative(of: elementwiseDivide)
public func _vjpElementwiseDivide<C1, C2>(
    _ lhs: C1,
    _ rhs: C2
) -> (
    value: [Double],
    pullback: ([Double].TangentVector) -> (C1.TangentVector, C2.TangentVector)
)
where C1: DifferentiableCollection, C2: DifferentiableCollection, C1.Element == Double, C2.Element == Double
{
    let lhsSaved = lhs
    let rhsSaved = rhs
    let lhsCount = lhs.count
    let rhsCount = rhs.count
    let n = Swift.min(lhsCount, rhsCount)
    let result = elementwiseDivide(lhs, rhs)
    return (
        value: result,
        pullback: { dOut in
            let d = dOut.base
            let limit = Swift.min(n, d.count)

            // dL[i] = d[i]/rhs[i]; walk `rhs` in lockstep.
            var ir = rhsSaved.startIndex
            let dL = C1.TangentVector(count: lhsCount) { i in
                guard i < limit else { return 0 }
                defer { ir = rhsSaved.index(after: ir) }
                return d[i] / rhsSaved[ir]
            }
            // dR[i] = -d[i]·lhs[i]/rhs[i]²; walk `lhs` and `rhs` in lockstep.
            var ilR = lhsSaved.startIndex
            var irR = rhsSaved.startIndex
            let dR = C2.TangentVector(count: rhsCount) { i in
                guard i < limit else { return 0 }
                defer {
                    ilR = lhsSaved.index(after: ilR)
                    irR = rhsSaved.index(after: irR)
                }
                let invR = 1.0 / rhsSaved[irR]
                return -d[i] * lhsSaved[ilR] * invR * invR
            }

            return (dL, dR)
        }
    )
}

@inlinable
@differentiable(reverse)
public func ./ <C1, C2>(lhs: C1, rhs: C2) -> [Double]
where C1: DifferentiableCollection, C2: DifferentiableCollection, C1.Element == Double, C2.Element == Double {
    elementwiseDivide(lhs, rhs)
}
