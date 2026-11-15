/// Takes the icons on the left of Usherette's marker out of the menu bar and brings them back.
@MainActor
public protocol IconHider: AnyObject {
    var isHiding: Bool { get }
    func hide()
    func reveal()
}
