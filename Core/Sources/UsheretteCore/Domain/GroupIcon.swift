/// What a group shows in the menu bar: an SF Symbol name or an emoji.
public struct GroupIcon: Codable, Equatable, Sendable {
    public enum Kind: String, Codable, Sendable {
        case symbol
        case emoji
    }

    public var kind: Kind
    public var value: String

    public init(kind: Kind, value: String) {
        self.kind = kind
        self.value = value
    }
}
