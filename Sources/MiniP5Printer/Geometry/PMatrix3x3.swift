import Foundation

public struct PMatrix3x3 {
    public typealias Scalar = Double

    /// Returns a 3x3 [identity matrix].
    ///
    /// [identity matrix]: https://en.wikipedia.org/wiki/Identity_matrix
    @inlinable
    public static var identity: Self {
        Self.init(rows: (
            (1, 0, 0),
            (0, 1, 0),
            (0, 0, 1)
        ))
    }

    /// The full type of this matrix's backing, as a tuple of columns.
    public typealias M = (Row, Row, Row)

    /// The type of this matrix's row.
    public typealias Row = (Scalar, Scalar, Scalar)

    /// The type of this matrix's column.
    public typealias Column = (Scalar, Scalar, Scalar)

    /// Gets or sets all coefficients of this matrix as a single 3x3 tuple.
    public var m: M

    /// The first row of this matrix
    ///
    /// Equivalent to `self.m.0`.
    public var r0: Row {
        @inlinable
        get { m.0 }
        @inlinable
        set { m.0 = newValue }
    }

    /// The second row of this matrix
    ///
    /// Equivalent to `self.m.1`.
    public var r1: Row {
        @inlinable
        get { m.1 }
        @inlinable
        set { m.1 = newValue }
    }

    /// The third row of this matrix
    ///
    /// Equivalent to `self.m.2`.
    public var r2: Row {
        @inlinable
        get { m.2 }
        @inlinable
        set { m.2 = newValue }
    }

    /// The first column of this matrix
    ///
    /// Equivalent to `(self.r0.0, self.r1.0, self.r2.0)`.
    public var c0: Column {
        @inlinable
        get { (r0.0, r1.0, r2.0) }
        @inlinable
        set { (r0.0, r1.0, r2.0) = newValue }
    }

    /// The second column of this matrix
    ///
    /// Equivalent to `(self.r0.1, self.r1.1, self.r2.1)`.
    public var c1: Column {
        @inlinable
        get { (r0.1, r1.1, r2.1) }
        @inlinable
        set { (r0.1, r1.1, r2.1) = newValue }
    }

    /// The third column of this matrix
    ///
    /// Equivalent to `(self.r0.2, self.r1.2, self.r2.2)`.
    public var c2: Column {
        @inlinable
        get { (r0.2, r1.2, r2.2) }
        @inlinable
        set { (r0.2, r1.2, r2.2) = newValue }
    }

    /// Gets the first row of this matrix in a PVector3.
    public var r0Vec: PVector3 {
        @inlinable
        get { PVector3(r0) }
    }

    /// Gets the second row of this matrix in a PVector3.
    public var r1Vec: PVector3 {
        @inlinable
        get { PVector3(r1) }
    }

    /// Gets the third row of this matrix in a PVector3.
    public var r2Vec: PVector3 {
        @inlinable
        get { PVector3(r2) }
    }

    /// Gets the first column of this matrix in a PVector3.
    public var c0Vec: PVector3 {
        @inlinable
        get { PVector3(c0) }
    }

    /// Gets the second column of this matrix in a PVector3.
    public var c1Vec: PVector3 {
        @inlinable
        get { PVector3(c1) }
    }

    /// Gets the third column of this matrix in a PVector3.
    public var c2Vec: PVector3 {
        @inlinable
        get { PVector3(c2) }
    }

    public subscript(row: Int, column: Int) -> Scalar {
        @inlinable
        get {
            switch (row, column) {
            // Row 0
            case (0, 0): return r0.0
            case (0, 1): return r0.1
            case (0, 2): return r0.2
            // Row 1
            case (1, 0): return r1.0
            case (1, 1): return r1.1
            case (1, 2): return r1.2
            // Row 2
            case (2, 0): return r2.0
            case (2, 1): return r2.1
            case (2, 2): return r2.2
            default:
                preconditionFailure("Rows/columns for PMatrix3x3 run from [0, 0] to [2, 2], inclusive.")
            }
        }
        @inlinable
        set {
            switch (row, column) {
            // Row 0
            case (0, 0): r0.0 = newValue
            case (0, 1): r0.1 = newValue
            case (0, 2): r0.2 = newValue
            // Row 1
            case (1, 0): r1.0 = newValue
            case (1, 1): r1.1 = newValue
            case (1, 2): r1.2 = newValue
            // Row 2
            case (2, 0): r2.0 = newValue
            case (2, 1): r2.1 = newValue
            case (2, 2): r2.2 = newValue
            default:
                preconditionFailure("Rows/columns for PMatrix3x3 run from [0, 0] to [2, 2], inclusive.")
            }
        }
    }

    /// Returns the [trace] of this matrix, i.e. the sum of all the values on
    /// its diagonal:
    ///
    /// ```swift
    /// self[0, 0] + self[1, 1] + self[2, 2]
    /// ```
    ///
    /// [trace]: https://en.wikipedia.org/wiki/Trace_(linear_algebra)
    @inlinable
    public var trace: Scalar {
        r0.0 + r1.1 + r2.2
    }

    /// Returns a `String` that represents this instance.
    public var description: String {
        "\(type(of: self))(rows: \(m))"
    }

    /// Initializes an identity matrix.
    @inlinable
    public init() {
        m = ((1, 0, 0),
             (0, 1, 0),
             (0, 0, 1))
    }

    /// Initializes a new matrix with the given row values.
    @inlinable
    public init(rows: (Row, Row, Row)) {
        m = rows
    }

    /// Initializes a new matrix with the given ``PVector3`` values as the
    /// values for each row.
    @inlinable
    public init(rows: (PVector3, PVector3, PVector3)) {
        self.init(rows: (
            (rows.0.x, rows.0.y, rows.0.z),
            (rows.1.x, rows.1.y, rows.1.z),
            (rows.2.x, rows.2.y, rows.2.z)
        ))
    }

    /// Initializes a matrix with the given scalar on all positions.
    @inlinable
    public init(repeating scalar: Scalar) {
        m = (
            (scalar, scalar, scalar),
            (scalar, scalar, scalar),
            (scalar, scalar, scalar)
        )
    }

    /// Initializes a matrix with the given scalars laid out on the diagonal,
    /// with all remaining elements being `.zero`.
    @inlinable
    public init(diagonal: (Scalar, Scalar, Scalar)) {
        m = (
            (diagonal.0,          0,          0),
            (         0, diagonal.1,          0),
            (         0,          0, diagonal.2)
        )
    }

    /// Initializes a matrix with the given scalar laid out on the diagonal,
    /// with all remaining elements being `.zero`.
    @inlinable
    public init(diagonal: Scalar) {
        self.init(diagonal: (diagonal, diagonal, diagonal))
    }

    /// Returns the [determinant] of this matrix.
    ///
    /// [determinant]: https://en.wikipedia.org/wiki/Determinant
    @inlinable
    public func determinant() -> Scalar {
        // Use Rule os Sarrus (https://en.wikipedia.org/wiki/Rule_of_Sarrus)
        // to simplify 3x3 det computation here

        // | a b c |   | r0 |
        // | d e f | = | r1 |
        // | g h i |   | r2 |

        let (a, b, c) = r0
        let (d, e, f) = r1
        let (g, h, i) = r2

        let d1: Scalar = a * e * i
        let d2: Scalar = b * f * g
        let d3: Scalar = c * d * h

        let d4: Scalar = g * e * c
        let d5: Scalar = h * f * a
        let d6: Scalar = i * d * b

        let det: Scalar = d1 + d2 + d3 - d4 - d5 - d6

        return det
    }

    /// Returns a new ``PMatrix3x3`` that is a [transposition] of this matrix.
    ///
    /// [transposition]: https://en.wikipedia.org/wiki/Transpose
    @inlinable
    public func transposed() -> Self {
        Self(rows: (
            c0, c1, c2
        ))
    }

    /// Performs an in-place [transposition] of this matrix.
    ///
    /// [transposition]: https://en.wikipedia.org/wiki/Transpose
    @inlinable
    public mutating func transpose() {
        self = transposed()
    }

    /// Returns the [inverse of this matrix](https://en.wikipedia.org/wiki/Invertible_matrix).
    ///
    /// If this matrix has no inversion, `nil` is returned, instead.
    @inlinable
    public func inverted() -> Self? {
        // Use technique described in:
        // https://en.wikipedia.org/wiki/Invertible_matrix#Inversion_of_3_%C3%97_3_matrices

        let det = determinant()
        if det.isZero {
            return nil
        }

        let invDet = 1 / det

        let x0 = c0Vec
        let x1 = c1Vec
        let x2 = c2Vec

        let intermediary =
        Self(rows: (
            x1.cross(x2),
            x2.cross(x0),
            x0.cross(x1)
        ))

        return intermediary * invDet
    }

    /// Creates a matrix that when applied to a vector, scales each coordinate
    /// by the given amount.
    @inlinable
    public static func make2DScale(x: Scalar, y: Scalar) -> Self {
        Self(rows: (
            (x, 0, 0),
            (0, y, 0),
            (0, 0, 1)
        ))
    }

    /// Creates a matrix that when applied to a vector, scales each coordinate
    /// by the corresponding coordinate on a supplied vector.
    @inlinable
    public static func make2DScale(_ vec: PVector2) -> Self {
        make2DScale(x: vec.x, y: vec.y)
    }

    /// Creates a rotation matrix that when applied to a 2-dimensional vector,
    /// rotates it around the origin (Z-axis) by a specified radian amount.
    @inlinable
    public static func make2DRotation(_ angleInRadians: Scalar) -> Self {
        let c = cos(angleInRadians)
        let s = sin(angleInRadians)

        return Self(rows: (
            ( c, s, 0),
            (-s, c, 0),
            ( 0, 0, 1)
        ))
    }

    /// Creates a translation matrix that when applied to a vector, moves it
    /// according to the specified amounts.
    @inlinable
    public static func make2DTranslation(x: Scalar, y: Scalar) -> Self {
        Self(rows: (
            (1, 0, x),
            (0, 1, y),
            (0, 0, 1)
        ))
    }

    /// Creates a translation matrix that when applied to a vector, moves it
    /// according to the specified amounts.
    @inlinable
    public static func make2DTranslation(_ vec: PVector2) -> Self {
        make2DTranslation(x: vec.x, y: vec.y)
    }

    /// Creates a [skew-symmetric cross product] matrix for a given vector.
    ///
    /// When a skew-symmetric matrix `m` is created using this method with a
    /// vector `a`, a vector `b` multiplied by the matrix is equivalent to the
    /// result of `a × b`.
    ///
    /// Changing the [orientation] parameter results in a matrix that flips the
    /// sign of the resulting cross product.
    ///
    /// [skew-symmetric cross product]: https://en.wikipedia.org/wiki/Skew-symmetric_matrix#Cross_product
    /// [orientation]: https://en.wikipedia.org/wiki/Orientation_(vector_space)
    @inlinable
    public static func make3DSkewSymmetricCrossProduct(_ vector: PVector3) -> Self {
        let x = vector.x
        let y = vector.y
        let z = vector.z

        let m = Self(rows: (
            ( 0, -z,  y),
            ( z,  0, -x),
            (-y,  x,  0)
        ))

        return m
    }

    /// Performs a [matrix addition] between `lhs` and `rhs` and returns the
    /// result.
    ///
    /// [matrix addition]: https://en.wikipedia.org/wiki/Matrix_addition
    public static func + (lhs: Self, rhs: Self) -> Self {
        let r0 = lhs.r0Vec + rhs.r0Vec
        let r1 = lhs.r1Vec + rhs.r1Vec
        let r2 = lhs.r2Vec + rhs.r2Vec

        return Self(rows: (r0, r1, r2))
    }

    /// Performs a [matrix subtraction] between `lhs` and `rhs` and returns the
    /// result.
    ///
    /// [matrix subtraction]: https://en.wikipedia.org/wiki/Matrix_addition
    public static func - (lhs: Self, rhs: Self) -> Self {
        let r0 = lhs.r0Vec - rhs.r0Vec
        let r1 = lhs.r1Vec - rhs.r1Vec
        let r2 = lhs.r2Vec - rhs.r2Vec

        return Self(rows: (r0, r1, r2))
    }

    /// Negates (i.e. flips) the signs of all the values of this matrix.
    public static prefix func - (value: Self) -> Self {
        let r0 = -value.r0Vec
        let r1 = -value.r1Vec
        let r2 = -value.r2Vec

        return Self(rows: (r0, r1, r2))
    }

    /// Performs a [scalar multiplication] between `lhs` and `rhs` and returns
    /// the result.
    ///
    /// [scalar multiplication]: https://en.wikipedia.org/wiki/Scalar_multiplication
    public static func * (lhs: Self, rhs: Scalar) -> Self {
        let r0 = lhs.r0Vec * rhs
        let r1 = lhs.r1Vec * rhs
        let r2 = lhs.r2Vec * rhs

        return Self(rows: (r0, r1, r2))
    }

    /// Performs a scalar division between the elements of `lhs` and `rhs` and
    /// returns the result.
    public static func / (lhs: Self, rhs: Scalar) -> Self {
        let r0 = lhs.r0Vec / rhs
        let r1 = lhs.r1Vec / rhs
        let r2 = lhs.r2Vec / rhs

        return Self(rows: (r0, r1, r2))
    }

    /// Performs a [matrix multiplication] between `lhs` and `rhs` and returns
    /// the result.
    ///
    /// [matrix multiplication]: http://en.wikipedia.org/wiki/Matrix_multiplication
    @inlinable
    public static func * (lhs: Self, rhs: Self) -> Self {
        let r00 = lhs.r0Vec.dot(rhs.c0Vec)
        let r01 = lhs.r0Vec.dot(rhs.c1Vec)
        let r02 = lhs.r0Vec.dot(rhs.c2Vec)
        let r10 = lhs.r1Vec.dot(rhs.c0Vec)
        let r11 = lhs.r1Vec.dot(rhs.c1Vec)
        let r12 = lhs.r1Vec.dot(rhs.c2Vec)
        let r20 = lhs.r2Vec.dot(rhs.c0Vec)
        let r21 = lhs.r2Vec.dot(rhs.c1Vec)
        let r22 = lhs.r2Vec.dot(rhs.c2Vec)

        return Self(rows: (
            (r00, r01, r02),
            (r10, r11, r12),
            (r20, r21, r22)
        ))
    }

    /// Performs an in-place [matrix multiplication] between `lhs` and `rhs`
    /// and stores the result back to `lhs`.
    ///
    /// [matrix multiplication]: http://en.wikipedia.org/wiki/Matrix_multiplication
    @inlinable
    public static func *= (lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }

    /// Returns `true` iff all coefficients from `lhs` and `rhs` are equal.
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.m == rhs.m
    }
}

/// Performs an equality check over a tuple of ``PMatrix3x3`` values.
@inlinable
public func == (_ lhs: PMatrix3x3.M, _ rhs: PMatrix3x3.M) -> Bool {
    lhs.0 == rhs.0 && lhs.1 == rhs.1 && lhs.2 == rhs.2
}
