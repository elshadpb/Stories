// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Stories",
    platforms: [
        // Only add support for iOS 11 and up.
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Stories",
            targets: ["Stories"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "EasyPeasy", url: "https://github.com/nakiostudio/EasyPeasy", .exact("1.10.0")),
        .package(name: "AnimatedCollectionViewLayout", url: "https://github.com/KelvinJin/AnimatedCollectionViewLayout", .exact("1.0.0")),
        .package(name: "Kingfisher", url: "https://github.com/onevcat/Kingfisher.git", .exact("7.6.2"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Stories",
            dependencies: [
                .product(name: "EasyPeasy", package: "EasyPeasy"),
                .product(name: "AnimatedCollectionViewLayout", package: "AnimatedCollectionViewLayout"),
                .product(name: "Kingfisher", package: "Kingfisher")
            ],
            path: "Sources",
            resources: [.process("Assets.xcassets")]
        ),
    ]
)
