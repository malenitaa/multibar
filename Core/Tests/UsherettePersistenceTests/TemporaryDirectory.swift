import Foundation

/// A directory that exists for the duration of one test.
struct TemporaryDirectory {
    let url: URL

    init() throws {
        url = FileManager.default.temporaryDirectory
            .appendingPathComponent("usherette-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    func remove() {
        try? FileManager.default.removeItem(at: url)
    }

    func fileNames() throws -> [String] {
        try FileManager.default.contentsOfDirectory(atPath: url.path).sorted()
    }
}
