import Testing
@testable import UsheretteCore

// AC-1 · Create groups with an icon. Pending: implement until it passes (SPEC.md, section 5).
@Suite("AC-1 · Create groups with an icon")
struct AC01CreateGroupTests {
    @Test(
        "given no groups, when I create Work with briefcase and Tasks with ✅, then there are two groups with their name and icon, in that order",
        .disabled("pending")
    )
    func scenario1() {}

    @Test(
        "given an empty or whitespace-only name, when I try to create the group, then it is not created",
        .disabled("pending")
    )
    func scenario2() {}
}
