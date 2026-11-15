/// Opens the menu of another app's icon from a group: brings the hidden icons back, clicks
/// the icon, and hides them again once its menu has closed.
@MainActor
public struct OpenMenuBarIcon {
    /// How long each step is given.
    public struct Timing: Sendable {
        /// How often the menu bar is checked while waiting.
        public var poll: Duration = .milliseconds(50)
        /// How long the icon may take to come back after revealing.
        public var iconAppears: Duration = .seconds(2)
        /// How long the menu may take to show after the click.
        public var menuAppears: Duration = .milliseconds(1500)
        /// How long an open menu is waited for before hiding anyway.
        public var menuCloses: Duration = .seconds(120)
        /// How long the icons stay when the menu could not be seen opening.
        public var lingerWhenUnseen: Duration = .seconds(8)

        public init() {}
    }

    private let icons: any MenuBarIcons
    private let hider: any IconHider
    private let timing: Timing
    private let sleep: @MainActor (Duration) async -> Void

    public init(
        icons: any MenuBarIcons,
        hider: any IconHider,
        timing: Timing = Timing(),
        sleep: @escaping @MainActor (Duration) async -> Void = { try? await Task.sleep(for: $0) }
    ) {
        self.icons = icons
        self.hider = hider
        self.timing = timing
        self.sleep = sleep
    }

    /// Throws `OrganizerError`. Whatever happens, icons that were hidden end up hidden again.
    public func callAsFunction(bundleID: String) async throws {
        guard icons.isPermitted else { throw OrganizerError.permissionMissing }

        let wasHiding = hider.isHiding
        if wasHiding { hider.reveal() }
        defer { if wasHiding { hider.hide() } }

        guard await wait(upTo: timing.iconAppears, until: { icons.hasIcon(bundleID: bundleID) }),
            icons.openMenu(bundleID: bundleID)
        else { throw OrganizerError.iconNotFound }

        guard wasHiding else { return }
        if await wait(upTo: timing.menuAppears, until: { icons.isMenuOpen(bundleID: bundleID) }) {
            _ = await wait(upTo: timing.menuCloses, until: { !icons.isMenuOpen(bundleID: bundleID) })
        } else {
            await sleep(timing.lingerWhenUnseen)
        }
    }

    /// Checks `condition` every `timing.poll` and returns whether it became true in time.
    private func wait(upTo limit: Duration, until condition: () -> Bool) async -> Bool {
        var waited = Duration.zero
        while !condition() {
            guard waited < limit else { return false }
            await sleep(timing.poll)
            waited += timing.poll
        }
        return true
    }
}
