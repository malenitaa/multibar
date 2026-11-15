/// Takes an item out of a group and saves it.
public struct RemoveItem: Sendable {
    private let store: any ConfigStore

    public init(store: any ConfigStore) {
        self.store = store
    }

    /// Returns the configuration without that item. Asking for an item or a group that is not
    /// there changes nothing.
    public func callAsFunction(_ itemID: Item.ID, fromGroup groupID: Group.ID, in configuration: Configuration) throws -> Configuration {
        guard let index = configuration.groups.firstIndex(where: { $0.id == groupID }),
            configuration.groups[index].items.contains(where: { $0.id == itemID })
        else { return configuration }

        var updated = configuration
        updated.groups[index].items.removeAll { $0.id == itemID }
        try store.save(updated)
        return updated
    }
}
