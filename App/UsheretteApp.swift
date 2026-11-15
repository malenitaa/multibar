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
        let model = AppModel(store: store, icons: AccessibilityMenuBarIcons(), marker: HidingMarker())
        let settings = SettingsWindowController(model: model)
        let menuBar = MenuBarController(openSettings: { settings.show() }, openItem: { model.open($0) })
        model.onGroupsChange = { [weak model] in menuBar.show(model?.configuration.groups ?? []) }
        model.onProblem = { settings.show() }
        self.model = model
        self.menuBar = menuBar
        self.settings = settings

        model.load()
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
        ProcessInfo.processInfo.environment["USHERETTE_CONFIG_DIR"].map { URL(fileURLWithPath: $0, isDirectory: true) }
            ?? JSONConfigStore.defaultDirectory
    }
}
