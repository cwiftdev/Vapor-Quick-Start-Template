// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Vapor-Quick-Start-Template",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.110.1"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        .package(url: "https://github.com/vapor/queues-redis-driver.git", from: "1.1.1"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.9.2"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.2.2"),
        .package(url: "https://github.com/vapor-community/Lingo-Vapor.git", from: "4.2.0"),
        .package(url: "https://github.com/Joannis/VaporSMTPKit.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "Vapor-Quick-Start-Template",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "QueuesRedisDriver", package: "queues-redis-driver"),
                .product(name: "LingoVapor", package: "Lingo-Vapor"),
                .product(name: "VaporSMTPKit", package: "VaporSMTPKit")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "UnitTests",
            dependencies: [
                .target(name: "Vapor-Quick-Start-Template"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
            path: "Tests/UnitTests",
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
