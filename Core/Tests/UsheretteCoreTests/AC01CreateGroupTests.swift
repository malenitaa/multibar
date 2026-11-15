import Testing

@testable import UsheretteCore

// AC-1 · Create groups with an icon (SPEC.md, section 5).
@Suite("AC-1 · Create groups with an icon")
struct AC01CreateGroupTests {
    @Test("given no groups, when I create Work with briefcase and Tasks with ✅, then there are two groups with their name and icon, in that order")
    func createsTwoGroupsInOrder() throws {
        let store = InMemoryConfigStore()
        let createGroup = CreateGroup(store: store)

        var configuration = try createGroup(name: "Work", icon: GroupIcon(text: "briefcase"), in: .empty)
        configuration = try createGroup(name: "Tasks", icon: GroupIcon(text: "✅"), in: configuration)

        #expect(configuration.groups.map(\.name) == ["Work", "Tasks"])
        #expect(configuration.groups.map(\.icon) == [GroupIcon(kind: .symbol, value: "briefcase"), GroupIcon(kind: .emoji, value: "✅")])
        #expect(configuration.groups.allSatisfy { $0.items.isEmpty })
        #expect(Set(configuration.groups.map(\.id)).count == 2)
        #expect(store.saved == configuration)
    }

    @Test("given an empty or whitespace-only name, when I try to create the group, then it is not created", arguments: ["", " ", "\t\n  "])
    func rejectsEmptyName(_ name: String) {
        let store = InMemoryConfigStore()

        #expect(throws: GroupError.emptyName) {
            try CreateGroup(store: store)(name: name, icon: GroupIcon(text: "briefcase"), in: .empty)
        }
        #expect(store.saveCount == 0)
    }

    @Test("given a name with spaces around it, when I create the group, then the spaces are dropped")
    func trimsName() throws {
        let configuration = try CreateGroup(store: InMemoryConfigStore())(name: "  Work \n", icon: GroupIcon(text: "briefcase"), in: .empty)

        #expect(configuration.groups.map(\.name) == ["Work"])
    }

    @Test("given the configuration cannot be saved, when I create a group, then the error is reported and nothing changes")
    func reportsSaveFailure() {
        let store = InMemoryConfigStore(failsOnSave: true)

        #expect(throws: InMemoryConfigStore.Failure.self) {
            try CreateGroup(store: store)(name: "Work", icon: GroupIcon(text: "briefcase"), in: .empty)
        }
        #expect(store.saved == nil)
    }

    @Test(
        "given what the user typed as icon, when the group is created, then an emoji is kept as emoji and anything else is a symbol name",
        arguments: [
            ("✅", GroupIcon.Kind.emoji, "✅"),
            ("💼", .emoji, "💼"),
            ("❤️", .emoji, "❤️"),
            ("👩‍💻", .emoji, "👩‍💻"),
            ("🇦🇷", .emoji, "🇦🇷"),
            ("  ✅ ", .emoji, "✅"),
            ("briefcase", .symbol, "briefcase"),
            (" briefcase.fill ", .symbol, "briefcase.fill"),
            ("1.circle", .symbol, "1.circle"),
            ("#", .symbol, "#"),
            ("", .symbol, ""),
        ]
    )
    func iconFromText(_ text: String, _ kind: GroupIcon.Kind, _ value: String) {
        #expect(GroupIcon(text: text) == GroupIcon(kind: kind, value: value))
    }
}
