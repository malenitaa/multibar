import Testing
@testable import MultibarCore

// AC-9 · Target that no longer exists. Pending: implement until it passes (SPEC.md, section 5).
@Suite("AC-9 · Target that no longer exists")
struct AC09MissingTargetTests {
    @Test(
        "given an item whose app was uninstalled, when I open the group, then it shows up disabled as not found",
        .disabled("pending")
    )
    func scenario1() {}

    @Test(
        "given an app that moved to another folder, when I open the group, then it is resolved by bundle id",
        .disabled("pending")
    )
    func scenario2() {}
}
