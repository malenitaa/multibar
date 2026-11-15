import AppKit
import UsheretteCore

extension GroupIcon {
    /// The image for a symbol icon, or a plain circle when the symbol does not exist on this
    /// macOS. `nil` for an emoji, which is drawn as text.
    func symbolImage(accessibilityDescription: String) -> NSImage? {
        guard kind == .symbol else { return nil }
        return NSImage(systemSymbolName: value, accessibilityDescription: accessibilityDescription)
            ?? NSImage(systemSymbolName: "circle", accessibilityDescription: accessibilityDescription)
    }
}
