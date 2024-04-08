// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyMarkdown",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "SwiftyMarkdown", targets: ["SwiftyMarkdown"]),
    ],
    dependencies: [
        .package(name: "SwiftyUtils", path: "../SwiftyUtils"),
        .package(name: "SwiftyDebug", path: "../SwiftyDebug"),
        .package(name: "SwiftyParsec", path: "../SwiftyParsec"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftyMarkdown",
            dependencies: [
                "SwiftyUtils",
                "SwiftyParsec",
                "SwiftyDebug",
            ]
        ),
        .testTarget(
            name: "SwiftyMarkdownTests",
            dependencies: [
                "SwiftyMarkdown",
                "SwiftyUtils",
                "SwiftyParsec",
                "SwiftyDebug",
            ]
        ),
    ]
)
