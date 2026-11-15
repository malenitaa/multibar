import Foundation

/// Something a group can open.
public struct Item: Codable, Equatable, Identifiable, Sendable {
    public enum Kind: String, Codable, Sendable {
        case app
        case file
        case folder
        case url
    }

    public var id: UUID
    public var name: String
    public var kind: Kind
    /// A file path for apps, files and folders; the URL text for URLs.
    public var target: String
    /// For apps, so one that moved can still be found.
    public var bundleID: String?

    public init(id: UUID = UUID(), name: String, kind: Kind, target: String, bundleID: String? = nil) {
        self.id = id
        self.name = name
        self.kind = kind
        self.target = target
        self.bundleID = bundleID
    }
}
