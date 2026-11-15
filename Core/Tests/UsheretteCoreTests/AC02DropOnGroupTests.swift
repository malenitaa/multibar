import Testing
@testable import UsheretteCore

// AC-2 · Drop on the group icon. Pending: implement until it passes (SPEC.md, section 5).
@Suite("AC-2 · Drop on the group icon")
struct AC02DropOnGroupTests {
    @Test(
        "given the Work group, when I drop Microsoft Teams.app, then it becomes an item of kind app",
        .disabled("pending")
    )
    func scenario1() {}

    @Test(
        "given Teams is already in Work, when I drop it again, then it is not duplicated",
        .disabled("pending")
    )
    func scenario2() {}

    @Test(
        "given something that is not an app, file or folder, when I drop it, then it is ignored",
        .disabled("pending")
    )
    func scenario3() {}
}
