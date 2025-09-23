import _Differentiation

public struct DArray2<Element: Differentiable>: Differentiable {    
    @usableFromInline
    var storage: [Element]
    
    public struct TangentVector: Differentiable {
        public typealias TangentVector = Self
        @noDerivative
        var storage: TVEnum
        
        enum TVEnum {
            case normal([Element.TangentVector])
        }
    }
    
    public mutating func move(by offset: TangentVector) {

    }
}

extension DArray2: Equatable where Element: Equatable { }

extension DArray2.TangentVector: Equatable where Element.TangentVector: Equatable { }
extension DArray2.TangentVector: AdditiveArithmetic where Element.TangentVector: AdditiveArithmetic { }

extension DArray2.TangentVector.TVEnum: Equatable where Element.TangentVector: Equatable { }

extension DArray2.TangentVector.TVEnum: AdditiveArithmetic where Element.TangentVector: AdditiveArithmetic {
    static var zero: DArray2<Element>.TangentVector.TVEnum {
        .normal([])
    }
    
    static func + (lhs: DArray2<Element>.TangentVector.TVEnum, rhs: DArray2<Element>.TangentVector.TVEnum) -> DArray2<Element>.TangentVector.TVEnum {
        fatalError()
    }
    
    static func - (lhs: DArray2<Element>.TangentVector.TVEnum, rhs: DArray2<Element>.TangentVector.TVEnum) -> DArray2<Element>.TangentVector.TVEnum {
        fatalError()
    }
}
