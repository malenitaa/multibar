// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "UsheretteCore",
    platforms: [.macOS(.v15)],
    products: [
        .library(name: "UsheretteCore", targets: ["UsheretteCore"]),
        .library(name: "UsherettePersistence", targets: ["UsherettePersistence"]),
    ],
    targets: [
        // Domain and ports. Foundation only: no AppKit, no SwiftUI (ADR 0002).
        .target(name: "UsheretteCore"),
        // Adapter: configuration as JSON.
        .target(name: "UsherettePersistence", dependencies: ["UsheretteCore"]),
        .testTarget(name: "UsheretteCoreTests", dependencies: ["UsheretteCore"]),
        .testTarget(name: "UsherettePersistenceTests", dependencies: ["UsherettePersistence"]),
    ]
)
