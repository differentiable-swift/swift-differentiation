import Differentiation
import Testing

@Suite("Array.DifferentiableView mutations")
struct ArrayDifferentiableViewMutationTests {
    @Test("append adds an element to the base")
    func append() {
        var view = Array<Float>.DifferentiableView([1, 2, 3])
        view.append(4)
        #expect(view.base == [1, 2, 3, 4])
    }

    @Test("append(contentsOf:) adds all elements in order")
    func appendContentsOf() {
        var view = Array<Float>.DifferentiableView([1, 2])
        view.append(contentsOf: [3, 4, 5])
        #expect(view.base == [1, 2, 3, 4, 5])
    }

    @Test("remove(at:) removes and returns the element")
    func removeAt() {
        var view = Array<Float>.DifferentiableView([1, 2, 3])
        let removed = view.remove(at: 1)
        #expect(removed == 2)
        #expect(view.base == [1, 3])
    }

    @Test("reserveCapacity reserves storage on the base array")
    func reserveCapacity() {
        var view = Array<Float>.DifferentiableView([])
        #expect(view.base.capacity < 100)
        view.reserveCapacity(100)
        #expect(view.base.capacity >= 100)
    }

    /// Guards against the mutations silently rebinding to `RangeReplaceableCollection`'s default
    /// implementations when invoked through a generic context: the default `reserveCapacity` is a
    /// no-op, and the default `append` routes through `replaceSubrange`.
    @Test("mutations behave the same through a generic RangeReplaceableCollection context")
    func mutationsThroughGenericContext() {
        func appendAndReserve<C: RangeReplaceableCollection>(_ element: C.Element, capacity: Int, on collection: inout C) {
            collection.reserveCapacity(capacity)
            collection.append(element)
        }

        var view = Array<Float>.DifferentiableView([1, 2])
        #expect(view.base.capacity < 100)
        appendAndReserve(3, capacity: 100, on: &view)
        #expect(view.base == [1, 2, 3])
        #expect(view.base.capacity >= 100)
    }
}

@Suite("ContiguousArray.DifferentiableView mutations")
struct ContiguousArrayDifferentiableViewMutationTests {
    @Test("append adds an element to the base")
    func append() {
        var view = ContiguousArray<Float>.DifferentiableView([1, 2, 3])
        view.append(4)
        #expect(view.base == [1, 2, 3, 4])
    }

    @Test("append(contentsOf:) adds all elements in order")
    func appendContentsOf() {
        var view = ContiguousArray<Float>.DifferentiableView([1, 2])
        view.append(contentsOf: [3, 4, 5])
        #expect(view.base == [1, 2, 3, 4, 5])
    }

    @Test("remove(at:) removes and returns the element")
    func removeAt() {
        var view = ContiguousArray<Float>.DifferentiableView([1, 2, 3])
        let removed = view.remove(at: 1)
        #expect(removed == 2)
        #expect(view.base == [1, 3])
    }

    @Test("reserveCapacity reserves storage on the base array")
    func reserveCapacity() {
        var view = ContiguousArray<Float>.DifferentiableView([])
        #expect(view.base.capacity < 100)
        view.reserveCapacity(100)
        #expect(view.base.capacity >= 100)
    }
}

@Suite("ArraySlice.DifferentiableView mutations")
struct ArraySliceDifferentiableViewMutationTests {
    @Test("append adds an element to the base")
    func append() {
        var view = ArraySlice<Float>.DifferentiableView([1, 2, 3])
        view.append(4)
        #expect(view.base.elementsEqual([1, 2, 3, 4]))
    }

    @Test("append(contentsOf:) adds all elements in order")
    func appendContentsOf() {
        var view = ArraySlice<Float>.DifferentiableView([1, 2])
        view.append(contentsOf: [3, 4, 5])
        #expect(view.base.elementsEqual([1, 2, 3, 4, 5]))
    }

    @Test("remove(at:) removes and returns the element")
    func removeAt() {
        var view = ArraySlice<Float>.DifferentiableView([1, 2, 3])
        let removed = view.remove(at: 1)
        #expect(removed == 2)
        #expect(view.base.elementsEqual([1, 3]))
    }

    @Test("remove(at:) uses the slice's own (non-zero-based) indices")
    func removeAtSliceIndex() {
        let array: [Float] = [0, 1, 2, 3, 4]
        var view = ArraySlice<Float>.DifferentiableView(array[2...])
        let removed = view.remove(at: 3)
        #expect(removed == 3)
        #expect(view.base.elementsEqual([2, 4]))
    }

    @Test("reserveCapacity reserves storage on the base slice")
    func reserveCapacity() {
        var view = ArraySlice<Float>.DifferentiableView([])
        #expect(view.base.capacity < 100)
        view.reserveCapacity(100)
        #expect(view.base.capacity >= 100)
    }
}
