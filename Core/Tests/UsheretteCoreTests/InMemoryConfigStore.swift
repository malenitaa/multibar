import Foundation
import UsheretteCore

/// A `ConfigStore` that keeps the configuration in memory and can be told to fail.
final class InMemoryConfigStore: ConfigStore, @unchecked Sendable {
    struct Failure: Error {}

    private let lock = NSLock()
    private var stored: Configuration?
    private var saves = 0
    private let failsOnSave: Bool

    init(failsOnSave: Bool = false) {
        self.failsOnSave = failsOnSave
    }

    var saved: Configuration? { lock.withLock { stored } }
    var saveCount: Int { lock.withLock { saves } }

    func load() throws -> ConfigLoadResult {
        ConfigLoadResult(configuration: saved ?? .empty)
    }

    func save(_ configuration: Configuration) throws {
        if failsOnSave { throw Failure() }
        lock.withLock {
            stored = configuration
            saves += 1
        }
    }
}
