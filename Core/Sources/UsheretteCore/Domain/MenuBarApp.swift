/// An app that currently shows an icon of its own in the menu bar.
public struct MenuBarApp: Equatable, Identifiable, Sendable {
    public var bundleID: String
    public var name: String

    public var id: String { bundleID }

    public init(bundleID: String, name: String) {
        self.bundleID = bundleID
        self.name = name
    }
}
