extension Array where Element == Float {
    static func random(of size: Int) -> Self {
        (0 ..< size).map { _ in Float.random(in: -1.0E10 ... 1.0E10) }
    }
}
