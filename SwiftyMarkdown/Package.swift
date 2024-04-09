// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyMarkdown",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "SwiftyMarkAST", targets: ["SwiftyMarkAST"]),
        .library(name: "SwiftyMarkUI", targets: ["SwiftyMarkUI"]),
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
            name: "SwiftyMarkAST",
            dependencies: [
                "SwiftyUtils",
                "SwiftyParsec",
                "SwiftyDebug",
            ]
        ),
        .target(
            name: "SwiftyMarkUI",
            dependencies: [
                "SwiftyUtils",
                "SwiftyParsec",
                "SwiftyDebug",
                "SwiftyMarkAST",
            ]
        ),
        .testTarget(
            name: "SwiftyMarkdownTests",
            dependencies: [
                "SwiftyMarkAST",
                "SwiftyUtils",
                "SwiftyParsec",
                "SwiftyDebug",
            ]
        ),
    ]
)
