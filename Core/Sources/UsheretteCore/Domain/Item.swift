import Foundation

/// Something a group can open.
public struct Item: Codable, Equatable, Identifiable, Sendable {
    public enum Kind: String, Codable, Sendable {
        case app
        case file
        case folder
        case url
        /// Another app's icon in the menu bar; `bundleID` says which app.
        case menuBarIcon
    }

    public var id: UUID
    public var name: String
    public var kind: Kind
    /// A file path for apps, files and folders; the URL text for URLs; empty for a menu bar icon.
    public var target: String
    /// For apps, so one that moved can still be found; for a menu bar icon, the app it belongs to.
    public var bundleID: String?

    public init(id: UUID = UUID(), name: String, kind: Kind, target: String, bundleID: String? = nil) {
        self.id = id
        self.name = name
        self.kind = kind
        self.target = target
        self.bundleID = bundleID
    }
}
