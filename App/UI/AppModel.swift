import AppKit
import Observation
import UsheretteCore

/// What the menu bar and the settings window show, and the actions they can ask for.
@MainActor
@Observable
final class AppModel {
    private(set) var configuration = Configuration.empty
    /// Something the user should know about how the configuration was loaded.
    private(set) var notice: String?
    /// Why the last action did not work.
    private(set) var errorMessage: String?
    /// Whether Usherette may look at other apps' menu bar icons.
    private(set) var isAccessibilityGranted = false
    /// The apps known to have a menu bar icon. Empty without Accessibility. An icon that is
    /// hidden cannot be seen, so apps seen earlier stay listed while they keep running.
    private(set) var menuBarApps: [MenuBarApp] = []
    /// Whether hidden icons are shown for a moment so the user can move them around.
    private(set) var isArranging = false

    @ObservationIgnored var onGroupsChange: (() -> Void)?
    /// Called when something went wrong away from the settings window, which is where it is shown.
    @ObservationIgnored var onProblem: (() -> Void)?

    @ObservationIgnored private let store: any ConfigStore
    @ObservationIgnored private let icons: any MenuBarIcons
    @ObservationIgnored private let marker: HidingMarker
    @ObservationIgnored private let createGroup: CreateGroup
    @ObservationIgnored private let setIconHiding: SetIconHiding
    @ObservationIgnored private let addMenuBarIcon: AddMenuBarIcon
    @ObservationIgnored private let removeItem: RemoveItem
    @ObservationIgnored private let openMenuBarIcon: OpenMenuBarIcon

    init(store: any ConfigStore, icons: any MenuBarIcons, marker: HidingMarker) {
        self.store = store
        self.icons = icons
        self.marker = marker
        createGroup = CreateGroup(store: store)
        setIconHiding = SetIconHiding(store: store)
        addMenuBarIcon = AddMenuBarIcon(store: store)
        removeItem = RemoveItem(store: store)
        openMenuBarIcon = OpenMenuBarIcon(icons: icons, hider: marker)
    }

    /// Whether this display lets icons be hidden at all.
    var canHideIcons: Bool {
        marker.canHide
    }

    func load() {
        do {
            let result = try store.load()
            configuration = result.configuration
            if let recovery = result.recovery {
                notice = Self.describe(recovery)
            }
        } catch {
            errorMessage = "The configuration could not be read: \(error.localizedDescription)"
        }
        // The marker goes in first: group icons created after it are placed relative to it.
        applyHiding()
        onGroupsChange?()
    }

    /// Returns whether the group was created; `errorMessage` says why when it was not.
    @discardableResult
    func addGroup(name: String, iconText: String) -> Bool {
        change { try createGroup(name: name, icon: GroupIcon(text: iconText), in: configuration) }
    }

    // MARK: Other apps' icons

    func refreshMenuBarApps() {
        isAccessibilityGranted = icons.isPermitted
        guard isAccessibilityGranted else {
            menuBarApps = []
            return
        }
        let visible = icons.runningApps()
        let seenBefore = menuBarApps.filter { known in
            !visible.contains(known) && !NSRunningApplication.runningApplications(withBundleIdentifier: known.bundleID).isEmpty
        }
        menuBarApps = (visible + seenBefore).sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func requestAccessibility() {
        icons.requestPermission()
        refreshMenuBarApps()
    }

    func add(_ app: MenuBarApp, to group: Group) {
        change { try addMenuBarIcon(app, toGroup: group.id, in: configuration) }
    }

    func remove(_ item: Item, from group: Group) {
        change { try removeItem(item.id, fromGroup: group.id, in: configuration) }
    }

    func setHidesIcons(_ hidesIcons: Bool) {
        isArranging = false
        if change({ try setIconHiding(hidesIcons, in: configuration) }) {
            applyHiding()
        }
    }

    func setArranging(_ arranging: Bool) {
        isArranging = arranging
        applyHiding()
        guard arranging else { return }
        // The icons take a moment to come back; only then can they be listed.
        Task {
            try? await Task.sleep(for: .milliseconds(700))
            refreshMenuBarApps()
        }
    }

    func open(_ item: Item) {
        guard item.kind == .menuBarIcon, let bundleID = item.bundleID else { return }
        Task {
            do {
                try await openMenuBarIcon(bundleID: bundleID)
            } catch OrganizerError.permissionMissing {
                report("Opening \(item.name) from a group needs the Accessibility permission. You can allow it below.")
            } catch {
                report("\(item.name) is not running, or it has no icon in the menu bar right now.")
            }
        }
    }

    // MARK: Private

    /// Runs a use case that returns the new configuration, and reports why if it fails.
    @discardableResult
    private func change(_ useCase: () throws -> Configuration) -> Bool {
        do {
            configuration = try useCase()
            errorMessage = nil
            onGroupsChange?()
            return true
        } catch GroupError.emptyName {
            errorMessage = "Give the group a name."
        } catch {
            errorMessage = "The change could not be saved: \(error.localizedDescription)"
        }
        return false
    }

    private func report(_ message: String) {
        errorMessage = message
        refreshMenuBarApps()
        onProblem?()
    }

    private func applyHiding() {
        marker.setInstalled(configuration.hidesIcons)
        guard configuration.hidesIcons else { return }
        if isArranging {
            marker.reveal()
        } else {
            // A marker that was just created has no place in the bar yet; give macOS a moment.
            Task {
                try? await Task.sleep(for: .milliseconds(600))
                if configuration.hidesIcons, !isArranging { marker.hide() }
            }
        }
    }

    private static func describe(_ recovery: ConfigLoadResult.Recovery) -> String {
        let why =
            switch recovery.reason {
            case .unreadable: "Your configuration file could not be read"
            case .unsupportedVersion(let version): "Your configuration file comes from a newer Usherette (format \(version))"
            }
        return "\(why), so Usherette started empty. Nothing was deleted: the file was kept as \(recovery.backupFileName)."
    }
}
