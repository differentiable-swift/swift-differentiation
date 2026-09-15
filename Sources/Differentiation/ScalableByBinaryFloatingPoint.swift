public protocol ScalableByBinaryFloatingPoint {
    func scaled<Scalar>(by scalar: Scalar) -> Self where Scalar: BinaryFloatingPoint
}

extension Double: ScalableByBinaryFloatingPoint {
    @inlinable
    public func scaled<Scalar>(by scalar: Scalar) -> Double where Scalar: BinaryFloatingPoint {
        self * Double(scalar)
    }
}

extension Float: ScalableByBinaryFloatingPoint {
    @inlinable
    public func scaled<Scalar>(by scalar: Scalar) -> Float where Scalar: BinaryFloatingPoint {
        self * Float(scalar)
    }
}
