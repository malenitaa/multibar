import AppKit
import UsheretteCore
import UsherettePersistence

// Composition: the only place that wires adapters and use cases (ADR 0002).
@main
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var model: AppModel?
    private var menuBar: MenuBarController?
    private var settings: SettingsWindowController?

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let store = JSONConfigStore(directory: Self.configDirectory)
        // A trial copy keeps its icons under other names and puts its marker just left of its own groups,
        // so it neither disturbs nor is hidden by the copy the user really runs.
        let isTrial = Self.trialDirectory != nil
        let marker = isTrial ? HidingMarker(autosaveName: "trial-icon-marker", firstPosition: 50) : HidingMarker()
        let model = AppModel(store: store, icons: AccessibilityMenuBarIcons(), marker: marker)
        let settings = SettingsWindowController(model: model)
        let menuBar = MenuBarController(
            namePrefix: isTrial ? "trial-" : "",
            openSettings: { settings.show() },
            openItem: { model.open($0) },
            hiddenIconsAction: { model.hiddenIconsAction }
        )
        model.onGroupsChange = { [weak model] in menuBar.show(model?.configuration.groups ?? []) }
        model.onProblem = { settings.show() }
        model.groupIconsAreShown = { menuBar.groupIconsAreShown }
        self.model = model
        self.menuBar = menuBar
        self.settings = settings

        model.load()
        model.checkIconsAreShown()
        // Waking up is when macOS has been seen to stop drawing an app's icons.
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { _ in
            Task { @MainActor in model.checkIconsAreShown() }
        }
        // With no groups there is no icon to click, so the window is the only way in.
        if model.configuration.groups.isEmpty || model.notice != nil || model.errorMessage != nil {
            settings.show()
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        settings?.show()
        return true
    }

    /// `USHERETTE_CONFIG_DIR` points the app at another folder, so it can be tried out without
    /// touching the real configuration.
    private static var configDirectory: URL {
        trialDirectory ?? JSONConfigStore.defaultDirectory
    }

    private static var trialDirectory: URL? {
        ProcessInfo.processInfo.environment["USHERETTE_CONFIG_DIR"].map { URL(fileURLWithPath: $0, isDirectory: true) }
    }
}
