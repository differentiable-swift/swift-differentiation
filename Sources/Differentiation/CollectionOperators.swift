extension Array where Element: Differentiable  {
    @inlinable
    public func differentiableMap<Result>(into result: inout [Result], _ transform: @differentiable(reverse) (Element) -> Result) {
        for i in 0 ..< count {
            result[i] = transform(self[i])
        }
    }
    
    @derivative(of: differentiableMap(into:_:))
    @inlinable
    public func _vjpDifferentiableMap<Result>(
        into result: inout [Result],
        _ transform: @differentiable(reverse) (Element) -> Result
    ) -> (value: Void, pullback: (inout [Result].TangentVector) -> [Element].TangentVector) {
        let count = self.count
        
        var pullbacks: [(Result.TangentVector) -> Element.TangentVector] = []
        pullbacks.reserveCapacity(count)
        
        for i in 0 ..< count {
            let (value, pullback) = valueWithPullback(at: self[i], of: transform)
            result[i] = value
            pullbacks.append(pullback)
        }
        return (
            value: (),
            pullback: { tangentVector in
                var resultTangentVector: [Element].TangentVector = .init(repeating: .zero, count: count)
                
                for i in 0 ..< count {
                    let element = pullbacks[i](tangentVector[i])
                    resultTangentVector[i] += element
                }
                
                for i in 0 ..< count {
                    tangentVector[i] = .zero
                }
                return resultTangentVector
            }
        )
    }
    
    @available(macOS 26.0, *)
    public struct Cursor<let width: Int, let offset: Int>: Differentiable {
        public typealias TangentVector = Array<Element.TangentVector>.Cursor<width, offset>
        
        @usableFromInline
        var storage: InlineArray<width, Element>
        
        @inlinable
        init(storage: InlineArray<width, Element>) {
            self.storage = storage
        }
        
        @inlinable
        public mutating func move(by offset: TangentVector) {
            storage.move(by: offset.storage)
        }
        
        @inlinable
        public subscript(_ index: Int) -> Element {
            get {
                let offsetIndex = index - offset
                let index = offsetIndex >= 0 ? offsetIndex % width : offsetIndex % width + width
                return storage[index]
            }
            set {
                let offsetIndex = index - offset
                let index = offsetIndex >= 0 ? offsetIndex % width : offsetIndex % width + width
                storage[(index - offset) % width] = newValue
            }
        }
        
        @derivative(of: subscript.get)
        @inlinable
        public func _vjpSubscriptGet(_ index: Int) -> (value: Element, pullback: (Element.TangentVector) -> Cursor<width, offset>.TangentVector) {
            (
                value: self[index],
                pullback: { v in
                    var result = Cursor.TangentVector(storage: InlineArray<width, Element.TangentVector>.init(repeating: .zero))
                    result[index] = v
                    return result
                }
            )
        }
    }
    
    @available(macOS 26.0, *)
    @inlinable
    public func stencil<let cursorWidth: Int, let cursorOffset: Int, Result>(into result: inout [Result], padValue: Element, _ transform: @differentiable(reverse) (Cursor<cursorWidth, cursorOffset>) -> Result) {
        print(cursorOffset)
        let count = self.count
        for i in 0 ..< count {
            
            let storage = InlineArray<cursorWidth, Element> { (outputSpan: inout OutputSpan<Element>) in
                for j in 0 ..< cursorWidth {
                    print(cursorOffset)
                    let index = i + j + cursorOffset
                    if index >= 0 && index < count {
                        outputSpan.append(self[index])
                    } else {
                        outputSpan.append(padValue)
                    }
                }
            }
            let cursor = Cursor<cursorWidth, cursorOffset>(storage: storage)
            result[i] = transform(cursor)
        }
    }
    
    @available(macOS 26.0, *)
    @derivative(of: stencil, wrt: (self, result))
    @inlinable
    public func _vjpStencil<let cursorWidth: Int, let cursorOffset: Int, Result>(into result: inout [Result], padValue: Element, _ transform: @differentiable(reverse) (Cursor<cursorWidth, cursorOffset>) -> Result) -> (value: Void, pullback: (inout [Result].TangentVector) -> ([Element].TangentVector)) {
        
        let count = self.count
        
        var pullbacks: [(Result.TangentVector) -> Cursor<cursorWidth, cursorOffset>.TangentVector] = []
        pullbacks.reserveCapacity(count)
        
        for i in 0 ..< count {
            let storage: InlineArray<cursorWidth, Element> = .init { (outputSpan: inout OutputSpan<Element>) in
                for j in 0 ..< cursorWidth {
                    let index = i + j + cursorOffset
                    if index >= 0 && index < count {
                        outputSpan.append(self[index])
                    } else {
                        outputSpan.append(padValue)
                    }
                }
            }
            let cursor = Cursor<cursorWidth, cursorOffset>(storage: storage)
            let (value, pullback) = valueWithPullback(at: cursor, of: transform)
            result[i] = value
            pullbacks.append(pullback)
        }
        
        return (
            value: (),
            pullback: { tangentVector in
                var resultTangentVector: [Element].TangentVector = .init(repeating: .zero, count: count)
                
                for i in 0 ..< count {
                    let cursor = pullbacks[i](tangentVector[i])
                    for j in 0 ..< cursorWidth {
                        let index = i + j + cursorOffset
                        if index >= 0 && index < count {
                            resultTangentVector[index] += cursor[j]
                        }
                    }
                }
                
                for i in 0 ..< count {
                    tangentVector[i] = .zero
                }
                
                return resultTangentVector
            }
        )
    }
    
    mutating func gather1(from source: [Element], at indices: [Int]) {
        precondition(indices.count == self.count)
        precondition(source.count <= self.count)
        for i in 0 ..< self.count {
            self[i] = source[indices[i]]
        }
    }
    
    mutating func gather2(from newValues: [Element], at indices: [Int]) {
        precondition(newValues.count == indices.count)
        precondition(self.count >= newValues.count)
        for (newValue, index) in zip(newValues, indices) {
            self[index] = newValue
        }
    }
}

@available(macOS 26.0, *)
extension Array.Cursor: Equatable where Element: Equatable {
    
}

@available(macOS 26.0, *)
extension Array.Cursor: AdditiveArithmetic where Element: AdditiveArithmetic {
    
}
