import AppKit
import UsheretteCore

/// Keeps one menu bar icon per group.
@MainActor
final class MenuBarController: NSObject {
    private var statusItems: [NSStatusItem] = []
    private let openSettings: () -> Void

    init(openSettings: @escaping () -> Void) {
        self.openSettings = openSettings
    }

    func show(_ groups: [Group]) {
        for item in statusItems {
            NSStatusBar.system.removeStatusItem(item)
        }
        // macOS places each new status item to the left of the previous ones, so going through
        // the groups backwards makes the bar read in the order of the configuration.
        statusItems = groups.reversed().map(makeStatusItem)
    }

    private func makeStatusItem(for group: Group) -> NSStatusItem {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            if let image = group.icon.symbolImage(accessibilityDescription: group.name) {
                image.isTemplate = true
                button.image = image
            } else {
                button.title = group.icon.value
            }
            button.toolTip = group.name
            button.setAccessibilityLabel(group.name)
        }
        item.menu = makeMenu(for: group)
        return item
    }

    private func makeMenu(for group: Group) -> NSMenu {
        let menu = NSMenu()
        menu.addItem(disabledItem(group.name))
        menu.addItem(disabledItem("No items yet"))
        menu.addItem(.separator())
        let settings = NSMenuItem(title: "Settings…", action: #selector(showSettings), keyEquivalent: ",")
        settings.target = self
        menu.addItem(settings)
        menu.addItem(NSMenuItem(title: "Quit Usherette", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        return menu
    }

    private func disabledItem(_ title: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }

    @objc private func showSettings() {
        openSettings()
    }
}
