public struct PVector2i: Hashable, Codable {
    static let zero = Self(0)
    public static let unitX = Self(x: 1, y: 0)
    public static let unitY = Self(x: 0, y: 1)

    public typealias Scalar = Int

    public var x: Scalar
    public var y: Scalar

    public init(x: Scalar, y: Scalar) {
        self.x = x
        self.y = y
    }

    public init(_ values: (x: Scalar, y: Scalar)) {
        self.x = values.x
        self.y = values.y
    }

    public init(_ value: Scalar) {
        self.x = value
        self.y = value
    }

    public func dot(_ other: Self) -> Scalar {
        let dx = x * other.x
        let dy = y * other.y

        return dx + dy
    }

    @inlinable
    public static prefix func - (value: Self) -> Self {
        .init(x: -value.x, y: -value.y)
    }

    @inlinable
    public static func + (lhs: Self, rhs: Self) -> Self {
        op(lhs: lhs, rhs: rhs, +)
    }

    @inlinable
    public static func - (lhs: Self, rhs: Self) -> Self {
        op(lhs: lhs, rhs: rhs, -)
    }

    @inlinable
    public static func * (lhs: Self, rhs: Self) -> Self {
        op(lhs: lhs, rhs: rhs, *)
    }

    @inlinable
    public static func * (lhs: Self, rhs: Scalar) -> Self {
        op(lhs: lhs, rhs: rhs, *)
    }

    @inlinable
    static func op(lhs: Self, rhs: Self, _ op: (Scalar, Scalar) -> Scalar) -> Self {
        .init(x: op(lhs.x, rhs.x), y: op(lhs.y, rhs.y))
    }

    @inlinable
    static func op(lhs: Scalar, rhs: Self, _ op: (Scalar, Scalar) -> Scalar) -> Self {
        .init(x: op(lhs, rhs.x), y: op(lhs, rhs.y))
    }

    @inlinable
    static func op(lhs: Self, rhs: Scalar, _ op: (Scalar, Scalar) -> Scalar) -> Self {
        .init(x: op(lhs.x, rhs), y: op(lhs.y, rhs))
    }
}
