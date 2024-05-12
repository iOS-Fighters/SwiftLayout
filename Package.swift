// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "SwiftLayout",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "SwiftLayout",
            targets: ["SwiftLayout"]
        ),
        .library(
            name: "SwiftLayoutUtil",
            targets: ["SwiftLayoutUtil"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftLayout",
            dependencies: []
        ),
        .target(
            name: "SwiftLayoutUtil",
            dependencies: [
                "SwiftLayout"
            ]
        ),
        .testTarget(
            name: "SwiftLayoutTests",
            dependencies: [
                "SwiftLayout"
            ]
        ),
        .testTarget(
            name: "SwiftLayoutUtilTests",
            dependencies: [
                "SwiftLayout",
                "SwiftLayoutUtil"
            ]
        )
    ]
)
