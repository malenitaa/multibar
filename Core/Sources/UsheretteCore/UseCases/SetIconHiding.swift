/// Turns hiding of the icons on the left of the marker on or off, and saves the choice.
public struct SetIconHiding: Sendable {
    private let store: any ConfigStore

    public init(store: any ConfigStore) {
        self.store = store
    }

    public func callAsFunction(_ hidesIcons: Bool, in configuration: Configuration) throws -> Configuration {
        var updated = configuration
        updated.hidesIcons = hidesIcons
        try store.save(updated)
        return updated
    }
}
