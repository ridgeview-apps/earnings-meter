// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppPackages",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "AppConfig", targets: ["AppConfig"]),
        .library(name: "AppTargetLibrary", targets: ["AppTargetLibrary"]),
        .library(name: "AppWidgetLibrary", targets: ["AppWidgetLibrary"]),
        .library(name: "ViewComponents", targets: ["ViewComponents"]),
        .library(name: "Model", targets: ["Model"]),
        .library(name: "ModelStubs", targets: ["ModelStubs"]),
        .library(name: "DataSources", targets: ["DataSources"]),
        .library(name: "SharedViewStates", targets: ["SharedViewStates"]),
    ],
    dependencies: [
        .package(url: "https://github.com/devicekit/DeviceKit", from: "4.6.0"),
        .package(url: "https://github.com/ridgeview-apps/ridgeview-core", branch: "main"),
        .package(url: "https://github.com/microsoft/appcenter-sdk-apple.git", from: "4.4.0"),
        .package(url: "https://github.com/CombineCommunity/CombineExt", from: "1.6.0"),
        .package(url: "https://github.com/timbersoftware/SwiftUI-Introspect.git", from: "0.1.0")
    ],
    targets: [
        
        // AppConfig
        .target(
            name: "AppConfig",
            dependencies: []
        ),

        // AppTargetLibrary
        .target(
            name: "AppTargetLibrary",
            dependencies: [
                .product(name: "RidgeviewCore", package: "ridgeview-core"),
                .product(name: "AppCenterAnalytics", package: "appcenter-sdk-apple"),
                .product(name: "AppCenterCrashes", package: "appcenter-sdk-apple"),
                .product(name: "CombineExt", package: "CombineExt"),
                .product(name: "Introspect", package: "SwiftUI-Introspect"),
                .product(name: "DeviceKit", package: "DeviceKit"),
                "AppConfig",
                "ViewComponents",
                "Model",
                "ModelStubs",
                "DataSources",
                "SharedViewStates"
            ]
        ),
        
        // AppWidgetLibrary
        .target(
            name: "AppWidgetLibrary",
            dependencies: [
//                .product(name: "RidgeviewCore", package: "ridgeview-core"),
//                .product(name: "AppCenterAnalytics", package: "appcenter-sdk-apple"),
//                .product(name: "AppCenterCrashes", package: "appcenter-sdk-apple"),
//                .product(name: "CombineExt", package: "CombineExt"),
//                .product(name: "Introspect", package: "SwiftUI-Introspect"),
//                .product(name: "DeviceKit", package: "DeviceKit"),
                "AppConfig",
                "ViewComponents",
                "Model",
                "ModelStubs",
                "DataSources",
                "SharedViewStates"
            ]
        ),
        
        // ViewComponents
        .target(
            name: "ViewComponents",
            dependencies: [
                .product(name: "Introspect", package: "SwiftUI-Introspect"),
                .product(name: "RidgeviewCore", package: "ridgeview-core"),
            ],
            resources: [.process("Resources")]
        ),
        
        // Model
        .target(
            name: "Model",
            dependencies: []
        ),
        
        // ModelStubs
        .target(
            name: "ModelStubs",
            dependencies: [
                "Model",
                .product(name: "RidgeviewCore", package: "ridgeview-core")
            ]
        ),
        
        // DataSources
        .target(
            name: "DataSources",
            dependencies: [
                "Model",
                .product(name: "RidgeviewCore", package: "ridgeview-core")
            ]
        ),
        .testTarget(
            name: "DataSourcesTests",
            dependencies: ["DataSources", "ModelStubs"]
        ),
        
        // SharedViewStates
        
        .target(
            name: "SharedViewStates",
            dependencies: [
                "DataSources"
            ]
        ),

        
//        // DataClients
//        .target(
//            name: "DataClients",
//            dependencies: [
//                "Model",
//                "ModelFakes",
//                "Shared",
//                .product(name: "RidgeviewCore", package: "ridgeview-core"),
//            ],
//            resources: [.process("Resources")]
//        ),
//        .testTarget(
//            name: "DataClientsTests",
//            dependencies: [
//                "DataClients",
//                .product(name: "CombineSchedulers", package: "combine-schedulers")
//            ]),
        
//        // Model
//        .target(
//            name: "Model",
//            dependencies: []
//        ),
//        .testTarget(
//            name: "ModelTests",
//            dependencies: ["Model"]
//        ),
//
//        // ModelFakes
//        .target(
//            name: "ModelFakes",
//            dependencies: ["Model"]
//        ),
//
//        // ModelUI
//        .target(
//            name: "ModelUI",
//            dependencies: [
//                "Model",
//                "StyleGuide"
//            ]
//        ),
        
        // LiveArrivalsFeature
//        .target(
//            name: "LiveArrivalsFeature",
//            dependencies: [
//                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
//                "DataClients",
//                "Model",
//                "ModelFakes",
//                "ModelUI",
//                "Shared",
//                "SharedViews",
//                "StyleGuide",
//            ],
//            resources: [.process("Resources")]
//        ),
//        .testTarget(
//            name: "LiveArrivalsFeatureTests",
//            dependencies: ["LiveArrivalsFeature"]
//        ),
        
//        // LineStatusFeature
//        .target(
//            name: "LineStatusFeature",
//            dependencies: [
//                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
//                "DataClients",
//                "Model",
//                "ModelFakes",
//                "ModelUI",
//                "Shared",
//                "SharedViews",
//                "StyleGuide",
//            ],
//            resources: [.process("Resources")]
//        ),
//        .testTarget(
//            name: "LineStatusFeatureTests",
//            dependencies: ["LineStatusFeature"]
//        ),
//        
//        // SettingsFeature
//        .target(
//            name: "SettingsFeature",
//            dependencies: [
//                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
//                "DataClients",
//                "DeviceKit",
//                "Model",
//                "ModelFakes",
//                "ModelUI",
//                "Shared",
//                "SharedViews",
//                "StyleGuide"
//            ],
//            resources: [.process("Resources")]
//        ),
//        .testTarget(
//            name: "SettingsFeatureTests",
//            dependencies: ["SettingsFeature"]
//        ),
//        
//        // Shared
//        .target(
//            name: "Shared",
//            dependencies: []),
//        .testTarget(
//            name: "SharedTests",
//            dependencies: ["Shared"]
//        ),
//
//
//        // StyleGuide
//        .target(
//            name: "StyleGuide",
//            dependencies: [
//                .product(name: "RidgeviewCore", package: "ridgeview-core"),
//            ]
//        ),

    ]
)
