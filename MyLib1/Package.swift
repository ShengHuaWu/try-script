// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "MyLib1",
    products: [
        .library(name: "MyLib1", targets: ["MyLib1"])
    ],
    targets: [
        .target(name: "MyLib1", dependencies: [])
    ]
)
