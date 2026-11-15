import Testing
@testable import UsheretteCore

// AC-6 · Reorder and remove. Pending: implement until it passes (SPEC.md, section 5).
@Suite("AC-6 · Reorder and remove")
struct AC06ReorderAndRemoveTests {
    @Test(
        "given a group with three items, when I move the third to the top, then the new order is kept",
        .disabled("pending")
    )
    func scenario1() {}

    @Test(
        "given a group with three items, when I remove one, then it does not come back",
        .disabled("pending")
    )
    func scenario2() {}

    @Test(
        "given two groups, when I move the second before the first, then the menu bar follows that order",
        .disabled("pending")
    )
    func scenario3() {}
}
