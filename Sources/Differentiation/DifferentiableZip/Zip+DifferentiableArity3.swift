// MARK: Zip3SequenceDifferentiable@inlinable
public func differentiableZip<Collection1, Collection2, Collection3>(_ collection1: Collection1,
_ collection2: Collection2,
_ collection3: Collection3
) -> Zip3SequenceDifferentiable<Collection1, Collection2, Collection3> {
    Zip3SequenceDifferentiable(collection1, collection2, collection3)
}

@frozen
public struct Zip3SequenceDifferentiable<Collection1: Collection, Collection2: Collection, Collection3: Collection> where Collection1.Index == Int, Collection2.Index == Int, Collection3.Index == Int {@usableFromInline
internal var _collection1: Collection1
@usableFromInline
internal var _collection2: Collection2
@usableFromInline
internal var _collection3: Collection3
    @inlinable
    internal init(_ collection1: Collection1,
_ collection2: Collection2,
_ collection3: Collection3    ) {self._collection1 = collection1
self._collection2 = collection2
self._collection3 = collection3
    }
}

extension Zip3SequenceDifferentiable: Collection {
    public typealias Element = (Collection1.Element, Collection2.Element, Collection3.Element)
    public typealias Index = Int

    @inlinable
    public var startIndex: Int { 0 }
    @inlinable
    public var endIndex: Int {
        Swift.min(_collection1.count, _collection2.count, _collection3.count)
    }
    
    @inlinable
    public subscript(index: Int) -> Element {
        (_collection1[index], _collection2[index], _collection3[index])
    }

    @inlinable
    public func index(after index: Int) -> Int {
        index + 1
    }

    @inlinable
    public func formIndex(after i: inout Int) {
        i += 1
    }

}

extension Zip3SequenceDifferentiable: Sendable where Collection1: Sendable,
Collection2: Sendable,
Collection3: Sendable{}
// MARK: Zip3SequenceDifferentiable + Differentiable

#if canImport(_Differentiation)

@derivative(of: differentiableZip)
@inlinable
public func _vjpDifferentiableZip<Collection1, Collection2, Collection3>(_ collection1: Collection1,
_ collection2: Collection2,
_ collection3: Collection3
) -> (
    value: Zip3SequenceDifferentiable<Collection1, Collection2, Collection3>,
    pullback: (Zip3SequenceDifferentiable<Collection1, Collection2, Collection3>.TangentVector) -> (Collection1.TangentVector, Collection2.TangentVector, Collection3.TangentVector)
) where
Collection1: Differentiable,
Collection1.Element: Differentiable,
Collection1.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
Collection1.TangentVector.Index == Int,
Collection1.TangentVector.Element == Collection1.Element.TangentVector,
Collection2: Differentiable,
Collection2.Element: Differentiable,
Collection2.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
Collection2.TangentVector.Index == Int,
Collection2.TangentVector.Element == Collection2.Element.TangentVector,
Collection3: Differentiable,
Collection3.Element: Differentiable,
Collection3.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
Collection3.TangentVector.Index == Int,
Collection3.TangentVector.Element == Collection3.Element.TangentVector{
    (
        value: differentiableZip(collection1, collection2, collection3),
        pullback: { v in
            (v.collection1, v.collection2, v.collection3)
        }
    )
}

extension Zip3SequenceDifferentiable: Differentiable where
Collection1: Differentiable,
Collection1.Element: Differentiable,
Collection1.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
Collection1.TangentVector.Index == Int,
Collection1.TangentVector.Element == Collection1.Element.TangentVector,
Collection2: Differentiable,
Collection2.Element: Differentiable,
Collection2.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
Collection2.TangentVector.Index == Int,
Collection2.TangentVector.Element == Collection2.Element.TangentVector,
Collection3: Differentiable,
Collection3.Element: Differentiable,
Collection3.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
Collection3.TangentVector.Index == Int,
Collection3.TangentVector.Element == Collection3.Element.TangentVector
{
    @inlinable
    public mutating func move(by offset: TangentVector) {_collection1.move(by: offset.collection1)
_collection2.move(by: offset.collection2)
_collection3.move(by: offset.collection3)    }

    @inlinable
    public func differentiableMap<Result: Differentiable>(_ transform: @differentiable(reverse) (Collection1.Element, Collection2.Element, Collection3.Element) -> Result
    ) -> [Result] {
        self.map(transform)
    }

    @derivative(of: differentiableMap)
    @inlinable
    public func _vjpDifferentiableMap<Result: Differentiable>(_ transform: @differentiable(reverse) (Collection1.Element, Collection2.Element, Collection3.Element) -> Result
    ) -> (value: [Result], pullback: ([Result].TangentVector) -> TangentVector) {
        var results: [Result] = []
        results.reserveCapacity(self.count)
        var pullbacks: [(Result.TangentVector) -> (Collection1.Element.TangentVector, Collection2.Element.TangentVector, Collection3.Element.TangentVector)] = []
        pullbacks.reserveCapacity(self.count)

        for parameters in self {
            let (value, pullback) = valueWithPullback(at: parameters.0, parameters.1, parameters.2, of: transform)
            results.append(value)
            pullbacks.append(pullback)
        }

        return (
            value: results,
            pullback: { v in
var results1 = Collection1.TangentVector()
results1.reserveCapacity(v.count)
var results2 = Collection2.TangentVector()
results2.reserveCapacity(v.count)
var results3 = Collection3.TangentVector()
results3.reserveCapacity(v.count)
    // thoughts should Repeated tangentvector be a collection instead of also value + count alone? Will that make things easier?
    // we can't do append on a Repeated object so we either have to generate it from a single scope or not at all
    for (tangentElement, pullback) in zip(v, pullbacks) {
        let (result1, result2, result3) = pullback(tangentElement)
results1.appendContribution(of: result1)
results2.appendContribution(of: result2)
results3.appendContribution(of: result3)
                }

                return TangentVector(results1, results2, results3)
            }
        )
    }
}
extension Zip3SequenceDifferentiable {
    public struct TangentVector: Collection & Differentiable & AdditiveArithmetic where Collection1: Differentiable,
Collection1.TangentVector: Collection,
Collection1.TangentVector.Index == Int,
Collection2: Differentiable,
Collection2.TangentVector: Collection,
Collection2.TangentVector.Index == Int,
Collection3: Differentiable,
Collection3.TangentVector: Collection,
Collection3.TangentVector.Index == Int
    {
        public typealias TangentVector = Self
        public typealias Element = (Collection1.TangentVector.Element, Collection2.TangentVector.Element, Collection3.TangentVector.Element)
        public typealias Index = Int

        @inlinable
        public var startIndex: Int { 0 }
        @inlinable
        public var endIndex: Int { 
            Swift.min(collection1.count, collection2.count, collection3.count)
        }
        
        @inlinable
        public subscript(index: Int) -> Element {
            (collection1[index], collection2[index], collection3[index])
        }
    
        @inlinable
        public func index(after index: Int) -> Int {
            index + 1
        }

        @inlinable
        public func formIndex(after i: inout Int) {
            i += 1
        }
@usableFromInline
var collection1: Collection1.TangentVector
@usableFromInline
var collection2: Collection2.TangentVector
@usableFromInline
var collection3: Collection3.TangentVector
        @inlinable
        init(_ collection1: Collection1.TangentVector, _ collection2: Collection2.TangentVector, _ collection3: Collection3.TangentVector) {self.collection1 = collection1
self.collection2 = collection2
self.collection3 = collection3        }

    }
}

@inlinable
public func differentiableZipWith<Collection1, Collection2, Collection3, Result>(_ c1: Collection1,
_ c2: Collection2,
_ c3: Collection3,    with transform: @differentiable(reverse) (Collection1.Element, Collection2.Element, Collection3.Element) -> Result
) -> [Result] where
Collection1: DifferentiableCollection,
Collection1.Element: Differentiable,
Collection2: DifferentiableCollection,
Collection2.Element: Differentiable,
Collection3: DifferentiableCollection,
Collection3.Element: Differentiable,    Result: Differentiable
{
    let capacity = min(c1.count, c2.count, c3.count)
    
    if capacity == 0 { return [] }
    
    var results = ContiguousArray<Result>()
    results.reserveCapacity(capacity)
var c1i = c1.startIndex
var c2i = c2.startIndex
var c3i = c3.startIndex    
    for _ in 0 ..< capacity {
        results.append(transform(c1[c1i], c2[c2i], c3[c3i]))
c1.formIndex(after: &c1i)
c2.formIndex(after: &c2i)
c3.formIndex(after: &c3i)
    }
    
    return Array(results)
}

@derivative(of: differentiableZipWith)
@inlinable
public func _vjpDifferentiableZipWith<Collection1, Collection2, Collection3, Result>(_ c1: Collection1,
_ c2: Collection2,
_ c3: Collection3,    with transform: @differentiable(reverse) (Collection1.Element, Collection2.Element, Collection3.Element) -> Result
) -> (value: [Result], pullback: ([Result].TangentVector) -> (Collection1.TangentVector, Collection2.TangentVector, Collection3.TangentVector)) where
Collection1: DifferentiableCollection,
Collection1.Element: Differentiable,
Collection2: DifferentiableCollection,
Collection2.Element: Differentiable,
Collection3: DifferentiableCollection,
Collection3.Element: Differentiable,
    Result: Differentiable
{
    let count = min(c1.count, c2.count, c3.count)
    
    if count == 0 {
        return (value: [], pullback: { v in (Collection1.TangentVector(), Collection2.TangentVector(), Collection3.TangentVector()) })
    }
    
    var results = ContiguousArray<Result>()
    results.reserveCapacity(count)
    var pullbacks: ContiguousArray<(Result.TangentVector) -> (Collection1.Element.TangentVector, Collection2.Element.TangentVector, Collection3.Element.TangentVector)> = []
    pullbacks.reserveCapacity(count)
var c1i = c1.startIndex
var c2i = c2.startIndex
var c3i = c3.startIndex    
    for _ in 0 ..< count {
        let (value, pullback) = valueWithPullback(at: c1[c1i], c2[c2i], c3[c3i], of: transform)
        
        results.append(value)
        pullbacks.append(pullback)
c1.formIndex(after: &c1i)
c2.formIndex(after: &c2i)
c3.formIndex(after: &c3i)
    }
    
    return (
        value: Array(results),
        pullback: { v in
var results1 = Collection1.TangentVector()
results1.reserveCapacity(v.count)
var results2 = Collection2.TangentVector()
results2.reserveCapacity(v.count)
var results3 = Collection3.TangentVector()
results3.reserveCapacity(v.count)            
            for (tangentElement, pullback) in zip(v, pullbacks) {
                let (v1, v2, v3) = pullback(tangentElement)
results1.appendContribution(of: v1)
results2.appendContribution(of: v2)
results3.appendContribution(of: v3)
            }
            
            return (results1, results2, results3)
        }
    )
}


#endif
