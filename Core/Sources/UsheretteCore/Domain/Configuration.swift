import Foundation

/// Everything the user has set up: the groups, in the order they appear in the menu bar.
public struct Configuration: Codable, Equatable, Sendable {
    /// The format version this build reads and writes.
    public static let currentVersion = 1

    public static let empty = Configuration(groups: [])

    public var version: Int
    public var groups: [Group]

    public init(groups: [Group]) {
        self.version = Self.currentVersion
        self.groups = groups
    }
}
