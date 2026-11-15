// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MultibarCore",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "MultibarCore", targets: ["MultibarCore"]),
        .library(name: "MultibarPersistence", targets: ["MultibarPersistence"]),
    ],
    targets: [
        // Domain and ports. Foundation only: no AppKit, no SwiftUI (ADR 0002).
        .target(name: "MultibarCore"),
        // Adapter: configuration as JSON.
        .target(name: "MultibarPersistence", dependencies: ["MultibarCore"]),
        .testTarget(name: "MultibarCoreTests", dependencies: ["MultibarCore"]),
        .testTarget(name: "MultibarPersistenceTests", dependencies: ["MultibarPersistence"]),
    ]
)
