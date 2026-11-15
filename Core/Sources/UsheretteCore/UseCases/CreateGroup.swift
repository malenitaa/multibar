import Foundation

/// Adds a group at the end of the configuration and saves it.
public struct CreateGroup: Sendable {
    private let store: any ConfigStore

    public init(store: any ConfigStore) {
        self.store = store
    }

    /// Returns the configuration with the new group. Throws `GroupError.emptyName` for a name
    /// that is empty or only whitespace, or the store's error if saving fails; in both cases
    /// nothing is saved.
    public func callAsFunction(name: String, icon: GroupIcon, in configuration: Configuration) throws -> Configuration {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { throw GroupError.emptyName }

        var updated = configuration
        updated.groups.append(Group(name: name, icon: icon))
        try store.save(updated)
        return updated
    }
}
