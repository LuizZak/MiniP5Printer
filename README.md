## MiniP5Printer

A teeny-tiny-weeny p5.js sketch builder written in Swift available as a Swift Package.

Mostly used as a dependency by my other OSS projects.

Sample usage:

```swift
let p5 = BaseP5Printer(
    size: .init(x: 800, y: 600), lineScale: 40.0, renderScale: 20.0
)

p5.drawGrid = true
p5.add(.init(x: 5, y: 10))
p5.add(
    lineStart: .init(x: -3, y: -1),
    end: .init(x: 10, y: 5)
)

sut.printAll()
```

[prints:](https://editor.p5js.org/LuizZak/sketches/m4NsOEn_g)

```js
var lineScale = 40.0
var renderScale = 20.0

function setup() {
  createCanvas(800, 600)
  ellipseMode(RADIUS)
  rectMode(CORNERS)
}

function draw() {
  background(240)

  translate(width / 2, height / 2)

  strokeWeight(3 / lineScale)
  scale(renderScale)

  drawGrid()
  drawOrigin2D()

  // Sample.swift:12
  stroke(0)
  noFill()
  strokeWeight(2.0 / lineScale)
  circle(5.0, 10.0, 4.0 / renderScale)
  // Sample.swift:13
  line(-3.0, -1.0, 10.0, 5.0)

  drawMouseLocation2D()
  stroke(0)
  noFill()
  strokeWeight(1.0 / lineScale)
}
function drawMouseLocation2D() {
  resetMatrix()
  fill(0)
  noStroke()

  const mx = (mouseX - width / 2) / renderScale
  const my = (mouseY - height / 2) / renderScale

  text(`Mouse location: (${mx}, ${my})`, 10, 10 + textAscent())
}

function drawGrid() {
  strokeWeight(1 / lineScale)
  stroke(0, 0, 0, 20)
  line(0, -20, 0, 20)
  line(-20, 0, 20, 0)
  for (var x = -20; x < 20; x++) {
    line(x, -20, x, 20)
  }
  for (var y = -20; y < 20; y++) {
    line(-20, y, 20, y)
  }
}

function drawOrigin2D() {
  strokeWeight(1 / lineScale)
  // X axis
  stroke(255, 0, 0)
  line(0.0, 0.0, 25.0 / renderScale, 0.0)
  // Y axis
  stroke(0, 255, 0)
  line(0.0, 0.0, 0.0, 25.0 / renderScale)
}
```
