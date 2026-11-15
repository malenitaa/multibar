import Testing
@testable import MultibarCore

// AC-10 · Launch at login. Pending: implement until it passes (SPEC.md, section 5).
@Suite("AC-10 · Launch at login")
struct AC10LaunchAtLoginTests {
    @Test(
        "given the option is off, when I turn it on, then the LoginItemService registers the app",
        .disabled("pending")
    )
    func scenario1() {}

    @Test(
        "given the option is on, when I turn it off, then it is unregistered",
        .disabled("pending")
    )
    func scenario2() {}
}
