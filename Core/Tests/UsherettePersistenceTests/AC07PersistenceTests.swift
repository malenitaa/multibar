import Testing
@testable import UsherettePersistence

// AC-7 · Persistence. Pending: implement until it passes (SPEC.md, section 5).
@Suite("AC-7 · Persistence")
struct AC07PersistenceTests {
    @Test(
        "given two groups with items, when I save and load again from a temporary directory, then groups, icons, items and order are the same",
        .disabled("pending")
    )
    func scenario1() {}
}
