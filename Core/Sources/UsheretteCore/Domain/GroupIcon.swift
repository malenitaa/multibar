import Foundation

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

    /// Reads what a person typed: an emoji stays an emoji, anything else is taken as an SF
    /// Symbol name.
    public init(text: String) {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        self.init(kind: Self.startsWithEmoji(text) ? .emoji : .symbol, value: text)
    }

    private static func startsWithEmoji(_ text: String) -> Bool {
        guard let first = text.first, let scalar = first.unicodeScalars.first else { return false }
        // Digits, # and * are "emoji" to Unicode but only draw as one with a variation selector.
        return scalar.properties.isEmojiPresentation
            || (scalar.properties.isEmoji && first.unicodeScalars.contains { $0.value == 0xFE0F })
    }
}
