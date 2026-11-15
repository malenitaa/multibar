import Testing

@testable import UsheretteCore

// AC-15 · Icons are moved behind the marker for the user (SPEC.md, section 5).
@MainActor
@Suite("AC-15 · Move icons behind the marker")
struct AC15ArrangeMenuBarIconsTests {
    static let usage = MenuBarApp(bundleID: "com.example.usage", name: "Claude Usage")
    static let clipboard = MenuBarApp(bundleID: "org.example.clipboard", name: "Clipboard")

    /// A menu bar with hiding on, both apps running, and their icons at the given positions
    /// (the marker is at 500...512).
    func menuBar(usage: Double, clipboard: Double) -> FakeMenuBar {
        let menuBar = FakeMenuBar(hiding: true)
        menuBar.apps = [Self.usage, Self.clipboard]
        menuBar.iconPositions = [Self.usage.bundleID: usage, Self.clipboard.bundleID: clipboard]
        return menuBar
    }

    func arrange(_ menuBar: FakeMenuBar, hide: [String] = [], show: [String] = []) async throws -> ArrangeMenuBarIcons.Outcome {
        try await ArrangeMenuBarIcons(icons: menuBar, hider: menuBar, sleep: { menuBar.sleep($0) })(hide: hide, show: show)
    }

    @Test("given an icon on the visible side, when its app is added to a group, then it is dragged behind the marker and hidden")
    func movesBehindTheMarker() async throws {
        let menuBar = menuBar(usage: 560, clipboard: 600)

        let outcome = try await arrange(menuBar, hide: [Self.usage.bundleID])

        #expect(outcome.moved == [Self.usage.bundleID])
        #expect(menuBar.events == ["reveal", "drag com.example.usage to the hidden side", "hide"])
        #expect(menuBar.iconPositions[Self.usage.bundleID] == 460)
        #expect(menuBar.iconPositions[Self.clipboard.bundleID] == 600)
        #expect(menuBar.isHiding)
    }

    @Test("given an icon already behind the marker, when its app is added to a group, then nothing is dragged")
    func alreadyHidden() async throws {
        let menuBar = menuBar(usage: 460, clipboard: 600)

        let outcome = try await arrange(menuBar, hide: [Self.usage.bundleID])

        #expect(outcome == ArrangeMenuBarIcons.Outcome())
        #expect(menuBar.events == ["reveal", "hide"])
    }

    @Test("given an app that left its last group, when icons are arranged, then its icon is dragged back into view")
    func bringsBackIntoView() async throws {
        let menuBar = menuBar(usage: 460, clipboard: 430)

        let outcome = try await arrange(menuBar, show: [Self.usage.bundleID])

        #expect(outcome.moved == [Self.usage.bundleID])
        #expect(menuBar.events == ["reveal", "drag com.example.usage to the visible side", "hide"])
        #expect(menuBar.iconPositions[Self.clipboard.bundleID] == 430)
    }

    @Test("given two apps in groups, when hiding is turned on, then both icons are moved in one go")
    func movesSeveral() async throws {
        let menuBar = menuBar(usage: 560, clipboard: 600)

        let outcome = try await arrange(menuBar, hide: [Self.usage.bundleID, Self.clipboard.bundleID])

        #expect(outcome.moved == [Self.usage.bundleID, Self.clipboard.bundleID])
        #expect(menuBar.events.first == "reveal")
        #expect(menuBar.events.last == "hide")
        #expect(menuBar.events.filter { $0 == "reveal" }.count == 1)
    }

    @Test("given a drag that does not take the first time, when icons are arranged, then it is tried again")
    func retriesOnce() async throws {
        let menuBar = menuBar(usage: 560, clipboard: 600)
        menuBar.dragsThatFail = [Self.usage.bundleID: 1]

        let outcome = try await arrange(menuBar, hide: [Self.usage.bundleID])

        #expect(outcome.moved == [Self.usage.bundleID])
        #expect(menuBar.events.filter { $0.hasPrefix("drag") }.count == 2)
    }

    @Test("given an icon that is not where it was last seen, when icons are arranged, then nothing is dragged until it is found again")
    func waitsForTheBarToSettle() async throws {
        let menuBar = menuBar(usage: 560, clipboard: 600)
        menuBar.dragsRefused = [Self.usage.bundleID: 2]

        let outcome = try await arrange(menuBar, hide: [Self.usage.bundleID])

        #expect(outcome.moved == [Self.usage.bundleID])
        #expect(menuBar.events == ["reveal", "refuse com.example.usage", "refuse com.example.usage", "drag com.example.usage to the hidden side", "hide"])
        #expect(menuBar.iconPositions[Self.clipboard.bundleID] == 600)
    }

    @Test("given an icon that will not move, when every attempt was used, then I am told which one and the others are still handled")
    func reportsWhatDidNotMove() async throws {
        let menuBar = menuBar(usage: 560, clipboard: 600)
        menuBar.dragsThatFail = [Self.usage.bundleID: 5]

        let outcome = try await arrange(menuBar, hide: [Self.usage.bundleID, Self.clipboard.bundleID, "com.example.gone"])

        #expect(outcome.failed == [Self.usage.bundleID])
        #expect(outcome.moved == [Self.clipboard.bundleID])
        #expect(outcome.notFound == ["com.example.gone"])
        #expect(menuBar.events.filter { $0.hasPrefix("drag com.example.usage") }.count == 3)
        #expect(menuBar.isHiding)
    }

    @Test("given Accessibility is not granted, when icons are arranged, then nothing is touched")
    func permissionMissing() async {
        let menuBar = menuBar(usage: 560, clipboard: 600)
        menuBar.isPermitted = false

        await #expect(throws: OrganizerError.permissionMissing) { _ = try await arrange(menuBar, hide: [Self.usage.bundleID]) }
        #expect(menuBar.events.isEmpty)
    }

    @Test("given the same app in two groups and another in one, when I list the apps with an icon in a group, then each appears once")
    func bundleIDsInGroups() {
        let usage = Item(name: "Claude Usage", kind: .menuBarIcon, target: "", bundleID: Self.usage.bundleID)
        let clipboard = Item(name: "Clipboard", kind: .menuBarIcon, target: "", bundleID: Self.clipboard.bundleID)
        let launcher = Item(name: "Notes", kind: .app, target: "/Applications/Notes.app", bundleID: "com.apple.Notes")
        let configuration = Configuration(groups: [
            Group(name: "Work", icon: GroupIcon(text: "briefcase"), items: [usage, launcher]),
            Group(name: "Tasks", icon: GroupIcon(text: "✅"), items: [clipboard, usage]),
        ])

        #expect(configuration.menuBarIconBundleIDs == [Self.usage.bundleID, Self.clipboard.bundleID])
    }
}
