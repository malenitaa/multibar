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
        // Dominio y puertos. Solo Foundation: nada de AppKit ni SwiftUI (ADR 0002).
        .target(name: "MultibarCore"),
        // Adaptador de configuración en JSON.
        .target(name: "MultibarPersistence", dependencies: ["MultibarCore"]),
        .testTarget(name: "MultibarCoreTests", dependencies: ["MultibarCore"]),
        .testTarget(name: "MultibarPersistenceTests", dependencies: ["MultibarPersistence"]),
    ]
)
