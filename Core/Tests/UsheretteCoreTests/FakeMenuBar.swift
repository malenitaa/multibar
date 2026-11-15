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
    /// Where each app's icon is. The marker sits at 500...512; smaller is further left.
    var iconPositions: [String: Double] = [:]
    /// How many drags of each app do nothing before one works. Missing means every drag works.
    var dragsThatFail: [String: Int] = [:]
    /// How many times a drag of each app is refused because its icon is not where it was seen.
    var dragsRefused: [String: Int] = [:]

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

    var markerFrame: ClosedRange<Double>? {
        isHiding ? nil : 500...512
    }

    func iconFrame(bundleID: String) -> ClosedRange<Double>? {
        guard hasIcon(bundleID: bundleID), let x = iconPositions[bundleID] else { return nil }
        return (x - 10)...(x + 10)
    }

    func dragIcon(bundleID: String, toX x: Double) -> Bool {
        guard iconFrame(bundleID: bundleID) != nil else { return false }
        if let refusals = dragsRefused[bundleID], refusals > 0 {
            dragsRefused[bundleID] = refusals - 1
            events.append("refuse \(bundleID)")
            return false
        }
        events.append("drag \(bundleID) to \(x < 500 ? "the hidden side" : "the visible side")")
        if let failures = dragsThatFail[bundleID], failures > 0 {
            dragsThatFail[bundleID] = failures - 1
            return true
        }
        iconPositions[bundleID] = x < 500 ? 460 : 560
        return true
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
