/// Moves other apps' icons to the side of the marker where they belong: behind it for apps
/// that are in a group, in view for apps that are not.
@MainActor
public struct ArrangeMenuBarIcons {
    /// What happened to each app that was asked about and needed moving.
    public struct Outcome: Equatable, Sendable {
        /// Icons that were moved.
        public var moved: [String] = []
        /// Apps that are not running or show no icon.
        public var notFound: [String] = []
        /// Icons that did not end up where they should after every attempt.
        public var failed: [String] = []

        public init() {}
    }

    public struct Timing: Sendable {
        public var poll: Duration = .milliseconds(50)
        /// How long the icons may take to come back after revealing.
        public var iconsAppear: Duration = .seconds(2)
        /// How long macOS keeps reporting positions from mid-rearrangement after a reveal.
        public var revealSettles: Duration = .milliseconds(700)
        /// How far apart two readings of the bar have to agree for it to count as still.
        public var stillFor: Duration = .milliseconds(200)
        /// How long a dragged icon may take to report its new place.
        public var moveSettles: Duration = .milliseconds(1500)
        /// How many times one icon is tried before giving up.
        public var attempts = 3
        /// How long to wait when an icon was not where it was expected, before trying again.
        public var retryPause: Duration = .milliseconds(400)
        /// How far past the marker's edge the pointer is taken.
        public var overshoot = 3.0

        public init() {}
    }

    private enum Side {
        case hidden
        case visible
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

    /// Puts the icons of `hide` behind the marker and those of `show` in view. Icons already
    /// on the right side are left alone. Throws `OrganizerError.permissionMissing` without the
    /// permission. Whatever happens, icons that were hidden end up hidden again.
    public func callAsFunction(hide: [String], show: [String] = []) async throws -> Outcome {
        guard icons.isPermitted else { throw OrganizerError.permissionMissing }

        let requests = hide.map { ($0, Side.hidden) } + show.map { ($0, Side.visible) }
        let wasHiding = hider.isHiding
        if wasHiding {
            hider.reveal()
            await sleep(timing.revealSettles)
        }
        defer { if wasHiding { hider.hide() } }

        // After revealing, the icons take a moment to come back; one of them is enough to go on.
        _ = await wait(upTo: timing.iconsAppear) { requests.contains { icons.iconFrame(bundleID: $0.0) != nil } }

        var outcome = Outcome()
        for (bundleID, side) in requests {
            guard icons.iconFrame(bundleID: bundleID) != nil else {
                outcome.notFound.append(bundleID)
                continue
            }
            if isOn(side, bundleID) { continue }

            var arrived = false
            for _ in 0..<timing.attempts where !arrived {
                await waitUntilStill(requests.map(\.0))
                guard let marker = hider.markerFrame else { break }
                let target = side == .hidden ? marker.lowerBound - timing.overshoot : marker.upperBound + timing.overshoot
                if icons.dragIcon(bundleID: bundleID, toX: target) {
                    arrived = await wait(upTo: timing.moveSettles) { isOn(side, bundleID) }
                } else {
                    // The bar is still settling: nothing was dragged. Look again in a moment.
                    await sleep(timing.retryPause)
                    arrived = isOn(side, bundleID)
                }
            }
            if arrived {
                outcome.moved.append(bundleID)
            } else {
                outcome.failed.append(bundleID)
            }
        }
        return outcome
    }

    private func isOn(_ side: Side, _ bundleID: String) -> Bool {
        guard let icon = icons.iconFrame(bundleID: bundleID), let marker = hider.markerFrame else { return false }
        let iconCentre = (icon.lowerBound + icon.upperBound) / 2
        let markerCentre = (marker.lowerBound + marker.upperBound) / 2
        return side == .hidden ? iconCentre < markerCentre : iconCentre > markerCentre
    }

    /// Waits until the marker and the icons report the same places twice in a row. While the
    /// bar is rearranging itself the reported places are wrong, and a drag aimed at them would
    /// land somewhere else.
    private func waitUntilStill(_ bundleIDs: [String]) async {
        func reading() -> [ClosedRange<Double>?] {
            [hider.markerFrame] + bundleIDs.map { icons.iconFrame(bundleID: $0) }
        }
        var last = reading()
        for _ in 0..<10 {
            await sleep(timing.stillFor)
            let now = reading()
            if now == last { return }
            last = now
        }
    }

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
