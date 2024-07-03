public struct PVector3: Hashable, Codable {
    public static let zero = Self(0)
    public static let unitX = Self(x: 1, y: 0, z: 0)
    public static let unitY = Self(x: 0, y: 1, z: 0)
    public static let unitZ = Self(x: 0, y: 0, z: 1)

    public typealias Scalar = Double

    public var x: Scalar
    public var y: Scalar
    public var z: Scalar

    public init(x: Scalar, y: Scalar, z: Scalar) {
        self.x = x
        self.y = y
        self.z = z
    }

    public init(_ values: (x: Scalar, y: Scalar, z: Scalar)) {
        self.x = values.x
        self.y = values.y
        self.z = values.z
    }

    public init(_ value: Scalar) {
        self.x = value
        self.y = value
        self.z = value
    }

    public func cross(_ other: Self) -> Self {
        let cx: Scalar =
            PVector2(x: self.y, y: self.z)
            .cross(PVector2(x: other.y, y: other.z))

        let cy: Scalar =
            PVector2(x: self.z, y: self.x)
            .cross(PVector2(x: other.z, y: other.x))

        let cz: Scalar =
            PVector2(x: self.x, y: self.y)
            .cross(PVector2(x: other.x, y: other.y))

        return Self(x: cx, y: cy, z: cz)
    }

    public func dot(_ other: Self) -> Scalar {
        let dx = x * other.x
        let dy = y * other.y
        let dz = z * other.z

        return dx + dy + dz
    }

    public static prefix func - (value: Self) -> Self {
        .init(x: -value.x, y: -value.y, z: -value.z)
    }

    public static func + (lhs: Self, rhs: Self) -> Self {
        op(lhs: lhs, rhs: rhs, +)
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        op(lhs: lhs, rhs: rhs, -)
    }

    public static func * (lhs: Self, rhs: Self) -> Self {
        op(lhs: lhs, rhs: rhs, *)
    }

    public static func * (lhs: Self, rhs: Scalar) -> Self {
        op(lhs: lhs, rhs: rhs, *)
    }

    public static func / (lhs: Self, rhs: Scalar) -> Self {
        op(lhs: lhs, rhs: rhs, /)
    }

    static func op(lhs: Self, rhs: Self, _ op: (Scalar, Scalar) -> Scalar) -> Self {
        .init(x: op(lhs.x, rhs.x), y: op(lhs.y, rhs.y), z: op(lhs.z, rhs.z))
    }

    static func op(lhs: Scalar, rhs: Self, _ op: (Scalar, Scalar) -> Scalar) -> Self {
        .init(x: op(lhs, rhs.x), y: op(lhs, rhs.y), z: op(lhs, rhs.z))
    }

    static func op(lhs: Self, rhs: Scalar, _ op: (Scalar, Scalar) -> Scalar) -> Self {
        .init(x: op(lhs.x, rhs), y: op(lhs.y, rhs), z: op(lhs.z, rhs))
    }
}
