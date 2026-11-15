import Testing

@testable import UsheretteCore

// AC-13 · Open another app's menu from a group (SPEC.md, section 5).
@MainActor
@Suite("AC-13 · Open a menu bar app from its group")
struct AC13OpenMenuBarIconTests {
    static let usage = MenuBarApp(bundleID: "com.example.usage", name: "Claude Usage")

    func menuBar(hiding: Bool) -> FakeMenuBar {
        let menuBar = FakeMenuBar(hiding: hiding)
        menuBar.apps = [Self.usage]
        return menuBar
    }

    func open(_ menuBar: FakeMenuBar) async throws {
        try await OpenMenuBarIcon(icons: menuBar, hider: menuBar, sleep: { menuBar.sleep($0) })(bundleID: Self.usage.bundleID)
    }

    @Test("given a hidden icon, when I pick it from the group, then it comes back, its menu opens, and it hides again once the menu closes")
    func revealPressHide() async throws {
        let menuBar = menuBar(hiding: true)

        try await open(menuBar)

        #expect(menuBar.events == ["reveal", "press com.example.usage", "hide"])
        #expect(menuBar.isHiding)
        // 150 ms for the icon, 100 ms for the menu to show, 3 s open.
        #expect(menuBar.now >= .milliseconds(3250))
        #expect(menuBar.now < .milliseconds(3500))
    }

    @Test("given a menu that cannot be seen opening, when I pick the icon, then the icons stay for a while and hide again")
    func lingersWhenTheMenuIsNotSeen() async throws {
        let menuBar = menuBar(hiding: true)
        menuBar.menuShowsAfter = nil

        try await open(menuBar)

        #expect(menuBar.events == ["reveal", "press com.example.usage", "hide"])
        #expect(menuBar.now >= .seconds(8))
    }

    @Test("given hiding is off, when I pick the icon, then its menu opens and nothing is hidden or revealed")
    func notHiding() async throws {
        let menuBar = menuBar(hiding: false)
        menuBar.iconReturnsAfter = .zero

        try await open(menuBar)

        #expect(menuBar.events == ["press com.example.usage"])
        #expect(!menuBar.isHiding)
        #expect(menuBar.now == .zero)
    }

    @Test("given Accessibility is not granted, when I pick the icon, then I am told and nothing is revealed")
    func permissionMissing() async {
        let menuBar = menuBar(hiding: true)
        menuBar.isPermitted = false

        await #expect(throws: OrganizerError.permissionMissing) { try await open(menuBar) }
        #expect(menuBar.events.isEmpty)
        #expect(menuBar.isHiding)
    }
}
