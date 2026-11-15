import Testing
@testable import MultibarCore

// AC-3 · Pick apps with checkboxes. Pending: implement until it passes (SPEC.md, section 5).
@Suite("AC-3 · Pick apps with checkboxes")
struct AC03PickAppsWithCheckboxesTests {
    @Test(
        "given Teams in the group, when I check Passwords and uncheck Teams, then Passwords is in, Teams is out and nothing else changes",
        .disabled("pending")
    )
    func scenario1() {}
}
