import Testing
@testable import UsherettePersistence

// AC-8 · Broken configuration. Pending: implement until it passes (SPEC.md, section 5).
@Suite("AC-8 · Broken configuration")
struct AC08BrokenConfigTests {
    @Test(
        "given a config.json with invalid JSON, when I load, then a dated .bak copy is kept, the app starts empty and the error is reported",
        .disabled("pending")
    )
    func scenario1() {}

    @Test(
        "given a config.json from an unknown version, when I load, then it is not overwritten and the .bak copy is kept",
        .disabled("pending")
    )
    func scenario2() {}
}
