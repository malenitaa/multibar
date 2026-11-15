import Foundation
import Testing

@testable import UsheretteCore

// AC-12 · Put another app's menu bar icon in a group (SPEC.md, section 5).
@Suite("AC-12 · Put a menu bar app in a group")
struct AC12AddMenuBarIconTests {
    static let usage = MenuBarApp(bundleID: "com.example.usage", name: "Claude Usage")
    static let work = Group(name: "Work", icon: GroupIcon(text: "briefcase"))
    static let tasks = Group(name: "Tasks", icon: GroupIcon(text: "✅"))
    static let twoGroups = Configuration(groups: [work, tasks])

    @Test("given the Work group, when I add a menu bar app, then it becomes an item that remembers which app it is")
    func addsTheIcon() throws {
        let store = InMemoryConfigStore()

        let configuration = try AddMenuBarIcon(store: store)(Self.usage, toGroup: Self.work.id, in: Self.twoGroups)

        let item = try #require(configuration.groups[0].items.first)
        #expect(item.kind == .menuBarIcon)
        #expect(item.bundleID == "com.example.usage")
        #expect(item.name == "Claude Usage")
        #expect(configuration.groups[1].items.isEmpty)
        #expect(store.saved == configuration)
    }

    @Test("given the app is already in Work, when I add it again, then it is not duplicated")
    func doesNotDuplicate() throws {
        let store = InMemoryConfigStore()
        let addMenuBarIcon = AddMenuBarIcon(store: store)

        let once = try addMenuBarIcon(Self.usage, toGroup: Self.work.id, in: Self.twoGroups)
        let twice = try addMenuBarIcon(Self.usage, toGroup: Self.work.id, in: once)

        #expect(twice == once)
        #expect(store.saveCount == 1)
    }

    @Test("given the app is in Work, when I add it to Tasks, then it is in both")
    func sameAppInTwoGroups() throws {
        let addMenuBarIcon = AddMenuBarIcon(store: InMemoryConfigStore())

        var configuration = try addMenuBarIcon(Self.usage, toGroup: Self.work.id, in: Self.twoGroups)
        configuration = try addMenuBarIcon(Self.usage, toGroup: Self.tasks.id, in: configuration)

        #expect(configuration.groups.map { $0.items.count } == [1, 1])
    }

    @Test("given a group that does not exist, when I add an app to it, then it is refused and nothing is saved")
    func unknownGroup() {
        let store = InMemoryConfigStore()

        #expect(throws: GroupError.unknownGroup) {
            try AddMenuBarIcon(store: store)(Self.usage, toGroup: UUID(), in: Self.twoGroups)
        }
        #expect(store.saveCount == 0)
    }

    @Test("given an item in Work, when I remove it, then it is gone and the rest stays")
    func removes() throws {
        let store = InMemoryConfigStore()
        let other = MenuBarApp(bundleID: "org.example.clipboard", name: "Clipboard")
        var configuration = try AddMenuBarIcon(store: store)(Self.usage, toGroup: Self.work.id, in: Self.twoGroups)
        configuration = try AddMenuBarIcon(store: store)(other, toGroup: Self.work.id, in: configuration)
        let usageItem = try #require(configuration.groups[0].items.first)

        configuration = try RemoveItem(store: store)(usageItem.id, fromGroup: Self.work.id, in: configuration)

        #expect(configuration.groups[0].items.map(\.name) == ["Clipboard"])
        #expect(store.saved == configuration)
    }

    @Test("given an item that is not in the group, when I remove it, then nothing changes and nothing is saved")
    func removingWhatIsNotThere() throws {
        let store = InMemoryConfigStore()

        let configuration = try RemoveItem(store: store)(UUID(), fromGroup: Self.work.id, in: Self.twoGroups)

        #expect(configuration == Self.twoGroups)
        #expect(store.saveCount == 0)
    }
}
