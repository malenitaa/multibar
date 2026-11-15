import Testing

@testable import UsheretteCore

// AC-14 · The app behind a menu bar icon is not there (SPEC.md, section 5).
@MainActor
@Suite("AC-14 · Menu bar app that is not running")
struct AC14MissingMenuBarIconTests {
    @Test("given the app is not running, when I pick it from the group, then I am told and the hidden icons end up hidden")
    func notRunning() async {
        let menuBar = FakeMenuBar(hiding: true)

        await #expect(throws: OrganizerError.iconNotFound) {
            try await OpenMenuBarIcon(icons: menuBar, hider: menuBar, sleep: { menuBar.sleep($0) })(bundleID: "com.example.gone")
        }
        #expect(menuBar.events == ["reveal", "hide"])
        #expect(menuBar.isHiding)
        #expect(menuBar.now >= .seconds(2))
    }

    @Test("given the app runs but its icon never comes back, when I pick it, then I am told and nothing is clicked")
    func iconNeverReturns() async {
        let menuBar = FakeMenuBar(hiding: true)
        menuBar.apps = [MenuBarApp(bundleID: "com.example.usage", name: "Claude Usage")]
        menuBar.iconReturnsAfter = nil

        await #expect(throws: OrganizerError.iconNotFound) {
            try await OpenMenuBarIcon(icons: menuBar, hider: menuBar, sleep: { menuBar.sleep($0) })(bundleID: "com.example.usage")
        }
        #expect(menuBar.events == ["reveal", "hide"])
    }
}
