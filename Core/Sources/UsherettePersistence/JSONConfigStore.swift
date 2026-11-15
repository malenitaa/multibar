import Foundation
import UsheretteCore

/// Keeps the configuration as a readable JSON file (`config.json`) in one folder.
public struct JSONConfigStore: ConfigStore {
    /// `~/Library/Application Support/Usherette`.
    public static var defaultDirectory: URL {
        URL.applicationSupportDirectory.appendingPathComponent("Usherette", isDirectory: true)
    }

    public let directory: URL
    private let now: @Sendable () -> Date

    public init(directory: URL, now: @escaping @Sendable () -> Date = { Date() }) {
        self.directory = directory
        self.now = now
    }

    public var fileURL: URL {
        directory.appendingPathComponent("config.json", isDirectory: false)
    }

    public func load() throws -> ConfigLoadResult {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return ConfigLoadResult(configuration: .empty)
        }
        let data = try Data(contentsOf: fileURL)

        let reason: ConfigLoadResult.Recovery.Reason
        if let version = try? JSONDecoder().decode(VersionProbe.self, from: data).version,
            version != Configuration.currentVersion
        {
            reason = version > Configuration.currentVersion ? .unsupportedVersion(version) : .unreadable
        } else if let configuration = try? JSONDecoder().decode(Configuration.self, from: data) {
            return ConfigLoadResult(configuration: configuration)
        } else {
            reason = .unreadable
        }

        let backupFileName = try setAside()
        return ConfigLoadResult(
            configuration: .empty,
            recovery: .init(reason: reason, backupFileName: backupFileName)
        )
    }

    public func save(_ configuration: Configuration) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        try encoder.encode(configuration).write(to: fileURL, options: .atomic)
    }

    /// Renames the file that could not be read so a later save cannot overwrite it.
    private func setAside() throws -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        let base = "config.json.bak-\(formatter.string(from: now()))"

        var name = base
        var attempt = 2
        while FileManager.default.fileExists(atPath: directory.appendingPathComponent(name).path) {
            name = "\(base)-\(attempt)"
            attempt += 1
        }
        try FileManager.default.moveItem(at: fileURL, to: directory.appendingPathComponent(name))
        return name
    }

    private struct VersionProbe: Decodable {
        let version: Int
    }
}
