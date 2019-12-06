// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "my-script",
    products: [
        .executable(name: "my-script", targets: ["my-script"]),
        .library(name: "Composable", targets: ["Composable"]),
        .library(name: "ArgumentParsing", targets: ["ArgumentParsing"]),
        .library(name: "FileOperations", targets: ["FileOperations"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-package-manager", .revision("528da5147ca82164acbd4cecdc8e69322d96d3e2")),
    ],
    targets: [
        .target(name: "my-script", dependencies: ["Composable", "ArgumentParsing", "FileOperations"]),
        .target(name: "Composable"),
        .target(name: "ArgumentParsing", dependencies: ["Composable", "TSCUtility"]),
        .target(name: "FileOperations", dependencies: ["Composable"])
    ]
)
