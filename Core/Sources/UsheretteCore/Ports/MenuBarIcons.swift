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
}
