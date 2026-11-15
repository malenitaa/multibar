import AppKit
import UsheretteCore

extension Item {
    /// The icon of the app this item belongs to, read from the app itself. No permission needed.
    @MainActor var appIcon: NSImage? {
        guard let bundleID, let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else { return nil }
        return NSWorkspace.shared.icon(forFile: url.path)
    }
}
