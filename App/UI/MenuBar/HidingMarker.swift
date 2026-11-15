import AppKit
import UsheretteCore

/// A status item of our own that, widened, pushes the icons on its left out of the menu bar.
/// Needs no permission. See `docs/spikes/0008-organizer.md` for why this works.
@MainActor
final class HidingMarker: IconHider {
    static let autosaveName = "icon-marker"
    private static let narrowLength: CGFloat = 12

    private var item: NSStatusItem?
    private(set) var isHiding = false
    /// Where the marker ends and how much macOS pads it, measured while it is narrow.
    private var measured: (rightEdge: Double, padding: Double)?

    /// Whether the display the menu bar is on has a notch to hide icons behind.
    var canHide: Bool {
        notchRightEdge != nil
    }

    /// Shows or removes the marker. A new marker goes to the left end of the menu bar, so
    /// nothing is on its left until the user drags icons there.
    func setInstalled(_ installed: Bool) {
        if installed, item == nil {
            let item = NSStatusBar.system.statusItem(withLength: Self.narrowLength)
            item.autosaveName = Self.autosaveName
            item.button?.toolTip = "Usherette hides the icons on the left of this marker. Hold ⌘ and drag icons across it."
            self.item = item
            showGlyph(true)
        } else if !installed, let item {
            NSStatusBar.system.removeStatusItem(item)
            self.item = nil
            isHiding = false
            measured = nil
        }
    }

    func hide() {
        guard let item, let window = item.button?.window else { return }
        if !isHiding, window.frame.width < 100, window.frame.maxX > 0 {
            measured = (Double(window.frame.maxX), Double(window.frame.width - Self.narrowLength))
        }
        guard let measured,
            let length = HidingGeometry.hidingLength(
                markerRightEdge: measured.rightEdge,
                markerPadding: measured.padding,
                notchRightEdge: notchRightEdge
            )
        else { return }
        showGlyph(false)
        item.length = length
        isHiding = true
    }

    func reveal() {
        guard let item else { return }
        item.length = Self.narrowLength
        showGlyph(true)
        isHiding = false
    }

    private func showGlyph(_ visible: Bool) {
        item?.button?.image = visible ? NSImage(systemSymbolName: "chevron.compact.left", accessibilityDescription: "Usherette marker") : nil
    }

    private var notchRightEdge: Double? {
        let screen = item?.button?.window?.screen ?? NSScreen.main
        return screen?.auxiliaryTopRightArea.map { Double($0.minX) }
    }
}
