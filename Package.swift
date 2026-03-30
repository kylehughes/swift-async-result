// swift-tools-version: 6.2

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .treatAllWarnings(as: .error),
]

let package = Package(
    name: "swift-async-result",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "AsyncResult",
            targets: [
                "AsyncResult",
            ]
        ),
    ],
    targets: [
        .target(
            name: "AsyncResult",
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "AsyncResultTests",
            dependencies: [
                "AsyncResult",
            ],
            swiftSettings: swiftSettings
        ),
    ]
)
