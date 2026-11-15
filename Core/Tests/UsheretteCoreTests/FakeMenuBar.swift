import UsheretteCore

/// A pretend menu bar for the organizer tests: time only moves when the code under test sleeps.
@MainActor
final class FakeMenuBar: MenuBarIcons, IconHider {
    // What the test sets up.
    var isPermitted = true
    var apps: [MenuBarApp] = []
    /// How long after revealing the icon is back; `nil` means it never comes back.
    var iconReturnsAfter: Duration? = .milliseconds(150)
    /// How long after the click the menu shows; `nil` means it is never seen.
    var menuShowsAfter: Duration? = .milliseconds(100)
    var menuStaysOpenFor: Duration = .seconds(3)

    // What happened.
    private(set) var isHiding: Bool
    private(set) var now = Duration.zero
    private(set) var events: [String] = []
    private var revealedAt: Duration?
    private var pressedAt: Duration?

    init(hiding: Bool) {
        isHiding = hiding
        revealedAt = hiding ? nil : .zero
    }

    func sleep(_ duration: Duration) {
        now += duration
    }

    func hide() {
        isHiding = true
        revealedAt = nil
        events.append("hide")
    }

    func reveal() {
        isHiding = false
        revealedAt = now
        events.append("reveal")
    }

    func requestPermission() {
        events.append("request permission")
    }

    func runningApps() -> [MenuBarApp] {
        isPermitted ? apps : []
    }

    func hasIcon(bundleID: String) -> Bool {
        guard apps.contains(where: { $0.bundleID == bundleID }), let revealedAt, let iconReturnsAfter else { return false }
        return now >= revealedAt + iconReturnsAfter
    }

    func openMenu(bundleID: String) -> Bool {
        guard hasIcon(bundleID: bundleID) else { return false }
        pressedAt = now
        events.append("press \(bundleID)")
        return true
    }

    func isMenuOpen(bundleID: String) -> Bool {
        guard let pressedAt, let menuShowsAfter else { return false }
        return now >= pressedAt + menuShowsAfter && now < pressedAt + menuShowsAfter + menuStaysOpenFor
    }
}
