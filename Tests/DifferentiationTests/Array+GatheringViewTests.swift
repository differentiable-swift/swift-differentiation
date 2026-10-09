import Differentiation
import Testing

/// `RandomAccessCollection` is a complexity promise, so the conformance itself is worth pinning:
/// without it `count`, `distance` and `index(_:offsetBy:)` silently fall back to O(n) walks. A
/// generic constraint checks it at compile time, where dropping the conformance is a build error.
private func requireRandomAccess(_: some RandomAccessCollection) {}

/// An element whose tangent is not itself, which `gather(at:)` cannot handle but
/// `gatheringView(at:)` can.
private struct Celsius: Differentiable {
    var degrees: Double

    struct TangentVector: Differentiable & AdditiveArithmetic {
        var degrees: Double
        typealias TangentVector = Self
    }

    mutating func move(by offset: TangentVector) { self.degrees += offset.degrees }
}

struct ArrayGatheringViewTests {
    // MARK: - Forward

    @Test func gatheringViewReadsThroughIndices() {
        let array: [Float] = [1.0, 2.0, 3.0, 4.0]
        let view = array.gatheringView(at: [2, 0, 2])

        // Element j is base[indices[j]], not base[j]. Reading positionally
        // would give [3.0, 2.0, 1.0] here and [1.0, 2.0, 3.0] if the index
        // array were ignored altogether.
        #expect(view[0] == 3.0)
        #expect(view[1] == 1.0)
        #expect(view[2] == 3.0)

        // Iteration must agree with subscripting.
        #expect(Array(view) == [3.0, 1.0, 3.0])
    }

    @Test func gatheringViewMatchesGather() {
        let array: [Float] = [1.0, 2.0, 3.0, 4.0]
        for indices in [[2, 0, 2], [3, 2, 1, 0], [0], [1, 1, 1], []] {
            #expect(Array(array.gatheringView(at: indices)) == array.gather(at: indices))
        }
    }

    @Test func gatheringViewEmpty() {
        let array: [Float] = [1.0, 2.0, 3.0, 4.0]
        let view = array.gatheringView(at: [])
        #expect(view.isEmpty)
        #expect(view.count == 0)
        #expect(Array(view) == [])
    }

    @Test func gatheringViewOverEmptyBase() {
        let array: [Float] = []
        let view = array.gatheringView(at: [])
        #expect(view.isEmpty)
        #expect(Array(view) == [])
    }

    // MARK: - Collection conformance

    @Test func gatheringViewIndexSpace() {
        let array: [Float] = [1.0, 2.0, 3.0, 4.0]
        let view = array.gatheringView(at: [2, 0, 2])

        // The view's index space is its own positions, not the base's and not
        // the gathering indices.
        #expect(view.startIndex == 0)
        #expect(view.endIndex == 3)
        #expect(view.count == 3)
        #expect(view.indices == 0 ..< 3)
        #expect(view.indices == view.startIndex ..< view.endIndex)
        #expect(!view.isEmpty)
    }

    @Test func gatheringViewIsRandomAccess() {
        let array: [Float] = [1.0, 2.0, 3.0, 4.0]
        let view = array.gatheringView(at: [3, 2, 1, 0])

        requireRandomAccess(view)

        #expect(view.distance(from: 0, to: 3) == 3)
        #expect(view.index(0, offsetBy: 2) == 2)
        #expect(view.index(3, offsetBy: -2) == 1)
        #expect(view.index(0, offsetBy: 9, limitedBy: 4) == nil)
        #expect(view.index(before: 2) == 1)
        #expect(view.first == 4.0)
        #expect(view.last == 1.0)
        #expect(Array(view.reversed()) == [1.0, 2.0, 3.0, 4.0])
    }

    @Test func gatheringViewSlice() {
        let array: [Float] = [1.0, 2.0, 3.0, 4.0]
        let view = array.gatheringView(at: [3, 2, 1, 0])
        let slice = view[1 ..< 3]

        requireRandomAccess(slice)

        #expect(Array(slice) == [3.0, 2.0])
        #expect(slice.startIndex == 1)
    }

    // MARK: - Derivative

    @Test func vjpgatheringView() {
        let array: [Float] = [1.0, 2.0, 3.0, 4.0]
        let (value, pullback) = array._vjpGatheringView(at: [2, 0, 2])

        #expect(Array(value) == [3.0, 1.0, 3.0])

        // Same VJP as the materializing gather: index 2 appears twice, so its
        // incoming cotangents accumulate.
        let dBase = pullback([10.0, 20.0, 30.0])
        #expect(dBase.count == 4)
        #expect(dBase == [20.0, 0.0, 40.0, 0.0])
    }

    @Test func vjpGatheringViewEmptyTangent() {
        let array: [Float] = [1.0, 2.0, 3.0, 4.0]
        let (_, pullback) = array._vjpGatheringView(at: [2, 0, 2])
        #expect(pullback([]) == [])
    }

    @Test func vjpGatheringViewWrongSizedTangent() async {
        await #expect(processExitsWith: .failure) {
            let array: [Float] = [1.0, 2.0, 3.0, 4.0]
            let (_, pullback) = array._vjpGatheringView(at: [2, 0, 2])
            _ = pullback([1.0, 2.0])
        }
    }

    @Test func vjpGatheringViewNonSelfTangentElement() {
        // `gather(at:)` requires `Element.TangentVector == Element`; the view does not, so an
        // element with a distinct tangent type has to survive the round trip.
        let array = [Celsius(degrees: 1.0), Celsius(degrees: 2.0), Celsius(degrees: 3.0)]
        let (value, pullback) = array._vjpGatheringView(at: [2, 0, 2])

        #expect(value.map(\.degrees) == [3.0, 1.0, 3.0])

        let dBase = pullback([
            Celsius.TangentVector(degrees: 10.0),
            Celsius.TangentVector(degrees: 20.0),
            Celsius.TangentVector(degrees: 30.0),
        ])
        #expect(dBase.base.map(\.degrees) == [20.0, 0.0, 40.0])
    }

    // MARK: - Under differentiation

    /// The forward projection and the pullback must agree about which elements were read. A
    /// subscript that ignored the gathering indices would still produce a plausible value and a
    /// plausible gradient — they would just be the value and gradient of a different function.
    /// Only a comparison against the materializing `gather` catches that, so compare both halves.
    ///
    /// Going through `valueWithPullback` rather than calling `_vjpGatheringView` directly is the
    /// point: it is what exercises the `@derivative` registration, which a direct call bypasses.
    @Test func gatheringViewAgreesWithGatherUnderDifferentiation() {
        let array: [Double] = [1.0, 2.0, 3.0, 4.0, 5.0]
        let indices = [4, 1, 4, 0]
        let weights: [Double] = [2.0, 3.0, 5.0, 7.0]

        let viewRun = valueWithPullback(at: array) { source in
            differentiableZipWith(source.gatheringView(at: indices), weights) { value, weight in value * weight }
        }
        let gatherRun = valueWithPullback(at: array) { source in
            differentiableZipWith(source.gather(at: indices), weights) { value, weight in value * weight }
        }

        #expect(viewRun.value == gatherRun.value)
        #expect(viewRun.value == [10.0, 6.0, 25.0, 7.0])

        let seed: [Double].TangentVector = [1.0, 1.0, 1.0, 1.0]
        let viewGradient = viewRun.pullback(seed)
        #expect(viewGradient == gatherRun.pullback(seed))
        // Index 4 is read twice, with weights 2 and 5.
        #expect(viewGradient == [7.0, 3.0, 0.0, 0.0, 7.0])
    }

    @Test func gatheringViewDifferentiatesThroughDuplicateIndices() {
        let array: [Double] = [1.0, 2.0, 3.0]
        let run = valueWithPullback(at: array) { source in
            differentiableZipWith(source.gatheringView(at: [1, 1, 1]), [1.0, 1.0, 1.0]) { value, one in value * one }
        }
        #expect(run.value == [2.0, 2.0, 2.0])
        #expect(run.pullback([1.0, 1.0, 1.0]) == [0.0, 3.0, 0.0])
    }

    // MARK: - Documented traps

    @Test func gatheringViewMoveByTraps() async {
        await #expect(processExitsWith: .failure) {
            var view = [1.0, 2.0, 3.0].gatheringView(at: [0, 1])
            view.move(by: [1.0, 1.0])
        }
    }
}
