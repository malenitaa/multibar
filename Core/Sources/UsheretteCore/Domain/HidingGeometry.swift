/// How wide Usherette's marker has to be for the icons on its left to leave the menu bar.
///
/// On a display with a notch, macOS drops every icon on the left of an item whose own left
/// edge reaches the notch (measured on macOS 27.2, see `docs/spikes/0008-organizer.md`).
public enum HidingGeometry {
    /// How far past the notch the marker reaches, so that icons appearing or disappearing on
    /// its right do not bring the hidden ones back.
    public static let overshoot = 120.0

    /// The length to give the marker, or `nil` when hiding is not possible from where it is.
    ///
    /// - Parameters:
    ///   - markerRightEdge: The marker's right edge while it is narrow, in screen points.
    ///   - markerPadding: What macOS adds around a status item's own length.
    ///   - notchRightEdge: Where the menu bar starts again on the right of the notch, or `nil`
    ///     on a display without one.
    public static func hidingLength(markerRightEdge: Double, markerPadding: Double, notchRightEdge: Double?) -> Double? {
        guard let notchRightEdge, markerRightEdge > notchRightEdge else { return nil }
        return markerRightEdge - notchRightEdge - markerPadding + overshoot
    }
}
