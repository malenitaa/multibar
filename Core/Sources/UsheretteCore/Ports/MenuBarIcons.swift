/// Other apps' icons in the menu bar. Everything here needs the Accessibility permission.
@MainActor
public protocol MenuBarIcons: AnyObject {
    /// Whether the user has granted Accessibility to Usherette.
    var isPermitted: Bool { get }
    /// Asks macOS to show its own prompt for the permission.
    func requestPermission()
    /// The apps that show an icon right now. Empty without the permission.
    func runningApps() -> [MenuBarApp]
    /// Whether that app's icon is in the menu bar at this moment.
    func hasIcon(bundleID: String) -> Bool
    /// Clicks that app's icon. Returns whether there was an icon to click.
    func openMenu(bundleID: String) -> Bool
    /// Whether the menu opened by the last `openMenu` is still showing.
    func isMenuOpen(bundleID: String) -> Bool
    /// Where that app's icon is, left to right in screen points. `nil` when it has none.
    func iconFrame(bundleID: String) -> ClosedRange<Double>?
    /// Holds ⌘ and drags that app's icon sideways until the pointer is at `x`, the way a
    /// person would. Returns `false`, without touching anything, when the icon is missing or
    /// is not where it was last seen, which happens while the bar is still rearranging.
    func dragIcon(bundleID: String, toX x: Double) -> Bool
}
