import AppKit
import UsheretteCore

/// A status item of our own that, widened, pushes the icons on its left out of the menu bar.
/// Needs no permission. See `docs/spikes/0008-organizer.md` for why this works.
@MainActor
final class HidingMarker: NSObject, IconHider {
    private static let narrowLength: CGFloat = 12

    /// Called when the user clicks the marker while it is showing.
    var onClick: (() -> Void)?
    /// The name macOS remembers the marker's place by.
    private let autosaveName: String
    /// Where a marker macOS has never seen goes; `nil` leaves it at the left end.
    private let firstPosition: Double?

    init(autosaveName: String = "icon-marker", firstPosition: Double? = nil) {
        self.autosaveName = autosaveName
        self.firstPosition = firstPosition
    }

    private var item: NSStatusItem?
    private(set) var isHiding = false
    /// Where the marker ends and how much macOS pads it, measured while it is narrow.
    private var measured: (rightEdge: Double, padding: Double)?

    var markerFrame: ClosedRange<Double>? {
        guard !isHiding, let frame = item?.button?.window?.frame, frame.width < 100, frame.maxX > 0 else { return nil }
        return Double(frame.minX)...Double(frame.maxX)
    }

    /// Whether the display the menu bar is on has a notch to hide icons behind.
    var canHide: Bool {
        notchRightEdge != nil
    }

    /// Shows or removes the marker. A new marker goes to the left end of the menu bar, so
    /// nothing is on its left until the user drags icons there.
    func setInstalled(_ installed: Bool) {
        if installed, item == nil {
            let positionKey = "NSStatusItem Preferred Position \(autosaveName)"
            if let firstPosition, UserDefaults.standard.object(forKey: positionKey) == nil {
                UserDefaults.standard.set(firstPosition, forKey: positionKey)
            }
            let item = NSStatusBar.system.statusItem(withLength: Self.narrowLength)
            item.autosaveName = autosaveName
            item.button?.toolTip = "Click to hide the icons on the left of this marker. Hold ⌘ and drag icons across it to choose which."
            item.button?.target = self
            item.button?.action = #selector(clicked)
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

    @objc private func clicked() {
        onClick?()
    }

    private func showGlyph(_ visible: Bool) {
        item?.button?.image = visible ? NSImage(systemSymbolName: "chevron.compact.left", accessibilityDescription: "Usherette marker") : nil
    }

    private var notchRightEdge: Double? {
        let screen = item?.button?.window?.screen ?? NSScreen.main
        return screen?.auxiliaryTopRightArea.map { Double($0.minX) }
    }
}
