// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Models",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "Models", targets: ["Models"]),
        .library(name: "ModelStubs", targets: ["ModelStubs"])
    ],
    dependencies: [
        .package(url: "https://github.com/ridgeview-apps/ridgeview-core", from: "1.0.0"),
        .package(path: "Shared"),
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Models",
            dependencies: [
                .product(name: "RidgeviewCore", package: "ridgeview-core"),
                "Shared",
            ],
            path: "Sources/Models"
        ),
        .target(
            name: "ModelStubs",
            dependencies: [
                .product(name: "RidgeviewCore", package: "ridgeview-core"),
                "Models"
            ],
            path: "Sources/ModelStubs"
        ),
        .testTarget(
            name: "ModelsTests",
            dependencies: ["Models", "ModelStubs"]
        )
    ]
    
)
