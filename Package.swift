// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MiniP5Printer",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MiniP5Printer",
            targets: ["MiniP5Printer"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MiniP5Printer"),
        .testTarget(
            name: "MiniP5PrinterTests",
            dependencies: ["MiniP5Printer"]),
    ]
)
