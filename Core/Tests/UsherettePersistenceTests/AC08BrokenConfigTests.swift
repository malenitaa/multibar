import Foundation
import Testing
import UsheretteCore

@testable import UsherettePersistence

// AC-8 · Broken configuration (SPEC.md, section 5).
@Suite("AC-8 · Broken configuration")
struct AC08BrokenConfigTests {
    /// 2026-11-15 12:00:00 UTC.
    static let noon = Date(timeIntervalSince1970: 1_794_744_000)
    static let backupName = "config.json.bak-20261115T120000Z"

    func store(in directory: TemporaryDirectory) -> JSONConfigStore {
        JSONConfigStore(directory: directory.url, now: { Self.noon })
    }

    func write(_ text: String, in directory: TemporaryDirectory) throws {
        try Data(text.utf8).write(to: directory.url.appendingPathComponent("config.json"))
    }

    func read(_ name: String, in directory: TemporaryDirectory) throws -> String {
        try String(contentsOf: directory.url.appendingPathComponent(name), encoding: .utf8)
    }

    @Test("given a config.json with invalid JSON, when I load, then a dated .bak copy is kept, the app starts empty and the error is reported")
    func invalidJSON() throws {
        let directory = try TemporaryDirectory()
        defer { directory.remove() }
        try write("{ this is not json", in: directory)

        let loaded = try store(in: directory).load()

        #expect(loaded.configuration == .empty)
        #expect(loaded.recovery?.reason == .unreadable)
        #expect(loaded.recovery?.backupFileName == Self.backupName)
        #expect(try read(Self.backupName, in: directory) == "{ this is not json")
    }

    @Test("given a config.json from an unknown version, when I load, then it is not overwritten and the .bak copy is kept")
    func unknownVersion() throws {
        let directory = try TemporaryDirectory()
        defer { directory.remove() }
        let future = #"{"version": 99, "groups": [], "somethingNew": true}"#
        try write(future, in: directory)

        let loaded = try store(in: directory).load()

        #expect(loaded.configuration == .empty)
        #expect(loaded.recovery?.reason == .unsupportedVersion(99))
        #expect(try read(Self.backupName, in: directory) == future)
    }

    @Test("given a broken file was set aside, when I save new groups, then the copy is still there untouched")
    func saveAfterRecovery() throws {
        let directory = try TemporaryDirectory()
        defer { directory.remove() }
        try write("garbage", in: directory)
        let store = store(in: directory)

        _ = try store.load()
        try store.save(AC07PersistenceTests.twoGroups)

        #expect(try read(Self.backupName, in: directory) == "garbage")
        #expect(try store.load().configuration == AC07PersistenceTests.twoGroups)
        #expect(try directory.fileNames() == ["config.json", Self.backupName])
    }

    @Test("given a broken file was set aside, when I load again, then nothing new is reported and no second copy appears")
    func recoveryHappensOnce() throws {
        let directory = try TemporaryDirectory()
        defer { directory.remove() }
        try write("garbage", in: directory)
        let store = store(in: directory)

        _ = try store.load()
        let second = try store.load()

        #expect(second.recovery == nil)
        #expect(try directory.fileNames() == [Self.backupName])
    }

    @Test("given two broken files within the same second, when I load each, then both copies are kept")
    func backupNamesDoNotCollide() throws {
        let directory = try TemporaryDirectory()
        defer { directory.remove() }
        let store = store(in: directory)

        try write("first", in: directory)
        _ = try store.load()
        try write("second", in: directory)
        let loaded = try store.load()

        #expect(loaded.recovery?.backupFileName == Self.backupName + "-2")
        #expect(try read(Self.backupName, in: directory) == "first")
        #expect(try read(Self.backupName + "-2", in: directory) == "second")
    }

    @Test(
        "given a file that is valid JSON but not a configuration, when I load, then it is treated as unreadable",
        arguments: [
            "",
            "[]",
            "null",
            #"{"groups": []}"#,
            #"{"version": "one", "groups": []}"#,
            #"{"version": 1}"#,
            #"{"version": 0, "groups": []}"#,
            #"{"version": 1, "groups": [{"id": "not-a-uuid", "name": "x", "icon": {"kind": "symbol", "value": "a"}, "items": []}]}"#,
            #"{"version": 1, "groups": [{"id": "6F9619FF-8B86-D011-B42D-00C04FC964FF", "name": "x", "icon": {"kind": "hologram", "value": "a"}, "items": []}]}"#,
        ]
    )
    func notAConfiguration(_ content: String) throws {
        let directory = try TemporaryDirectory()
        defer { directory.remove() }
        try write(content, in: directory)

        let loaded = try store(in: directory).load()

        #expect(loaded.configuration == .empty)
        #expect(loaded.recovery != nil)
        #expect(try read(Self.backupName, in: directory) == content)
    }

    @Test("given a version 1 file with fields this build does not know, when I load, then the known fields are read and nothing is set aside")
    func unknownFieldsAreIgnored() throws {
        let directory = try TemporaryDirectory()
        defer { directory.remove() }
        try write(#"{"version": 1, "groups": [], "theme": "dark"}"#, in: directory)

        let loaded = try store(in: directory).load()

        #expect(loaded.configuration == .empty)
        #expect(loaded.recovery == nil)
        #expect(try directory.fileNames() == ["config.json"])
    }
}
