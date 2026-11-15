import Testing
@testable import UsheretteCore

// AC-4 · Item kinds. Pending: implement until it passes (SPEC.md, section 5).
@Suite("AC-4 · Item kinds")
struct AC04ItemKindsTests {
    @Test(
        "given the Work group, when I add utm://start?name=Windows, then it becomes a URL with a readable name",
        .disabled("pending")
    )
    func scenario1() {}

    @Test(
        "given the Work group, when I add a folder and a pdf, then they become a folder and a file",
        .disabled("pending")
    )
    func scenario2() {}
}
