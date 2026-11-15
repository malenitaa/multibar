/// Takes the icons on the left of Usherette's marker out of the menu bar and brings them back.
@MainActor
public protocol IconHider: AnyObject {
    var isHiding: Bool { get }
    /// Where the marker is, left to right in screen points, while it is narrow. `nil` when
    /// there is no marker or it is widened to hide.
    var markerFrame: ClosedRange<Double>? { get }
    func hide()
    func reveal()
}
