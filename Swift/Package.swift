// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "my-script",
    dependencies: [
        .package(url: "https://github.com/apple/swift-package-manager", .revision("528da5147ca82164acbd4cecdc8e69322d96d3e2")),
        .package(path: "/Users/sw819i/Development/Private/Swift/try-script/MyLib1")
    ],
    targets: [
        .target(
            name: "my-script",
            dependencies: ["TSCUtility", "MyLib1"]),
        .testTarget(
            name: "my-scriptTests",
            dependencies: ["my-script"]),
    ]
)
