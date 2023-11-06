// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PresentationViews",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "PresentationViews", targets: ["PresentationViews"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ridgeview-apps/ridgeview-core", branch: "main"),
        .package(path: "Models")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PresentationViews",
            dependencies: [
                .product(name: "RidgeviewCore", package: "ridgeview-core"),
                "Models"
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "PresentationViewsTests",
            dependencies: ["PresentationViews", "Models"]
        ),
    ]
)
