import Foundation

/// Base class for P5Printer implementations.
///
/// Subclasses should
open class BaseP5Printer {
    private var _lastStrokeColorCall: String? = ""
    private var _lastStrokeWeightCall: String? = ""
    private var _lastFillColorCall: String? = ""

    private let identDepth: Int = 2
    private var currentIndent: Int = 0
    private var draws: [String] = []

    /// Camera look-at.
    /// 3D-mode only.
    public var cameraLookAt: PVector3 = .zero

    /// Whether `drawNormal()` function should be emitted.
    ///
    /// Subclasses that make use of `drawNormal()` routine should turn this flag
    /// on when they require that function in the sketch.
    public var shouldPrintDrawNormal: Bool = false

    /// Whether `drawTangent()` function should be emitted.
    ///
    /// Subclasses that make use of `drawTangent()` routine should turn this flag
    /// on when they require that function in the sketch.
    public var shouldPrintDrawTangent: Bool = false

    /// Flag that indicates whether the contents of the sketch are 3D.
    ///
    /// Should be set to true whenever a 3D geometry has been added.
    /// May conflict with 2D rendering in odd ways.
    public var is3D: Bool = false

    /// Gets the current sketch's code buffer.
    internal(set) public var buffer: String = ""

    /// The size of the sketch.
    public var size: PVector2i

    /// Controls the scale of rendering of lines and shapes.
    ///
    /// Can be increased to make sure that highly-scaled scenes don't render
    /// with overly thickened lines.
    ///
    /// Drawing routines should ensure a call to `strokeWeight(1 / lineScale)` is
    /// emitted before any stroke operation.
    public var lineScale: Double

    /// The rendering scale applied to the sketch.
    ///
    /// An implicit translation is also applied that moves the origin of the
    /// sketch towards the center of the screen.
    public var renderScale: Double

    /// Whether to emit `debugMode(GRID)` during the sketch's setup.
    public var shouldStartDebugMode: Bool = false

    /// Whether to draw the origin of the sketch's local coordinates.
    ///
    /// - note: Works in 2D and 3D mode.
    public var drawOrigin: Bool = true

    /// Whether to draw a grid around the sketch.
    ///
    /// - note: 2D-mode only.
    public var drawGrid: Bool = false

    /// Controls the style and color on the output of the sketch.
    public var styling: Styles = Styles()

    /// Creates a new p5.js sketch printer.
    ///
    /// - Parameters:
    ///   - size: The size of the sketch, in width/height space.
    ///   - lineScale: Controls the scale of rendering of lines and shapes.
    ///     Can be increased to make sure that highly-scaled scenes don't render
    ///     with overly thickened lines.
    ///   - renderScale: The scale of the contents of the sketch. The contents of
    ///     the sketch will automatically be aligned at the center of the screen,
    ///     and zoomed in and out depending on this scale value.
    public required init(
        size: PVector2i = .init(x: 800, y: 600),
        lineScale: Double = 2.0,
        renderScale: Double = 1.0
    ) {
        self.size = size
        self.lineScale = lineScale
        self.renderScale = renderScale
    }

    // MARK: - Geometry

    /// Returns a type-agnostic numeric value that represents the radius of vertices
    /// to be draw with `self.add()` and related methods.
    open func vertexRadius<Scalar: Numeric>() -> Scalar {
        return 4
    }

    open func add(_ point: PVector2, style: Style? = nil, file: StaticString = #file, line: UInt = #line) {
        let radius: Double = vertexRadius()

        addFileAndLineComment(file: file, line: line)
        addStyleSet(style ?? styling.geometry)
        addDrawLine("circle(\(vec2String(point)), \(radius) / renderScale)")
    }

    open func add(_ point: PVector3, style: Style? = nil, file: StaticString = #file, line: UInt = #line) {
        let radius: Double = vertexRadius()

        is3D = true

        addFileAndLineComment(file: file, line: line)
        addDrawLine(
            sphere3String_customRadius(point, radius: "\(radius) / renderScale")
        )
    }

    func add(lineStart start: PVector2, end: PVector2, style: Style? = nil, file: StaticString = #file, line: UInt = #line) {
        addFileAndLineComment(file: file, line: line)
        addStyleSet(style ?? styling.line)
        addDrawLine("line(\(vec2String(start)), \(vec2String(end)))")
        addDrawLine("")
    }

    func add(lineStart start: PVector3, end: PVector3, style: Style? = nil, file: StaticString = #file, line: UInt = #line) {
        is3D = true

        addFileAndLineComment(file: file, line: line)
        addStyleSet(style ?? styling.line)
        addDrawLine("line(\(vec3String(start)), \(vec3String(end)))")
        addDrawLine("")
    }

    // MARK: - Printing

    /// Prints the buffer to the standard output, optionally clearing the buffer
    /// in the process.
    ///
    /// Also performs trimming of whitespace and newlines of the buffer's contents.
    open func printBuffer(clearBuffer: Bool = true) {
        buffer = buffer.trimmingCharacters(in: .whitespacesAndNewlines)

        print(buffer)

        if clearBuffer {
            buffer = ""
        }
    }

    /// Main print method; prints all necessary and optional methods, along with
    /// all geometry to be drawn within `function draw()`.
    ///
    /// At the end of the method, the contents of the buffer are printed to the
    /// standard output, and optionally cleared.
    open func printAll(clearBufferAfter: Bool = true) {
        defer { printBuffer(clearBuffer: clearBufferAfter) }

        prepareCustomPreFile()

        printLine("var lineScale = \(lineScale)")
        printLine("var renderScale = \(renderScale)")
        if is3D {
            printLine("var isSpaceBarPressed = false")
        }

        printCustomHeader()

        printLine("")
        printSetup()
        printLine("")
        printDraw()

        if !is3D {
            printDrawMouseLocation2D()
        }

        if is3D {
            printLine("")
            printKeyPressed()
        }

        if drawGrid && !is3D {
            printLine("")
            printDrawGrid2D()
        }

        if drawOrigin {
            printLine("")

            if is3D {
                printDrawOrigin3D()
            } else {
                printDrawOrigin2D()
            }
        }

        if shouldPrintDrawNormal {
            printLine("")
            printDrawNormal2D()
        }

        if shouldPrintDrawNormal && is3D {
            printLine("")
            printDrawNormal3D()
        }

        if shouldPrintDrawTangent {
            printLine("")
            printDrawTangent2D()
        }

        if is3D {
            printLine("")
            printDrawSphere()
        }
    }

    // MARK: Expression Printing

    open func boilerplate3DSpaceBar<T: FloatingPoint>(lineWeight: T) -> [String] {
        return [
            "if (isSpaceBarPressed) {",
            indentString(depth: 1) + "noFill()",
            indentString(depth: 1) + "noLights()",
            indentString(depth: 1) + "stroke(0, 0, 0, 20)",
            indentString(depth: 1) + "strokeWeight(\(1 / lineWeight) / lineScale)",
            "} else {",
            indentString(depth: 1) + "noStroke()",
            indentString(depth: 1) + "fill(255, 255, 255, 255)",
            indentString(depth: 1) + "lights()",
            "}"
        ]
    }

    open func addDrawLine(_ line: String) {
        draws.append(line)
    }

    open func addNoStroke() {
        if _lastStrokeColorCall == nil { return }
        _lastStrokeColorCall = nil
        addDrawLine("noStroke()")
    }

    open func addNoFill() {
        if _lastFillColorCall == nil { return }
        _lastFillColorCall = nil
        addDrawLine("noFill()")
    }

    open func addStrokeColorSet(_ color: Color?) {
        let line = _strokeColor(color)

        if _lastStrokeColorCall == line { return }

        _lastStrokeColorCall = line
        addDrawLine(line)
    }

    open func addStrokeWeightSet(_ value: String) {
        let line = "strokeWeight(\(value) / lineScale)"

        if _lastStrokeWeightCall == line { return }

        _lastStrokeWeightCall = line
        addDrawLine(line)
    }

    open func addFillColorSet(_ color: Color?) {
        let line = _fillColor(color)

        if _lastFillColorCall == line { return }

        _lastFillColorCall = line
        addDrawLine(line)
    }

    open func addStyleSet(_ style: Style?) {
        guard let style = style else { return }

        addStrokeColorSet(style.strokeColor)
        addFillColorSet(style.fillColor)
        addStrokeWeightSet(style.strokeWeight.description)
    }

    open func addFileAndLineComment(file: StaticString, line: UInt) {
        let url = URL(fileURLWithPath: "\(file)")

        addDrawLine("// \(url.lastPathComponent):\(line)")
    }

    // MARK: Methods for subclasses

    open func prepareCustomPreFile() {

    }

    open func printCustomHeader() {

    }

    open func printCustomPostSetup() {

    }

    open func printCustomPreDraw() {

    }

    open func printCustomPostDraw() {

    }

    // MARK: Function Printing

    open func printSetup() {
        indentedBlock("function setup() {") {
            if is3D {
                printLine("createCanvas(\(vec2String(size)), WEBGL)")
                printLine("perspective(PI / 3, 1, 0.3, 8000) // Corrects default zNear plane being too far for unit measurements")

                if cameraLookAt != .zero {
                    printLine("camera(\(vec3String_pCoordinates(cameraLookAt)))")
                }
            } else {
                printLine("createCanvas(\(vec2String(size)))")
            }

            printLine("ellipseMode(RADIUS)")
            printLine("rectMode(CORNERS)")

            if is3D && shouldStartDebugMode {
                printLine("debugMode(GRID)")
            }

            printCustomPostSetup()
        }
    }

    open func printDraw() {
        indentedBlock("function draw() {") {
            printCustomPreDraw()

            printLine("background(240)")
            printLine("")
            if !is3D {
                printLine("translate(width / 2, height / 2)")
            } else {
                printLine("orbitControl(3, 3, 0.3)")
                printLine("scale(lineScale)")
                printLine("// Correct Y to grow away from the origin, and Z to grow up")
                printLine("rotateX(PI / 2)")
                printLine("scale(1, -1, 1)")
            }
            printLine("")
            printLine("strokeWeight(3 / lineScale)")

            if drawOrigin && is3D {
                printLine("drawOrigin3D()")
            }

            if is3D {
                boilerplate3DSpaceBar(lineWeight: 1.0).forEach(printLine)
            }

            printLine("scale(renderScale)")

            if drawGrid && !is3D {
                printLine("")
                printLine("drawGrid()")
            }
            if drawOrigin && !is3D {
                printLine("drawOrigin2D()")
            }

            printLine("")

            for draw in draws {
                printLine(draw)
            }

            // Draw mouse location
            if !is3D {
                printLine("drawMouseLocation2D()")
            }

            // Reset draw state
            printLine(_strokeColor(.black))
            printLine(_fillColor(nil))
            printLine(_strokeWeight(1))

            printCustomPostDraw()
        }
    }

    open func printKeyPressed() {
        printMultiline("""
        function keyPressed() {
            if (keyCode === 32) {
                isSpaceBarPressed = !isSpaceBarPressed
            }
        }
        """)
    }

    open func printDrawMouseLocation2D() {
        printMultiline("""
        function drawMouseLocation2D() {
            resetMatrix()
            fill(0)
            noStroke()

            const mx = (mouseX - width / 2) / renderScale
            const my = (mouseY - height / 2) / renderScale

            text(`Mouse location: (${mx}, ${my})`, 10, 10 + textAscent())
        }
        """)
    }

    open func printDrawGrid2D() {
        printMultiline("""
        function drawGrid() {
            strokeWeight(1 / lineScale)

            let lengthX = width / 2 / renderScale
            let lengthY = height / 2 / renderScale
            let sep = (20) / renderScale

            stroke(0, 0, 0, 50)

            line(0, -lengthY, 0, lengthY)
            line(-lengthX, 0, lengthX, 0)
            for (let x = -lengthX; x < lengthX; x += sep) {
                line(x, -lengthY, x, lengthY)
            }
            for (let y = -lengthY; y < lengthY; y += sep) {
                line(-lengthX, y, lengthX, y)
            }
        }
        """)
    }

    open func printDrawOrigin2D() {
        let length: Double = 25.0

        printMultiline("""
        function drawOrigin2D() {
            strokeWeight(1 / lineScale)
            // X axis
            stroke(255, 0, 0)
            line(0.0, 0.0, \(length) / renderScale, 0.0)
            // Y axis
            stroke(0, 255, 0)
            line(0.0, 0.0, 0.0, \(length) / renderScale)
        }
        """)
    }

    open func printDrawOrigin3D() {
        let length: Double = 100.0

        let vx = PVector3.unitX * length
        let vy = PVector3.unitY * length
        let vz = PVector3.unitZ * length

        printMultiline("""
        function drawOrigin3D() {
            // X axis
            stroke(255, 0, 0, 50)
            line(\(vec3String(.zero)), \(vec3String(vx)))
            // Y axis
            stroke(0, 255, 0, 50)
            line(\(vec3String(.zero)), \(vec3String(vy)))
            // Z axis
            stroke(0, 0, 255, 50)
            line(\(vec3String(.zero)), \(vec3String(vz)))
        }
        """)
    }

    open func printDrawNormal2D() {
        printMultiline("""
        function drawNormal(x, y, nx, ny) {
            const s = 15.0 / renderScale

            const x2 = x + nx * s
            const y2 = y + ny * s

            line(x, y, x2, y2)
        }
        """)
    }

    open func printDrawNormal3D() {
        printMultiline("""
        function drawNormal(x, y, z, nx, ny, nz) {
            const s = 10.0 / renderScale

            const x2 = x + nx * s
            const y2 = y + ny * s
            const z2 = z + nz * s

            strokeWeight(5 / lineScale)
            stroke(255, 0, 0, 200)
            line(x, y, z, x2, y2, z2)
        }
        """)
    }

    open func printDrawTangent2D() {
        printMultiline("""
        function drawTangent(x, y, nx, ny) {
            const s = 5.0 / renderScale

            const x1 = x - ny * s
            const y1 = y + nx * s

            const x2 = x + ny * s
            const y2 = y - nx * s

            line(x1, y1, x2, y2)
        }
        """)
    }

    open func printDrawSphere() {
        printMultiline("""
        function drawSphere(x, y, z, radius) {
            push()
            translate(x, y, z)
            sphere(radius)
            pop()
        }
        """)
    }

    // MARK: String printing

    open func vec3PVectorString(_ vec: PVector3) -> String {
        return "createVector(\(vec3String(vec)))"
    }

    open func vec3String(_ vec: PVector3) -> String {
        return "\(vec.x), \(vec.y), \(vec.z)"
    }

    open func vec3String_pCoordinates(_ vec: PVector3) -> String {
        // Flip Y-Z axis (in Processing positive Y axis is down and positive Z axis is towards the screen)
        return "\(vec.x), \(-vec.z), \(-vec.y)"
    }

    open func vec2String(_ vec: PVector2) -> String {
        "\(vec.x), \(vec.y)"
    }

    open func vec2String(_ vec: PVector2i) -> String {
        "\(vec.x), \(vec.y)"
    }

    open func sphere3String_customRadius(_ center: PVector3, radius: String) -> String {
        "drawSphere(\(vec3String(center)), \(radius))"
    }

    open func applyMatrix3DString(_ matrix: PMatrix3x3) -> [String] {
        return [
            "applyMatrix(\(matrix[0, 0]), \(matrix[1, 0]), \(matrix[2, 0]), 0,",
            "            \(matrix[0, 1]), \(matrix[1, 1]), \(matrix[2, 1]), 0,",
            "            \(matrix[0, 2]), \(matrix[1, 2]), \(matrix[2, 2]), 0,",
            "            0.0, 0.0, 0.0, 1.0)"
        ]
    }

    func _styleLines(_ style: Style?) -> [String] {
        guard let style = style else {
            return []
        }

        var lines: [String] = []
        lines.append(_strokeWeight(style.strokeWeight))
        lines.append(_strokeColor(style.strokeColor))
        lines.append(_fillColor(style.fillColor))

        return lines
    }

    func _strokeColor(_ color: Color?) -> String {
        if let color = color {
            return "stroke(\(_colorParams(color)))"
        } else {
            return "noStroke()"
        }
    }

    func _fillColor(_ color: Color?) -> String {
        if let color = color {
            return "fill(\(_colorParams(color)))"
        } else {
            return "noFill()"
        }
    }

    func _strokeWeight(_ weight: Double) -> String {
        return "strokeWeight(\(weight) / lineScale)"
    }

    func _colorParams(_ color: Color) -> String {
        var c = ""
        if color.red == color.green && color.green == color.blue {
            c = "\(color.red)"
        } else {
            c = _commaSeparated(color.red, color.green, color.blue)
        }

        if color.alpha == 255 {
            return c
        } else {
            return _commaSeparated(c, color.alpha)
        }
    }

    func _commaSeparated(_ values: Any...) -> String {
        values.map { "\($0)" }.joined(separator: ", ")
    }

    func indentString(depth: Int) -> String {
        String(repeating: " ", count: depth)
    }

    // MARK: - Printing methods

    /// Adds a line straight to the buffer.
    open func printLine(_ line: some StringProtocol) {
        print("\(indentString())\(line)", to: &buffer)
    }

    /// Prints a block of code as a multi-lined string, with appropriate indentation
    /// across line breaks based on relative indentation between lines.
    open func printMultiline(_ block: String) {
        func spacesOnLine(_ line: some StringProtocol) -> Int {
            line.prefix(while: \.isWhitespace).count
        }

        let currentIndent = self.currentIndent
        defer { self.currentIndent = currentIndent }

        let lines = block.split(separator: "\n", omittingEmptySubsequences: false)
        var indentOffsetPerLine: [Int] = []

        var lastSpaces = lines.first.map(spacesOnLine) ?? 0
        for line in lines {
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                indentOffsetPerLine.append(0)
                continue
            }

            let nextSpaces = spacesOnLine(line)
            defer { lastSpaces = nextSpaces }

            if nextSpaces == lastSpaces {
                indentOffsetPerLine.append(0)
            } else if nextSpaces < lastSpaces {
                indentOffsetPerLine.append(-1)
            } else if nextSpaces > lastSpaces {
                indentOffsetPerLine.append(1)
            }
        }

        for (i, line) in lines.enumerated() {
            let line = line.drop(while: \.isWhitespace)

            if indentOffsetPerLine[i] > 0 {
                indent()
            } else if indentOffsetPerLine[i] < 0 {
                deindent()
            }

            printLine(line)
        }
    }

    /// Adds a series of lines straight to the buffer.
    open func printLines(_ lines: [String]) {
        lines.forEach(printLine)
    }

    /// Gets the indentation string at the current point in the buffer.
    open func indentString() -> String {
        indentString(depth: identDepth * currentIndent)
    }

    /// Prints a lead line, then invokes a block to print an indented block,
    /// followed by an unindented closing brace.
    ///
    /// - note: `start` must include its own matching opening brace.
    open func indentedBlock(_ start: String, _ block: () -> Void) {
        printLine(start)
        indented {
            block()
        }
        printLine("}")
    }

    /// Invokes a block to print an indented block.
    open func indented(_ block: () -> Void) {
        indent()
        block()
        deindent()
    }

    /// Increments the current indentation by one.
    open func indent() {
        currentIndent += 1
    }

    /// Decrements the current indentation by one.
    open func deindent() {
        currentIndent -= 1
    }

    /// Style for a draw operation
    public struct Style {
        public static let `default` = Self(
            strokeColor: .black,
            fillColor: nil,
            strokeWeight: 1.0
        )

        public var strokeColor: Color?
        public var fillColor: Color?
        public var strokeWeight: Double

        public init(
            strokeColor: BaseP5Printer.Color? = .black,
            fillColor: BaseP5Printer.Color? = nil,
            strokeWeight: Double = 1.0
        ) {
            self.strokeColor = strokeColor
            self.fillColor = fillColor
            self.strokeWeight = strokeWeight
        }
    }

    /// RGBA color with components between 0-255.
    public struct Color {
        public var alpha: Int
        public var red: Int
        public var green: Int
        public var blue: Int

        public var translucent: Self {
            var copy = self
            copy.alpha = 100
            return copy
        }

        public var opaque: Self {
            var copy = self
            copy.alpha = 255
            return copy
        }

        public init(alpha: Int = 255, red: Int, green: Int, blue: Int) {
            self.alpha = alpha
            self.red = red
            self.green = green
            self.blue = blue
        }
    }
}

public extension BaseP5Printer {
    struct Styles {
        public var line: Style = Style(strokeColor: .black, strokeWeight: 2.0)
        public var normalLine: Style = Style(strokeColor: .red.translucent, strokeWeight: 2.0)
        public var tangentLine: Style = Style(strokeColor: .purple.translucent, strokeWeight: 2.0)
        public var geometry: Style = Style(strokeColor: .black, strokeWeight: 2.0)
    }
}

public extension BaseP5Printer {
    static func withPrinter(_ block: (Self) -> Void) {
        let printer = Self(size: .init(x: 500, y: 500), lineScale: 2.0)

        block(printer)

        printer.printAll()
    }
}

public extension BaseP5Printer.Color {
    static let black = Self(red: 0, green: 0, blue: 0)
    static let grey = Self(red: 127, green: 127, blue: 127)
    static let white = Self(red: 255, green: 255, blue: 255)

    // Primary colors
    static let red = Self(red: 255, green: 0, blue: 0)
    static let green = Self(red: 0, green: 255, blue: 0)
    static let blue = Self(red: 0, green: 0, blue: 255)

    // Secondary colors
    static let yellow = Self(red: 255, green: 255, blue: 0)
    static let cyan = Self(red: 0, green: 255, blue: 255)
    static let purple = Self(red: 255, green: 0, blue: 255)
}
