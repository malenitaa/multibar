import Foundation

/// One icon in the menu bar and the items it holds, in the order they are shown.
public struct Group: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var icon: GroupIcon
    public var items: [Item]

    public init(id: UUID = UUID(), name: String, icon: GroupIcon, items: [Item] = []) {
        self.id = id
        self.name = name
        self.icon = icon
        self.items = items
    }
}
