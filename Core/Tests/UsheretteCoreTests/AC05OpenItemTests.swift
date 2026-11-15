import Testing
@testable import UsheretteCore

// AC-5 · Open an item. Pending: implement until it passes (SPEC.md, section 5).
@Suite("AC-5 · Open an item")
struct AC05OpenItemTests {
    @Test(
        "given a group with an app, a file and a URL, when I click each one, then the Launcher gets the request that matches its kind",
        .disabled("pending")
    )
    func scenario1() {}
}
