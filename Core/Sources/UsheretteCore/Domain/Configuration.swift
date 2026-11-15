import Foundation

/// Everything the user has set up: the groups, in the order they appear in the menu bar.
public struct Configuration: Codable, Equatable, Sendable {
    /// The format version this build reads and writes.
    public static let currentVersion = 1

    public static let empty = Configuration(groups: [])

    public var version: Int
    public var groups: [Group]
    /// Whether the icons on the left of Usherette's marker are kept out of the menu bar.
    public var hidesIcons: Bool

    public init(groups: [Group], hidesIcons: Bool = false) {
        self.version = Self.currentVersion
        self.groups = groups
        self.hidesIcons = hidesIcons
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(Int.self, forKey: .version)
        groups = try container.decode([Group].self, forKey: .groups)
        // Added after the first files were written, so it may be missing.
        hidesIcons = try container.decodeIfPresent(Bool.self, forKey: .hidesIcons) ?? false
    }
}
