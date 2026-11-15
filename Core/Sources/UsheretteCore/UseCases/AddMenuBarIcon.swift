/// Puts another app's menu bar icon in a group and saves it.
public struct AddMenuBarIcon: Sendable {
    private let store: any ConfigStore

    public init(store: any ConfigStore) {
        self.store = store
    }

    /// Returns the configuration with the icon at the end of the group. An app that is already
    /// in that group is not added again. Throws `GroupError.unknownGroup` for a group that is
    /// not in the configuration.
    public func callAsFunction(_ app: MenuBarApp, toGroup groupID: Group.ID, in configuration: Configuration) throws -> Configuration {
        guard let index = configuration.groups.firstIndex(where: { $0.id == groupID }) else { throw GroupError.unknownGroup }
        let alreadyThere = configuration.groups[index].items.contains { $0.kind == .menuBarIcon && $0.bundleID == app.bundleID }
        guard !alreadyThere else { return configuration }

        var updated = configuration
        updated.groups[index].items.append(Item(name: app.name, kind: .menuBarIcon, target: "", bundleID: app.bundleID))
        try store.save(updated)
        return updated
    }
}
