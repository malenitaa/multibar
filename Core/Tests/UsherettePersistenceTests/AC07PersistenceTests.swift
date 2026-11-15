import Foundation
import Testing
import UsheretteCore

@testable import UsherettePersistence

// AC-7 · Persistence (SPEC.md, section 5).
@Suite("AC-7 · Persistence")
struct AC07PersistenceTests {
    static let twoGroups = Configuration(groups: [
        Group(
            name: "Work",
            icon: GroupIcon(kind: .symbol, value: "briefcase"),
            items: [
                Item(name: "Microsoft Teams", kind: .app, target: "/Applications/Microsoft Teams.app", bundleID: "com.microsoft.teams2"),
                Item(name: "Windows", kind: .url, target: "utm://start?name=Windows"),
                Item(name: "Contracts", kind: .folder, target: "/Users/someone/Documents/Contracts"),
            ]
        ),
        Group(
            name: "Tasks",
            icon: GroupIcon(kind: .emoji, value: "✅"),
            items: [Item(name: "Plan.pdf", kind: .file, target: "/Users/someone/Desktop/Plan.pdf")]
        ),
    ])

    @Test("given two groups with items, when I save and load again from a temporary directory, then groups, icons, items and order are the same")
    func roundTrip() throws {
        let directory = try TemporaryDirectory()
        defer { directory.remove() }

        try JSONConfigStore(directory: directory.url).save(Self.twoGroups)
        let loaded = try JSONConfigStore(directory: directory.url).load()

        #expect(loaded.configuration == Self.twoGroups)
        #expect(loaded.recovery == nil)
    }

    @Test("given no configuration file yet, when I load, then the configuration is empty and nothing is reported")
    func firstLaunch() throws {
        let directory = try TemporaryDirectory()
        defer { directory.remove() }

        let loaded = try JSONConfigStore(directory: directory.url).load()

        #expect(loaded.configuration == .empty)
        #expect(loaded.recovery == nil)
        #expect(try directory.fileNames().isEmpty)
    }

    @Test("given the configuration folder does not exist, when I save, then it is created")
    func createsFolder() throws {
        let directory = try TemporaryDirectory()
        defer { directory.remove() }
        let nested = directory.url.appendingPathComponent("Usherette", isDirectory: true)

        try JSONConfigStore(directory: nested).save(Self.twoGroups)

        #expect(try JSONConfigStore(directory: nested).load().configuration == Self.twoGroups)
    }

    @Test("given a saved configuration, when I open the file, then it is readable JSON that states its version")
    func readableFile() throws {
        let directory = try TemporaryDirectory()
        defer { directory.remove() }
        let store = JSONConfigStore(directory: directory.url)

        try store.save(Self.twoGroups)
        let text = try String(contentsOf: store.fileURL, encoding: .utf8)

        #expect(text.contains("\"version\" : 1"))
        #expect(text.contains("\"name\" : \"Work\""))
        #expect(text.contains("\"kind\" : \"symbol\""))
        #expect(text.contains("/Applications/Microsoft Teams.app"))
    }

    @Test("given a saved configuration, when I save a different one, then the new one replaces it")
    func overwrite() throws {
        let directory = try TemporaryDirectory()
        defer { directory.remove() }
        let store = JSONConfigStore(directory: directory.url)

        try store.save(Self.twoGroups)
        try store.save(.empty)

        #expect(try store.load().configuration == .empty)
        #expect(try directory.fileNames() == ["config.json"])
    }
}
