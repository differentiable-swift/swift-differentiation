// MARK: Zip9SequenceDifferentiable@inlinable
public func differentiableZip<Collection1, Collection2, Collection3, Collection4, Collection5, Collection6, Collection7, Collection8, Collection9>(_ collection1: Collection1,
_ collection2: Collection2,
_ collection3: Collection3,
_ collection4: Collection4,
_ collection5: Collection5,
_ collection6: Collection6,
_ collection7: Collection7,
_ collection8: Collection8,
_ collection9: Collection9
) -> Zip9SequenceDifferentiable<Collection1, Collection2, Collection3, Collection4, Collection5, Collection6, Collection7, Collection8, Collection9> {
    Zip9SequenceDifferentiable(collection1, collection2, collection3, collection4, collection5, collection6, collection7, collection8, collection9)
}

@frozen
public struct Zip9SequenceDifferentiable<Collection1: Collection, Collection2: Collection, Collection3: Collection, Collection4: Collection, Collection5: Collection, Collection6: Collection, Collection7: Collection, Collection8: Collection, Collection9: Collection> where Collection1.Index == Int, Collection2.Index == Int, Collection3.Index == Int, Collection4.Index == Int, Collection5.Index == Int, Collection6.Index == Int, Collection7.Index == Int, Collection8.Index == Int, Collection9.Index == Int {@usableFromInline
internal var _collection1: Collection1
@usableFromInline
internal var _collection2: Collection2
@usableFromInline
internal var _collection3: Collection3
@usableFromInline
internal var _collection4: Collection4
@usableFromInline
internal var _collection5: Collection5
@usableFromInline
internal var _collection6: Collection6
@usableFromInline
internal var _collection7: Collection7
@usableFromInline
internal var _collection8: Collection8
@usableFromInline
internal var _collection9: Collection9
    @inlinable
    internal init(_ collection1: Collection1,
_ collection2: Collection2,
_ collection3: Collection3,
_ collection4: Collection4,
_ collection5: Collection5,
_ collection6: Collection6,
_ collection7: Collection7,
_ collection8: Collection8,
_ collection9: Collection9    ) {self._collection1 = collection1
self._collection2 = collection2
self._collection3 = collection3
self._collection4 = collection4
self._collection5 = collection5
self._collection6 = collection6
self._collection7 = collection7
self._collection8 = collection8
self._collection9 = collection9
    }
}

extension Zip9SequenceDifferentiable: Collection {
    public typealias Element = (Collection1.Element, Collection2.Element, Collection3.Element, Collection4.Element, Collection5.Element, Collection6.Element, Collection7.Element, Collection8.Element, Collection9.Element)
    public typealias Index = Int

    @inlinable
    public var startIndex: Int { 0 }
    @inlinable
    public var endIndex: Int {
        Swift.min(_collection1.count, _collection2.count, _collection3.count, _collection4.count, _collection5.count, _collection6.count, _collection7.count, _collection8.count, _collection9.count)
    }
    
    @inlinable
    public subscript(index: Int) -> Element {
        (_collection1[index], _collection2[index], _collection3[index], _collection4[index], _collection5[index], _collection6[index], _collection7[index], _collection8[index], _collection9[index])
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

extension Zip9SequenceDifferentiable: Sendable where Collection1: Sendable,
Collection2: Sendable,
Collection3: Sendable,
Collection4: Sendable,
Collection5: Sendable,
Collection6: Sendable,
Collection7: Sendable,
Collection8: Sendable,
Collection9: Sendable{}
// MARK: Zip9SequenceDifferentiable + Differentiable

#if canImport(_Differentiation)

@derivative(of: differentiableZip)
@inlinable
public func _vjpDifferentiableZip<Collection1, Collection2, Collection3, Collection4, Collection5, Collection6, Collection7, Collection8, Collection9>(_ collection1: Collection1,
_ collection2: Collection2,
_ collection3: Collection3,
_ collection4: Collection4,
_ collection5: Collection5,
_ collection6: Collection6,
_ collection7: Collection7,
_ collection8: Collection8,
_ collection9: Collection9
) -> (
    value: Zip9SequenceDifferentiable<Collection1, Collection2, Collection3, Collection4, Collection5, Collection6, Collection7, Collection8, Collection9>,
    pullback: (Zip9SequenceDifferentiable<Collection1, Collection2, Collection3, Collection4, Collection5, Collection6, Collection7, Collection8, Collection9>.TangentVector) -> (Collection1.TangentVector, Collection2.TangentVector, Collection3.TangentVector, Collection4.TangentVector, Collection5.TangentVector, Collection6.TangentVector, Collection7.TangentVector, Collection8.TangentVector, Collection9.TangentVector)
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
Collection3.TangentVector.Element == Collection3.Element.TangentVector,
Collection4: Differentiable,
Collection4.Element: Differentiable,
Collection4.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
Collection4.TangentVector.Index == Int,
Collection4.TangentVector.Element == Collection4.Element.TangentVector,
Collection5: Differentiable,
Collection5.Element: Differentiable,
Collection5.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
Collection5.TangentVector.Index == Int,
Collection5.TangentVector.Element == Collection5.Element.TangentVector,
Collection6: Differentiable,
Collection6.Element: Differentiable,
Collection6.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
Collection6.TangentVector.Index == Int,
Collection6.TangentVector.Element == Collection6.Element.TangentVector,
Collection7: Differentiable,
Collection7.Element: Differentiable,
Collection7.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
Collection7.TangentVector.Index == Int,
Collection7.TangentVector.Element == Collection7.Element.TangentVector,
Collection8: Differentiable,
Collection8.Element: Differentiable,
Collection8.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
Collection8.TangentVector.Index == Int,
Collection8.TangentVector.Element == Collection8.Element.TangentVector,
Collection9: Differentiable,
Collection9.Element: Differentiable,
Collection9.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
Collection9.TangentVector.Index == Int,
Collection9.TangentVector.Element == Collection9.Element.TangentVector{
    (
        value: differentiableZip(collection1, collection2, collection3, collection4, collection5, collection6, collection7, collection8, collection9),
        pullback: { v in
            (v.collection1, v.collection2, v.collection3, v.collection4, v.collection5, v.collection6, v.collection7, v.collection8, v.collection9)
        }
    )
}

extension Zip9SequenceDifferentiable: Differentiable where
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
Collection3.TangentVector.Element == Collection3.Element.TangentVector,
Collection4: Differentiable,
Collection4.Element: Differentiable,
Collection4.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
Collection4.TangentVector.Index == Int,
Collection4.TangentVector.Element == Collection4.Element.TangentVector,
Collection5: Differentiable,
Collection5.Element: Differentiable,
Collection5.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
Collection5.TangentVector.Index == Int,
Collection5.TangentVector.Element == Collection5.Element.TangentVector,
Collection6: Differentiable,
Collection6.Element: Differentiable,
Collection6.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
Collection6.TangentVector.Index == Int,
Collection6.TangentVector.Element == Collection6.Element.TangentVector,
Collection7: Differentiable,
Collection7.Element: Differentiable,
Collection7.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
Collection7.TangentVector.Index == Int,
Collection7.TangentVector.Element == Collection7.Element.TangentVector,
Collection8: Differentiable,
Collection8.Element: Differentiable,
Collection8.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
Collection8.TangentVector.Index == Int,
Collection8.TangentVector.Element == Collection8.Element.TangentVector,
Collection9: Differentiable,
Collection9.Element: Differentiable,
Collection9.TangentVector: DifferentiableCollection, // at least needs to be a collection to have an Element associatedtype
Collection9.TangentVector.Index == Int,
Collection9.TangentVector.Element == Collection9.Element.TangentVector
{
    @inlinable
    public mutating func move(by offset: TangentVector) {_collection1.move(by: offset.collection1)
_collection2.move(by: offset.collection2)
_collection3.move(by: offset.collection3)
_collection4.move(by: offset.collection4)
_collection5.move(by: offset.collection5)
_collection6.move(by: offset.collection6)
_collection7.move(by: offset.collection7)
_collection8.move(by: offset.collection8)
_collection9.move(by: offset.collection9)    }

    @inlinable
    public func differentiableMap<Result: Differentiable>(_ transform: @differentiable(reverse) (Collection1.Element, Collection2.Element, Collection3.Element, Collection4.Element, Collection5.Element, Collection6.Element, Collection7.Element, Collection8.Element, Collection9.Element) -> Result
    ) -> [Result] {
        self.map(transform)
    }

    @derivative(of: differentiableMap)
    @inlinable
    public func _vjpDifferentiableMap<Result: Differentiable>(_ transform: @differentiable(reverse) (Collection1.Element, Collection2.Element, Collection3.Element, Collection4.Element, Collection5.Element, Collection6.Element, Collection7.Element, Collection8.Element, Collection9.Element) -> Result
    ) -> (value: [Result], pullback: ([Result].TangentVector) -> TangentVector) {
        var results: [Result] = []
        results.reserveCapacity(self.count)
        var pullbacks: [(Result.TangentVector) -> (Collection1.Element.TangentVector, Collection2.Element.TangentVector, Collection3.Element.TangentVector, Collection4.Element.TangentVector, Collection5.Element.TangentVector, Collection6.Element.TangentVector, Collection7.Element.TangentVector, Collection8.Element.TangentVector, Collection9.Element.TangentVector)] = []
        pullbacks.reserveCapacity(self.count)

        for parameters in self {
            let (value, pullback) = valueWithPullback(at: parameters.0, parameters.1, parameters.2, parameters.3, parameters.4, parameters.5, parameters.6, parameters.7, parameters.8, of: transform)
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
var results4 = Collection4.TangentVector()
results4.reserveCapacity(v.count)
var results5 = Collection5.TangentVector()
results5.reserveCapacity(v.count)
var results6 = Collection6.TangentVector()
results6.reserveCapacity(v.count)
var results7 = Collection7.TangentVector()
results7.reserveCapacity(v.count)
var results8 = Collection8.TangentVector()
results8.reserveCapacity(v.count)
var results9 = Collection9.TangentVector()
results9.reserveCapacity(v.count)
    // thoughts should Repeated tangentvector be a collection instead of also value + count alone? Will that make things easier?
    // we can't do append on a Repeated object so we either have to generate it from a single scope or not at all
    for (tangentElement, pullback) in zip(v, pullbacks) {
        let (result1, result2, result3, result4, result5, result6, result7, result8, result9) = pullback(tangentElement)
results1.appendContribution(of: result1)
results2.appendContribution(of: result2)
results3.appendContribution(of: result3)
results4.appendContribution(of: result4)
results5.appendContribution(of: result5)
results6.appendContribution(of: result6)
results7.appendContribution(of: result7)
results8.appendContribution(of: result8)
results9.appendContribution(of: result9)
                }

                return TangentVector(results1, results2, results3, results4, results5, results6, results7, results8, results9)
            }
        )
    }
}
extension Zip9SequenceDifferentiable {
    public struct TangentVector: Collection & Differentiable & AdditiveArithmetic where Collection1: Differentiable,
Collection1.TangentVector: Collection,
Collection1.TangentVector.Index == Int,
Collection2: Differentiable,
Collection2.TangentVector: Collection,
Collection2.TangentVector.Index == Int,
Collection3: Differentiable,
Collection3.TangentVector: Collection,
Collection3.TangentVector.Index == Int,
Collection4: Differentiable,
Collection4.TangentVector: Collection,
Collection4.TangentVector.Index == Int,
Collection5: Differentiable,
Collection5.TangentVector: Collection,
Collection5.TangentVector.Index == Int,
Collection6: Differentiable,
Collection6.TangentVector: Collection,
Collection6.TangentVector.Index == Int,
Collection7: Differentiable,
Collection7.TangentVector: Collection,
Collection7.TangentVector.Index == Int,
Collection8: Differentiable,
Collection8.TangentVector: Collection,
Collection8.TangentVector.Index == Int,
Collection9: Differentiable,
Collection9.TangentVector: Collection,
Collection9.TangentVector.Index == Int
    {
        public typealias TangentVector = Self
        public typealias Element = (Collection1.TangentVector.Element, Collection2.TangentVector.Element, Collection3.TangentVector.Element, Collection4.TangentVector.Element, Collection5.TangentVector.Element, Collection6.TangentVector.Element, Collection7.TangentVector.Element, Collection8.TangentVector.Element, Collection9.TangentVector.Element)
        public typealias Index = Int

        @inlinable
        public var startIndex: Int { 0 }
        @inlinable
        public var endIndex: Int { 
            Swift.min(collection1.count, collection2.count, collection3.count, collection4.count, collection5.count, collection6.count, collection7.count, collection8.count, collection9.count)
        }
        
        @inlinable
        public subscript(index: Int) -> Element {
            (collection1[index], collection2[index], collection3[index], collection4[index], collection5[index], collection6[index], collection7[index], collection8[index], collection9[index])
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
@usableFromInline
var collection4: Collection4.TangentVector
@usableFromInline
var collection5: Collection5.TangentVector
@usableFromInline
var collection6: Collection6.TangentVector
@usableFromInline
var collection7: Collection7.TangentVector
@usableFromInline
var collection8: Collection8.TangentVector
@usableFromInline
var collection9: Collection9.TangentVector
        @inlinable
        init(_ collection1: Collection1.TangentVector, _ collection2: Collection2.TangentVector, _ collection3: Collection3.TangentVector, _ collection4: Collection4.TangentVector, _ collection5: Collection5.TangentVector, _ collection6: Collection6.TangentVector, _ collection7: Collection7.TangentVector, _ collection8: Collection8.TangentVector, _ collection9: Collection9.TangentVector) {self.collection1 = collection1
self.collection2 = collection2
self.collection3 = collection3
self.collection4 = collection4
self.collection5 = collection5
self.collection6 = collection6
self.collection7 = collection7
self.collection8 = collection8
self.collection9 = collection9        }

    }
}

@inlinable
public func differentiableZipWith<Collection1, Collection2, Collection3, Collection4, Collection5, Collection6, Collection7, Collection8, Collection9, Result>(_ c1: Collection1,
_ c2: Collection2,
_ c3: Collection3,
_ c4: Collection4,
_ c5: Collection5,
_ c6: Collection6,
_ c7: Collection7,
_ c8: Collection8,
_ c9: Collection9,    with transform: @differentiable(reverse) (Collection1.Element, Collection2.Element, Collection3.Element, Collection4.Element, Collection5.Element, Collection6.Element, Collection7.Element, Collection8.Element, Collection9.Element) -> Result
) -> [Result] where
Collection1: DifferentiableCollection,
Collection1.Element: Differentiable,
Collection2: DifferentiableCollection,
Collection2.Element: Differentiable,
Collection3: DifferentiableCollection,
Collection3.Element: Differentiable,
Collection4: DifferentiableCollection,
Collection4.Element: Differentiable,
Collection5: DifferentiableCollection,
Collection5.Element: Differentiable,
Collection6: DifferentiableCollection,
Collection6.Element: Differentiable,
Collection7: DifferentiableCollection,
Collection7.Element: Differentiable,
Collection8: DifferentiableCollection,
Collection8.Element: Differentiable,
Collection9: DifferentiableCollection,
Collection9.Element: Differentiable,    Result: Differentiable
{
    let capacity = min(c1.count, c2.count, c3.count, c4.count, c5.count, c6.count, c7.count, c8.count, c9.count)
    
    if capacity == 0 { return [] }
    
    var results = ContiguousArray<Result>()
    results.reserveCapacity(capacity)
var c1i = c1.startIndex
var c2i = c2.startIndex
var c3i = c3.startIndex
var c4i = c4.startIndex
var c5i = c5.startIndex
var c6i = c6.startIndex
var c7i = c7.startIndex
var c8i = c8.startIndex
var c9i = c9.startIndex    
    for _ in 0 ..< capacity {
        results.append(transform(c1[c1i], c2[c2i], c3[c3i], c4[c4i], c5[c5i], c6[c6i], c7[c7i], c8[c8i], c9[c9i]))
c1.formIndex(after: &c1i)
c2.formIndex(after: &c2i)
c3.formIndex(after: &c3i)
c4.formIndex(after: &c4i)
c5.formIndex(after: &c5i)
c6.formIndex(after: &c6i)
c7.formIndex(after: &c7i)
c8.formIndex(after: &c8i)
c9.formIndex(after: &c9i)
    }
    
    return Array(results)
}

@derivative(of: differentiableZipWith)
@inlinable
public func _vjpDifferentiableZipWith<Collection1, Collection2, Collection3, Collection4, Collection5, Collection6, Collection7, Collection8, Collection9, Result>(_ c1: Collection1,
_ c2: Collection2,
_ c3: Collection3,
_ c4: Collection4,
_ c5: Collection5,
_ c6: Collection6,
_ c7: Collection7,
_ c8: Collection8,
_ c9: Collection9,    with transform: @differentiable(reverse) (Collection1.Element, Collection2.Element, Collection3.Element, Collection4.Element, Collection5.Element, Collection6.Element, Collection7.Element, Collection8.Element, Collection9.Element) -> Result
) -> (value: [Result], pullback: ([Result].TangentVector) -> (Collection1.TangentVector, Collection2.TangentVector, Collection3.TangentVector, Collection4.TangentVector, Collection5.TangentVector, Collection6.TangentVector, Collection7.TangentVector, Collection8.TangentVector, Collection9.TangentVector)) where
Collection1: DifferentiableCollection,
Collection1.Element: Differentiable,
Collection2: DifferentiableCollection,
Collection2.Element: Differentiable,
Collection3: DifferentiableCollection,
Collection3.Element: Differentiable,
Collection4: DifferentiableCollection,
Collection4.Element: Differentiable,
Collection5: DifferentiableCollection,
Collection5.Element: Differentiable,
Collection6: DifferentiableCollection,
Collection6.Element: Differentiable,
Collection7: DifferentiableCollection,
Collection7.Element: Differentiable,
Collection8: DifferentiableCollection,
Collection8.Element: Differentiable,
Collection9: DifferentiableCollection,
Collection9.Element: Differentiable,
    Result: Differentiable
{
    let count = min(c1.count, c2.count, c3.count, c4.count, c5.count, c6.count, c7.count, c8.count, c9.count)
    
    if count == 0 {
        return (value: [], pullback: { v in (Collection1.TangentVector(), Collection2.TangentVector(), Collection3.TangentVector(), Collection4.TangentVector(), Collection5.TangentVector(), Collection6.TangentVector(), Collection7.TangentVector(), Collection8.TangentVector(), Collection9.TangentVector()) })
    }
    
    var results = ContiguousArray<Result>()
    results.reserveCapacity(count)
    var pullbacks: ContiguousArray<(Result.TangentVector) -> (Collection1.Element.TangentVector, Collection2.Element.TangentVector, Collection3.Element.TangentVector, Collection4.Element.TangentVector, Collection5.Element.TangentVector, Collection6.Element.TangentVector, Collection7.Element.TangentVector, Collection8.Element.TangentVector, Collection9.Element.TangentVector)> = []
    pullbacks.reserveCapacity(count)
var c1i = c1.startIndex
var c2i = c2.startIndex
var c3i = c3.startIndex
var c4i = c4.startIndex
var c5i = c5.startIndex
var c6i = c6.startIndex
var c7i = c7.startIndex
var c8i = c8.startIndex
var c9i = c9.startIndex    
    for _ in 0 ..< count {
        let (value, pullback) = valueWithPullback(at: c1[c1i], c2[c2i], c3[c3i], c4[c4i], c5[c5i], c6[c6i], c7[c7i], c8[c8i], c9[c9i], of: transform)
        
        results.append(value)
        pullbacks.append(pullback)
c1.formIndex(after: &c1i)
c2.formIndex(after: &c2i)
c3.formIndex(after: &c3i)
c4.formIndex(after: &c4i)
c5.formIndex(after: &c5i)
c6.formIndex(after: &c6i)
c7.formIndex(after: &c7i)
c8.formIndex(after: &c8i)
c9.formIndex(after: &c9i)
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
var results4 = Collection4.TangentVector()
results4.reserveCapacity(v.count)
var results5 = Collection5.TangentVector()
results5.reserveCapacity(v.count)
var results6 = Collection6.TangentVector()
results6.reserveCapacity(v.count)
var results7 = Collection7.TangentVector()
results7.reserveCapacity(v.count)
var results8 = Collection8.TangentVector()
results8.reserveCapacity(v.count)
var results9 = Collection9.TangentVector()
results9.reserveCapacity(v.count)            
            for (tangentElement, pullback) in zip(v, pullbacks) {
                let (v1, v2, v3, v4, v5, v6, v7, v8, v9) = pullback(tangentElement)
results1.appendContribution(of: v1)
results2.appendContribution(of: v2)
results3.appendContribution(of: v3)
results4.appendContribution(of: v4)
results5.appendContribution(of: v5)
results6.appendContribution(of: v6)
results7.appendContribution(of: v7)
results8.appendContribution(of: v8)
results9.appendContribution(of: v9)
            }
            
            return (results1, results2, results3, results4, results5, results6, results7, results8, results9)
        }
    )
}


#endif
