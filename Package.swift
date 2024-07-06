// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MiniP5Printer",
    products: [
        .library(
            name: "MiniP5Printer",
            targets: ["MiniP5Printer"]
        ),
    ],
    targets: [
        .target(
            name: "MiniP5Printer"
        ),
        .testTarget(
            name: "MiniP5PrinterTests",
            dependencies: ["MiniP5Printer"]
        ),
    ]
)
